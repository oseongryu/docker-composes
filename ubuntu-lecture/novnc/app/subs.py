import asyncio
import base64
import itertools
import json
from urllib.parse import urlparse
from urllib.request import urlopen

CDP = 'http://127.0.0.1:9222'
EXT = ('.vtt', '.srt')
ATTACH = {'autoAttach': True, 'waitForDebuggerOnStart': False, 'flatten': True}


class Capture:
    """브라우저 응답 중 자막만 저장한다. 각 대상에 Network 도메인만 켜고 페이지 동작을 바꾸는 명령은 보내지 않는다.

    target() 이 노트 폴더를 돌려줄 때만 저장하고 None 이면 버린다.
    """

    def __init__(self, target):
        self.target = target
        self.connected = False
        self.seen = set()

    async def run(self):
        import websockets
        while True:
            try:
                url = await asyncio.to_thread(ws_url)
                async with websockets.connect(url, max_size=None, ping_interval=None) as ws:
                    self.connected = True
                    print('자막연결', flush=True)
                    await Session(ws, self).run()
            except Exception:
                pass
            if self.connected:
                self.connected = False
                print('자막끊김', flush=True)
            await asyncio.sleep(5)


class Session:
    def __init__(self, ws, capture):
        self.ws = ws
        self.capture = capture
        self.ids = itertools.count(1)
        self.calls = {}
        self.pending = {}
        self.tasks = set()

    async def run(self):
        reader = asyncio.create_task(self.read())
        try:
            await self.send('Target.setAutoAttach', ATTACH)
            await reader
        finally:
            reader.cancel()
            for t in list(self.tasks):
                t.cancel()

    async def send(self, method, params=None, sid=None):
        i = next(self.ids)
        msg = {'id': i, 'method': method, 'params': params or {}}
        if sid:
            msg['sessionId'] = sid
        fut = asyncio.get_running_loop().create_future()
        self.calls[i] = fut
        await self.ws.send(json.dumps(msg))
        return await fut

    async def read(self):
        try:
            async for raw in self.ws:
                m = json.loads(raw)
                if 'id' in m:
                    fut = self.calls.pop(m['id'], None)
                    if fut and not fut.done():
                        fut.set_result(m.get('result') or {})
                    continue
                self.on_event(m.get('method'), m.get('params') or {}, m.get('sessionId'))
        finally:
            for fut in self.calls.values():
                if not fut.done():
                    fut.set_exception(ConnectionError('끊김'))
            self.calls.clear()

    def spawn(self, coro):
        async def guard():
            try:
                await coro
            except Exception:
                pass
        t = asyncio.create_task(guard())
        self.tasks.add(t)
        t.add_done_callback(self.tasks.discard)

    def on_event(self, method, p, sid):
        if method == 'Target.attachedToTarget':
            s = p['sessionId']
            self.spawn(self.send('Network.enable', sid=s))
            self.spawn(self.send('Target.setAutoAttach', ATTACH, sid=s))
        elif method == 'Network.responseReceived':
            res = p['response']
            ext = subtitle_ext(res.get('url', ''), res.get('mimeType', ''))
            note = self.capture.target()
            if ext and note is not None and res.get('status') == 200 and (note.name, res['url']) not in self.capture.seen:
                self.pending[(sid, p['requestId'])] = (note, res['url'], ext)
        elif method == 'Network.loadingFinished':
            hit = self.pending.pop((sid, p['requestId']), None)
            if hit:
                self.spawn(self.save(sid, p['requestId'], *hit))
        elif method == 'Network.loadingFailed':
            self.pending.pop((sid, p['requestId']), None)

    async def save(self, sid, rid, note, url, ext):
        if (note.name, url) in self.capture.seen:
            return
        self.capture.seen.add((note.name, url))
        res = await self.send('Network.getResponseBody', {'requestId': rid}, sid)
        if 'body' not in res:
            return
        body = base64.b64decode(res['body']) if res.get('base64Encoded') else res['body'].encode('utf-8')
        d = note / 'subs'
        d.mkdir(exist_ok=True)
        (d / f'{len(list(d.iterdir())):04d}{ext}').write_bytes(restore(body))
        print('자막수집', flush=True)


def ws_url():
    with urlopen(CDP + '/json/version', timeout=5) as r:
        return json.load(r)['webSocketDebuggerUrl']


def subtitle_ext(url, mime):
    path = urlparse(url).path.lower()
    ext = next((e for e in EXT if path.endswith(e)), None)
    if ext is None and 'text/vtt' in mime:
        ext = '.vtt'
    return ext


def restore(body):
    """charset 없이 온 텍스트는 CDP 가 latin-1 로 읽고 UTF-8 로 넘긴다. 원래 바이트로 되돌려 UTF-8 로 돌려준다."""
    try:
        raw = bytes(ord(c) if ord(c) < 256 else c.encode('cp1252')[0] for c in body.decode('utf-8'))
    except (UnicodeDecodeError, UnicodeEncodeError):
        return body
    for enc in ('utf-8', 'cp949'):
        try:
            return raw.decode(enc).encode('utf-8')
        except UnicodeDecodeError:
            pass
    return body


def count(note):
    d = note / 'subs'
    return len(list(d.iterdir())) if d.is_dir() else 0