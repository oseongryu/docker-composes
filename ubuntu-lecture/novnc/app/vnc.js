(() => {
  if (window.top !== window) return;
  const base = new URL(document.currentScript.src).origin;
  const icon = d => 'data:image/svg+xml,' + encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" viewBox="0 0 25 25"><path fill="#fff" d="M4 9.5h4l5-4.5v15l-5-4.5H4z"/><path fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" d="${d}"/></svg>`);
  const ON = icon('M16 9.5a4.5 4.5 0 0 1 0 6M18.5 7a8 8 0 0 1 0 11');
  const OFF = icon('M16.5 10l5 5M21.5 10l-5 5');

  function init() {
    const anchor = document.getElementById('noVNC_view_drag_button');
    if (!anchor) return;
    const btn = document.createElement('input');
    btn.type = 'image';
    btn.id = 'lecture_sound_button';
    btn.className = 'noVNC_button';
    btn.alt = '소리';
    let on = false, mode = 'basic', state = '정지';
    const show = () => {
      btn.src = on ? ON : OFF;
      btn.classList.toggle('noVNC_selected', on);
      btn.title = on ? `소리 끄기 (${state})` : '소리 켜기';
    };
    const player = LecturePlayer(s => { state = s; show(); }, base);
    btn.onclick = () => {
      on = !on;
      if (on) player.start(mode); else player.stop();
      show();
      document.querySelector('#noVNC_container canvas')?.focus({ preventScroll: true });
    };
    fetch(base + '/api/status').then(r => r.json()).then(s => { mode = s.audio_mode; }).catch(() => {});
    show();
    anchor.before(btn);
  }

  const s = document.createElement('script');
  s.src = base + '/player.js';
  s.onload = () => document.readyState === 'loading' ? addEventListener('DOMContentLoaded', init) : init();
  document.head.append(s);
})();