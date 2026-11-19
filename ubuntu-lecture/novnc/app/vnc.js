(() => {
  const base = new URL(document.currentScript.src).origin;
  const settings = () => document.getElementById('noVNC_settings_button')?.click();
  if (window.top !== window) {
    addEventListener('message', e => { if (e.origin === base && e.data === 'lecture_settings') settings(); });
    return;
  }
  const KEY = 'lecture_bar_collapsed';
  const GRIP = '<svg width="8" height="14" viewBox="0 0 8 14" fill="currentColor"><circle cx="2" cy="3" r="1.3"/><circle cx="6" cy="3" r="1.3"/><circle cx="2" cy="7" r="1.3"/><circle cx="6" cy="7" r="1.3"/><circle cx="2" cy="11" r="1.3"/><circle cx="6" cy="11" r="1.3"/></svg>';
  const css = `
    body { display:flex; flex-direction:column; }
    #noVNC_container { flex:1; min-height:0; height:auto; }
    #lecture_bar, #lecture_mini { --bg:#fafafa; --fg:#1b1b1b; --muted:#6b6b6b; --line:#ddd; --accent:#c0392b;
      background:var(--bg); color:var(--fg); font:14px/1.4 system-ui, sans-serif; }
    @media (prefers-color-scheme: dark) {
      #lecture_bar, #lecture_mini { --bg:#161616; --fg:#eaeaea; --muted:#9a9a9a; --line:#333; --accent:#ff6b5b; }
    }
    #lecture_bar { display:flex; gap:8px; align-items:center; flex-wrap:wrap; padding:6px 12px; border-bottom:1px solid var(--line); }
    #lecture_mini { position:fixed; top:0; left:50%; transform:translateX(-50%); z-index:15; display:flex; width:max-content; gap:4px; padding:3px 6px;
      border:1px solid var(--line); border-top:0; border-radius:0 0 8px 8px; box-shadow:0 2px 6px rgba(0,0,0,.3); opacity:.85; font-size:12px; }
    #lecture_mini:hover { opacity:1; }
    #lecture_mini.moved { transform:none; border-top:1px solid var(--line); border-radius:8px; }
    #lecture_grip { display:flex; align-items:center; padding:0 2px; color:var(--muted); cursor:move; touch-action:none; user-select:none; }
    .lecture_collapsed #lecture_bar, :root:not(.lecture_collapsed) #lecture_mini { display:none; }
    #lecture_bar button, #lecture_bar select, #lecture_mini button { font:inherit; margin:0; padding:4px 10px; border-radius:6px; border:1px solid var(--line);
      background:var(--bg); color:var(--fg); cursor:pointer; box-shadow:none; min-width:0; }
    #lecture_mini button { padding:1px 8px; }
    #lecture_bar select { appearance:auto; }
    #lecture_bar button.primary, #lecture_mini button.primary { background:var(--accent); border-color:var(--accent); color:#fff; }
    #lecture_bar .muted { color:var(--muted); font-size:13px; }
    #lecture_bar .grow { flex:1; }
    #lecture_bar a { color:inherit; }`;

  function remember(v) {
    try { localStorage.setItem(KEY, v ? '1' : '0'); } catch {}
  }

  function collapsed() {
    try { return localStorage.getItem(KEY) === '1'; } catch { return false; }
  }

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
      <a href="${base}/" target="_blank">노트 콘솔</a>
      <button id="lecture_settings" title="noVNC 설정 (왼쪽 가장자리 손잡이와 같음)">설정</button>
      <button id="lecture_fold" title="막대를 접어 화면을 넓게">접기</button>`;
    const mini = document.createElement('div');
    mini.id = 'lecture_mini';
    mini.innerHTML = `
      <span id="lecture_grip" title="끌어서 옮기기 (두 번 누르면 가운데로)">${GRIP}</span>
      <button class="primary" id="lecture_mini_listen">소리 켜기</button>
      <button id="lecture_unfold" title="소리 막대 펼치기">펼치기</button>`;
    container.before(bar);
    document.body.append(mini);

    const $ = id => document.getElementById('lecture_' + id);
    const player = LecturePlayer(s => $('state').textContent = s, base);
    const back = () => document.querySelector('#noVNC_container canvas')?.focus({ preventScroll: true });
    const float = LectureFloat(mini, $('grip'), 'lecture_mini_pos', back);
    const fold = v => {
      document.documentElement.classList.toggle('lecture_collapsed', v);
      remember(v);
      float.apply();
      back();
    };
    let want = false;
    const toggle = () => {
      want = !want;
      if (want) player.start($('mode').value); else player.stop();
      $('listen').textContent = $('mini_listen').textContent = want ? '소리 끄기' : '소리 켜기';
      back();
    };
    if (!player.supportsLow) $('mode').querySelector('[value=low]').disabled = true;
    $('listen').onclick = $('mini_listen').onclick = toggle;
    $('mode').onchange = () => { if (want) player.start($('mode').value); back(); };
    $('reconnect').onclick = () => { player.reconnect(); back(); };
    $('settings').onclick = settings;
    $('fold').onclick = () => fold(true);
    $('unfold').onclick = () => fold(false);
    document.documentElement.classList.toggle('lecture_collapsed', collapsed());
    float.apply();
    fetch(base + '/api/status').then(r => r.json()).then(st => {
      if (!want && st.audio_mode === 'low' && player.supportsLow) $('mode').value = 'low';
    }).catch(() => {});
  }

  const load = src => new Promise((ok, no) => document.head.append(Object.assign(document.createElement('script'), { src: base + src, onload: ok, onerror: no })));
  Promise.all([load('/player.js'), load('/float.js')])
    .then(() => document.readyState === 'loading' ? addEventListener('DOMContentLoaded', init) : init())
    .catch(() => {});
})();