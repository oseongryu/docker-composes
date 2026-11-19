(() => {
  if (window.top !== window) return;
  const base = new URL(document.currentScript.src).origin;
  const css = `
    body { display:flex; flex-direction:column; }
    #noVNC_container { flex:1; min-height:0; height:auto; }
    #lecture_bar { --bg:#fafafa; --fg:#1b1b1b; --muted:#6b6b6b; --line:#ddd; --accent:#c0392b;
      display:flex; gap:8px; align-items:center; flex-wrap:wrap; padding:6px 12px; border-bottom:1px solid var(--line);
      background:var(--bg); color:var(--fg); font:14px/1.4 system-ui, sans-serif; }
    @media (prefers-color-scheme: dark) {
      #lecture_bar { --bg:#161616; --fg:#eaeaea; --muted:#9a9a9a; --line:#333; --accent:#ff6b5b; }
    }
    #lecture_bar button, #lecture_bar select { font:inherit; margin:0; padding:4px 10px; border-radius:6px; border:1px solid var(--line);
      background:var(--bg); color:var(--fg); cursor:pointer; box-shadow:none; min-width:0; }
    #lecture_bar select { appearance:auto; }
    #lecture_bar button.primary { background:var(--accent); border-color:var(--accent); color:#fff; }
    #lecture_bar .muted { color:var(--muted); font-size:13px; }
    #lecture_bar .grow { flex:1; }
    #lecture_bar a { color:inherit; }`;

  function init() {
    const container = document.getElementById('noVNC_container');
    if (!container) return;
    const style = document.createElement('style');
    style.textContent = css;
    document.head.append(style);
    const bar = document.createElement('header');
    bar.id = 'lecture_bar';
    bar.innerHTML = `
      <button class="primary" id="lecture_listen">소리 켜기</button>
      <select id="lecture_mode"><option value="basic">기본</option><option value="low">저지연</option></select>
      <button id="lecture_reconnect">다시 연결</button>
      <span class="muted" id="lecture_state">정지</span>
      <span class="grow"></span>
      <a href="${base}/" target="_blank">노트 콘솔</a>`;
    container.before(bar);

    const $ = id => document.getElementById('lecture_' + id);
    const player = LecturePlayer(s => $('state').textContent = s, base);
    const back = () => document.querySelector('#noVNC_container canvas')?.focus({ preventScroll: true });
    let want = false;
    if (!player.supportsLow) $('mode').querySelector('[value=low]').disabled = true;
    $('listen').onclick = () => {
      want = !want;
      if (want) player.start($('mode').value); else player.stop();
      $('listen').textContent = want ? '소리 끄기' : '소리 켜기';
      back();
    };
    $('mode').onchange = () => { if (want) player.start($('mode').value); back(); };
    $('reconnect').onclick = () => { player.reconnect(); back(); };
    fetch(base + '/api/status').then(r => r.json()).then(st => {
      if (!want && st.audio_mode === 'low' && player.supportsLow) $('mode').value = 'low';
    }).catch(() => {});
  }

  const s = document.createElement('script');
  s.src = base + '/player.js';
  s.onload = () => document.readyState === 'loading' ? addEventListener('DOMContentLoaded', init) : init();
  document.head.append(s);
})();