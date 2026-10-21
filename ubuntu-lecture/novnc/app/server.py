import json
import queue
import re
import subprocess
import threading
import time
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import pipeline

NOTES = Path.home() / 'notes'
APP = Path(__file__).parent
SOURCE = 'lecture.monitor'
FILES = {'summary.md', 'transcript.txt', 'meta.json', 'error.log', 'audio.ogg'}
NAME = re.compile(r'^[\w\-]+$')

lock = threading.Lock()
recording = None
working = None
jobs = queue.Queue()


def worker():
    global working
    while True:
        note = jobs.get()
        working = note.name
        pipeline.process(note)
        working = None


def start(no, title):
    global recording
    with lock:
        if recording:
            raise ValueError('이미 녹음 중')
        meta = pipeline.lookup_course(no)
        if title:
            meta['title'] = title
        if not meta.get('title'):
            raise ValueError('연번을 찾지 못함. 제목을 입력하세요')
        meta['no'] = no
        meta['started'] = datetime.now().isoformat(timespec='seconds')
        note = NOTES / f"{datetime.now():%Y%m%d_%H%M%S}_{no or 'x'}"
        note.mkdir(parents=True)
        (note / 'meta.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding='utf-8')
        proc = subprocess.Popen(
            ['ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'pulse', '-i', SOURCE,
             '-ac', '1', '-ar', '16000', '-c:a', 'libopus', '-b:a', '32k', str(note / 'audio.ogg')],
            stdin=subprocess.PIPE,
        )
        recording = {'note': note, 'proc': proc, 'since': time.time()}
        print('녹음시작', flush=True)


def stop():
    global recording
    with lock:
        if not recording:
            raise ValueError('녹음 중이 아님')
        proc, note = recording['proc'], recording['note']
        try:
            proc.communicate(b'q', timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()
        recording = None
        jobs.put(note)
        print('녹음종료', flush=True)


def status():
    queued = {n.name for n in list(jobs.queue)}
    notes = []
    for d in sorted((p for p in NOTES.iterdir() if p.is_dir()), reverse=True):
        meta = json.loads((d / 'meta.json').read_text(encoding='utf-8')) if (d / 'meta.json').exists() else {}
        if recording and recording['note'] == d:
            state = '녹음중'
        elif d.name == working:
            state = '처리중'
        elif d.name in queued:
            state = '대기'
        elif (d / 'error.log').exists():
            state = '실패'
        elif (d / 'summary.md').exists():
            state = '완료'
        else:
            state = '미처리'
        files = sorted(f.name for f in d.iterdir() if f.name in FILES)
        notes.append({'dir': d.name, 'no': meta.get('no'), 'title': meta.get('title'), 'state': state, 'files': files})
    rec = None
    if recording:
        rec = {'dir': recording['note'].name, 'seconds': int(time.time() - recording['since'])}
    return {'recording': rec, 'notes': notes}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def send(self, code, body, ctype='application/json; charset=utf-8'):
        data = body if isinstance(body, bytes) else json.dumps(body, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == '/':
            return self.send(200, (APP / 'index.html').read_bytes(), 'text/html; charset=utf-8')
        if self.path == '/api/status':
            return self.send(200, status())
        if self.path.startswith('/stream.mp3'):
            return self.stream()
        parts = self.path.split('/')
        if len(parts) == 4 and parts[1] == 'notes' and NAME.match(parts[2]) and parts[3] in FILES:
            f = NOTES / parts[2] / parts[3]
            if f.is_file():
                ctype = 'audio/ogg' if f.suffix == '.ogg' else 'text/plain; charset=utf-8'
                return self.send(200, f.read_bytes(), ctype)
        self.send(404, {'error': '없음'})

    def do_POST(self):
        length = int(self.headers.get('Content-Length') or 0)
        body = json.loads(self.rfile.read(length) or b'{}')
        try:
            if self.path == '/api/start':
                start(str(body.get('no') or '').strip(), (body.get('title') or '').strip())
            elif self.path == '/api/stop':
                stop()
            elif self.path == '/api/retry' and NAME.match(body.get('dir', '')):
                jobs.put(NOTES / body['dir'])
            else:
                return self.send(404, {'error': '없음'})
        except ValueError as e:
            return self.send(409, {'error': str(e)})
        self.send(200, status())

    def stream(self):
        self.send_response(200)
        self.send_header('Content-Type', 'audio/mpeg')
        self.send_header('Cache-Control', 'no-cache, no-store')
        self.end_headers()
        proc = subprocess.Popen(
            ['ffmpeg', '-hide_banner', '-loglevel', 'error', '-fragment_size', '3840', '-f', 'pulse', '-i', SOURCE,
             '-ac', '2', '-ar', '44100', '-c:a', 'libmp3lame', '-b:a', '128k', '-flush_packets', '1', '-f', 'mp3', '-'],
            stdout=subprocess.PIPE,
        )
        try:
            while chunk := proc.stdout.read1(4096):
                self.wfile.write(chunk)
        except (BrokenPipeError, ConnectionResetError):
            pass
        finally:
            proc.kill()
            proc.wait()


if __name__ == '__main__':
    NOTES.mkdir(parents=True, exist_ok=True)
    threading.Thread(target=worker, daemon=True).start()
    print('시작', flush=True)
    ThreadingHTTPServer(('0.0.0.0', 8090), Handler).serve_forever()
