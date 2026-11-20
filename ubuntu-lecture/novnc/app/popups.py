import shutil
import time
from datetime import datetime
from pathlib import Path

import subs

RULES = Path.home() / 'popups.txt'
LOG = Path.home() / 'popups.log'
DEFAULT = Path(__file__).with_name('popups.txt')
TYPES = ('alert', 'confirm')


class Closer(subs.Capture):
    """popups.txt 문구가 들어간 브라우저 안내창(alert·confirm)만 확인을 누른다. 나머지는 그대로 두고 popups.log 에 남긴다."""

    label = '팝업'

    def __init__(self):
        super().__init__(lambda: None)
        self.logged = {}

    def session(self, ws):
        return Session(ws, self)

    async def run(self):
        if not RULES.exists() and DEFAULT.exists():
            shutil.copyfile(DEFAULT, RULES)
        await super().run()

    async def dialog(self, session, sid, p):
        msg = ' '.join(p.get('message', '').split())
        kind = p.get('type', '')
        hit = kind in TYPES and any(r in msg for r in rules())
        if hit:
            await session.send('Page.handleJavaScriptDialog', {'accept': True}, sid)
        now = time.monotonic()
        if now - self.logged.get(msg, -60) > 5:
            self.logged[msg] = now
            log('닫음' if hit else '그대로', kind, msg)


class Session(subs.Session):
    DOMAINS = ('Page.enable',)

    def on_event(self, method, p, sid):
        if method == 'Page.javascriptDialogOpening':
            self.spawn(self.capture.dialog(self, sid, p))
        else:
            super().on_event(method, p, sid)


def rules():
    try:
        lines = RULES.read_text('utf-8-sig').splitlines()
    except OSError:
        return []
    return [' '.join(s.split()) for s in lines if s.strip() and not s.lstrip().startswith('#')]


def log(what, kind, msg):
    with LOG.open('a', encoding='utf-8') as f:
        f.write(f'{datetime.now():%Y-%m-%d %H:%M:%S} {what} {kind} {msg}\n')
    print('팝업' + what, flush=True)