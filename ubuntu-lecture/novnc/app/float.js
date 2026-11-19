/* el 을 grip 으로 끌어 옮기고 위치를 화면 비율로 key 에 기억한다. 숨겨져 있던 el 을 보인 뒤엔 apply() 를 불러야 자리를 잡는다. 옮긴 동안 el 에 moved 클래스 */
function LectureFloat(el, grip, key, done = () => {}) {
  let pos = null;
  try { pos = JSON.parse(localStorage.getItem(key)); } catch {}
  const save = () => {
    try { pos ? localStorage.setItem(key, JSON.stringify(pos)) : localStorage.removeItem(key); } catch {}
  };
  const clamp = v => Math.min(Math.max(v, 0), 1);
  const room = () => [Math.max(innerWidth - el.offsetWidth, 0), Math.max(innerHeight - el.offsetHeight, 0)];
  const apply = () => {
    el.classList.toggle('moved', !!pos);
    if (!pos) { el.style.left = el.style.top = ''; return; }
    if (!el.offsetWidth) return;
    const [w, h] = room();
    el.style.left = Math.round(clamp(pos.x) * w) + 'px';
    el.style.top = Math.round(clamp(pos.y) * h) + 'px';
  };

  grip.addEventListener('pointerdown', e => {
    e.preventDefault();
    e.stopPropagation();
    grip.setPointerCapture(e.pointerId);
    const r = el.getBoundingClientRect();
    const dx = e.clientX - r.left, dy = e.clientY - r.top;
    const move = e => {
      e.stopPropagation();
      const [w, h] = room();
      pos = { x: clamp((e.clientX - dx) / (w || 1)), y: clamp((e.clientY - dy) / (h || 1)) };
      apply();
    };
    const up = () => {
      grip.removeEventListener('pointermove', move);
      grip.removeEventListener('pointerup', up);
      grip.removeEventListener('pointercancel', up);
      save();
      done();
    };
    grip.addEventListener('pointermove', move);
    grip.addEventListener('pointerup', up);
    grip.addEventListener('pointercancel', up);
  });
  grip.addEventListener('dblclick', () => { pos = null; save(); apply(); done(); });
  addEventListener('resize', apply);
  apply();
  return { apply };
}