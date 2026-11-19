import asyncio
from urllib.parse import urlparse

CDP = 'http://127.0.0.1:9222'
EXT = ('.vtt', '.srt')


class Capture:
    """브라우저 응답 중 자막만 저장한다. 요청을 보내거나 페이지를 조작하지 않는다.

    target() 이 노트 폴더를 돌려줄 때만 저장하고 None 이면 버린다.
    """

    def __init__(self, target):
        self.target = target
        self.connected = False
        self.seen = set()

    async def run(self):
        from playwright.async_api import async_playwright
        async with async_playwright() as pw:
            while True:
                try:
                    browser = await pw.chromium.connect_over_cdp(CDP)
                except Exception:
                    await asyncio.sleep(5)
                    continue
                gone = asyncio.Event()
                browser.on('disconnected', lambda *_: gone.set())
                for ctx in browser.contexts:
                    ctx.on('response', self.on_response)
                    # 리스너가 없으면 Playwright 가 alert·confirm 을 즉시 닫는다
                    ctx.on('dialog', lambda _: None)
                self.connected = True
                print('자막연결', flush=True)
                await gone.wait()
                self.connected = False
                print('자막끊김', flush=True)

    async def on_response(self, res):
        note = self.target()
        if note is None or res.status != 200:
            return
        path = urlparse(res.url).path.lower()
        ext = next((e for e in EXT if path.endswith(e)), None)
        if ext is None and 'text/vtt' in res.headers.get('content-type', ''):
            ext = '.vtt'
        if ext is None or (note.name, res.url) in self.seen:
            return
        self.seen.add((note.name, res.url))
        try:
            body = await res.body()
        except Exception:
            return
        d = note / 'subs'
        d.mkdir(exist_ok=True)
        (d / f'{len(list(d.iterdir())):04d}{ext}').write_bytes(restore(body))
        print('자막수집', flush=True)


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
