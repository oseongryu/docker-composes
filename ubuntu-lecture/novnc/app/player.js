function LecturePlayer(onState, base = '') {
  const supportsLow = !!(window.MediaSource && MediaSource.isTypeSupported('audio/mpeg'));
  let audio = null, ctl = null, timer = null, want = false, mode = 'basic', muted = false;

  function retry(el) {
    if (!want || el !== audio) return;
    onState('재연결 중');
    clearTimeout(timer);
    timer = setTimeout(connect, 1500);
  }

  function close() {
    clearTimeout(timer);
    if (ctl) ctl.abort();
    if (audio) {
      audio.pause();
      audio.removeAttribute('src');
      audio.load();
    }
    audio = ctl = null;
  }

  function connect() {
    close();
    const el = audio = new Audio();
    el.muted = muted;
    el.onplaying = () => { if (el === audio) onState('재생 중'); };
    el.onerror = el.onended = () => retry(el);
    const url = base + '/stream.mp3?t=' + Date.now();
    if (mode === 'low') low(el, url); else el.src = url;
    el.play().catch(() => {});
  }

  function low(el, url) {
    const ms = new MediaSource();
    const c = ctl = new AbortController();
    el.src = URL.createObjectURL(ms);
    ms.addEventListener('sourceopen', async () => {
      URL.revokeObjectURL(el.src);
      try {
        const sb = ms.addSourceBuffer('audio/mpeg');
        const q = [];
        const pump = () => {
          if (c.signal.aborted || sb.updating) return;
          try {
            const b = sb.buffered, t = el.currentTime;
            if (b.length && t - b.start(0) > 30) return sb.remove(0, t - 10);
            if (b.length && b.end(b.length - 1) - t > 1) el.currentTime = b.end(b.length - 1) - 0.3;
            if (q.length) sb.appendBuffer(q.shift());
          } catch (e) {
            c.abort();
          }
        };
        sb.addEventListener('updateend', pump);
        const r = (await fetch(url, { signal: c.signal })).body.getReader();
        for (;;) {
          const { value, done } = await r.read();
          if (done) break;
          q.push(value);
          pump();
        }
      } catch (e) {}
      retry(el);
    }, { once: true });
  }

  return {
    supportsLow,
    start(m) {
      mode = m === 'low' && supportsLow ? 'low' : 'basic';
      want = true;
      onState('연결 중');
      connect();
    },
    stop() {
      want = false;
      close();
      onState('정지');
    },
    reconnect() { if (want) connect(); },
    mute(v) {
      muted = v;
      if (audio) audio.muted = v;
    },
  };
}