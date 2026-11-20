import ctypes
import os
import subprocess
import sys
import time
from collections import deque
from datetime import datetime
from pathlib import Path

import av
import numpy as np

DISPLAY = os.environ.get('DISPLAY') or ':99'
SIZE = tuple(int(v) for v in (os.environ.get('RESOLUTION') or '1600x900x24').split('x')[:2])
DIR = Path.home() / 'popups'
LOG = Path.home() / 'popups.log'
INTERVAL = 3
THRESHOLD = 0.92
LIMIT = (3, 60)
PAUSE = 600


def grab():
    out = subprocess.run(
        ['ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'x11grab', '-draw_mouse', '0', '-video_size', '%dx%d' % SIZE, '-i', DISPLAY,
         '-frames:v', '1', '-pix_fmt', 'gray', '-f', 'rawvideo', '-'],
        capture_output=True, timeout=20).stdout
    if len(out) != SIZE[0] * SIZE[1]:
        raise RuntimeError('캡처실패')
    return np.frombuffer(out, np.uint8).reshape(SIZE[1], SIZE[0])


def load(path):
    with av.open(str(path)) as c:
        return next(c.decode(video=0)).to_ndarray(format='gray')


def match(img, tpl):
    """영점 정규화 상관. 돌려주는 값: (점수 0~1, 왼쪽 위 x, y)"""
    H, W = img.shape
    h, w = tpl.shape
    if h > H or w > W:
        return 0.0, 0, 0
    T = tpl.astype(np.float64)
    T -= T.mean()
    tn = np.sqrt((T * T).sum())
    if tn < 1e-3:
        return 0.0, 0, 0
    I = img.astype(np.float64)
    shape = (H + h, W + w)
    conv = np.fft.irfft2(np.fft.rfft2(I, shape) * np.fft.rfft2(T[::-1, ::-1], shape), shape)
    num = conv[h - 1:H, w - 1:W]

    def window(a):
        c = np.pad(a.cumsum(0).cumsum(1), ((1, 0), (1, 0)))
        return c[h:, w:] - c[:-h, w:] - c[h:, :-w] + c[:-h, :-w]

    var = window(I * I) - window(I) ** 2 / (h * w)
    den = np.sqrt(np.maximum(var, 0)) * tn
    ncc = np.divide(num, den, out=np.zeros_like(num), where=den > 1e-3)
    y, x = np.unravel_index(ncc.argmax(), ncc.shape)
    return float(ncc[y, x]), int(x), int(y)


class Mouse:
    def __init__(self):
        self.x11 = ctypes.CDLL('libX11.so.6')
        self.tst = ctypes.CDLL('libXtst.so.6')
        self.x11.XOpenDisplay.argtypes = [ctypes.c_char_p]
        self.x11.XOpenDisplay.restype = ctypes.c_void_p
        self.x11.XDefaultRootWindow.argtypes = [ctypes.c_void_p]
        self.x11.XDefaultRootWindow.restype = ctypes.c_ulong
        self.x11.XFlush.argtypes = [ctypes.c_void_p]
        self.x11.XQueryPointer.argtypes = [ctypes.c_void_p, ctypes.c_ulong] + [ctypes.c_void_p] * 7
        self.tst.XTestFakeMotionEvent.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ulong]
        self.tst.XTestFakeButtonEvent.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_int, ctypes.c_ulong]
        self.d = self.x11.XOpenDisplay(DISPLAY.encode())
        if not self.d:
            raise RuntimeError('화면연결실패')
        self.root = self.x11.XDefaultRootWindow(self.d)

    def where(self):
        rx, ry = ctypes.c_int(), ctypes.c_int()
        junk = [ctypes.c_ulong(), ctypes.c_ulong(), ctypes.c_int(), ctypes.c_int(), ctypes.c_uint()]
        self.x11.XQueryPointer(self.d, self.root, *[ctypes.byref(v) for v in junk[:2]], ctypes.byref(rx), ctypes.byref(ry),
                               *[ctypes.byref(v) for v in junk[2:]])
        return rx.value, ry.value

    def click(self, x, y):
        bx, by = self.where()
        self.move(x, y, 0.2)
        self.tst.XTestFakeButtonEvent(self.d, 1, 1, 0)
        self.x11.XFlush(self.d)
        time.sleep(0.1)
        self.tst.XTestFakeButtonEvent(self.d, 1, 0, 0)
        self.x11.XFlush(self.d)
        time.sleep(0.2)
        self.move(bx, by, 0)

    def move(self, x, y, wait):
        self.tst.XTestFakeMotionEvent(self.d, -1, x, y, 0)
        self.x11.XFlush(self.d)
        time.sleep(wait)


class Clicker:
    """~/popups/*.png 그림(밑줄로 시작하는 파일 제외)이 화면에 보이면 그 가운데를 한 번 누른다. 등록한 그림 외에는 누르지 않는다."""

    def __init__(self):
        self.cache = {}
        self.clicks = {}
        self.until = {}
        self.mouse = None

    def templates(self):
        found = {}
        for p in sorted(DIR.glob('*.png')) if DIR.is_dir() else []:
            if p.name.startswith('_'):
                continue
            stamp = p.stat().st_mtime
            if self.cache.get(p.name, (None,))[0] != stamp:
                try:
                    self.cache[p.name] = (stamp, load(p))
                except Exception:
                    self.cache[p.name] = (stamp, None)
            if self.cache[p.name][1] is not None:
                found[p.name] = self.cache[p.name][1]
        return found

    def scan(self):
        tpls = self.templates()
        if not tpls:
            return
        img = grab()
        now = time.monotonic()
        for name, tpl in tpls.items():
            score, x, y = match(img, tpl)
            if score < THRESHOLD or now < self.until.get(name, 0):
                continue
            hist = self.clicks.setdefault(name, deque())
            while hist and now - hist[0] > LIMIT[1]:
                hist.popleft()
            if len(hist) >= LIMIT[0]:
                self.until[name] = now + PAUSE
                hist.clear()
                log('중단', name)
                continue
            hist.append(now)
            if self.mouse is None:
                self.mouse = Mouse()
            self.mouse.click(x + tpl.shape[1] // 2, y + tpl.shape[0] // 2)
            log('클릭', name, '%d,%d' % (x, y), '%.2f' % score)
            return

    def run(self):
        while True:
            time.sleep(INTERVAL)
            try:
                self.scan()
            except Exception as e:
                log('오류', type(e).__name__)
                time.sleep(30)


def log(*words):
    with LOG.open('a', encoding='utf-8') as f:
        f.write('%s %s\n' % (datetime.now().strftime('%Y-%m-%d %H:%M:%S'), ' '.join(words)))
    print('팝업' + words[0], flush=True)


def shot():
    DIR.mkdir(exist_ok=True)
    out = DIR / '_화면.png'
    subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-f', 'x11grab', '-draw_mouse', '0', '-video_size', '%dx%d' % SIZE,
                    '-i', DISPLAY, '-frames:v', '1', str(out)], check=True)
    print(out)


def check():
    img = grab()
    tpls = Clicker().templates()
    for name, tpl in tpls.items():
        score, x, y = match(img, tpl)
        print('%-30s %.2f %s (%d,%d)' % (name, score, '보임' if score >= THRESHOLD else '안 보임', x, y))
    if not tpls:
        print('등록한 그림 없음')


if __name__ == '__main__':
    {'shot': shot, 'check': check}.get(sys.argv[1] if len(sys.argv) > 1 else '', lambda: print('사용: shot | check'))()