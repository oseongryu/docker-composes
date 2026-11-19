/* /screen 노트 패널. root 안의 notes_* 요소를 쓴다. 다시 듣는 동안 player(LecturePlayer) 실시간 소리를 음소거한다. 상태는 open(true) 인 동안만 2초마다 읽는다 */
function LectureNotes(root, player) {
  const $ = id => root.querySelector('#notes_' + id);
  const audio = $('audio'), view = $('view');
  const STAMP = /^\[((?:\d+:)?\d{1,2}:\d{2})\]\s*(.*)$/;
  let timer = null, notes = [], listSig = '', recording = null, current = null, noteSig = '';
  let tab = 'transcript', texts = {}, lines = [], now = -1, lastAuto = 0;

  const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const sec = t => t.split(':').reduce((a, p) => a * 60 + Number(p), 0);
  const two = n => String(n).padStart(2, '0');
  const clock = s => {
    s = Math.floor(s);
    const h = Math.floor(s / 3600), m = Math.floor(s / 60) % 60;
    return (h ? h + ':' + two(m) : two(m)) + ':' + two(s % 60);
  };
  const when = dir => {
    const m = dir.match(/^\d{4}(\d{2})(\d{2})_(\d{2})(\d{2})/);
    return m ? `${+m[1]}/${+m[2]} ${m[3]}:${m[4]}` : dir;
  };
  const file = (n, f) => `/notes/${encodeURIComponent(n.dir)}/${f}`;
  const has = (n, f) => n && n.files.includes(f);

  async function api(path, body) {
    const res = await fetch(path, body === undefined ? {} : { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || res.status);
    return data;
  }

  function md(src) {
    const inline = s => esc(s).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>').replace(/`([^`]+)`/g, '<code>$1</code>');
    const out = [];
    let list = false, table = null;
    const flush = () => {
      if (list) out.push('</ul>');
      if (table) out.push('<table>' + table.join('') + '</table>');
      list = false;
      table = null;
    };
    for (const raw of src.replace(/\r/g, '').split('\n')) {
      const line = raw.trim();
      let m;
      if (/^\|.*\|$/.test(line)) {
        const cells = line.slice(1, -1).split('|').map(c => c.trim());
        if (cells.every(c => /^:?-+:?$/.test(c))) continue;
        if (!table) { flush(); table = []; }
        const tag = table.length ? 'td' : 'th';
        table.push('<tr>' + cells.map(c => `<${tag}>${inline(c)}</${tag}>`).join('') + '</tr>');
      } else if ((m = line.match(/^(#{1,4})\s+(.*)$/))) {
        flush();
        out.push(`<h${m[1].length + 2}>${inline(m[2])}</h${m[1].length + 2}>`);
      } else if ((m = line.match(/^[-*]\s+(.*)$/))) {
        if (!list) { flush(); out.push('<ul>'); list = true; }
        out.push(`<li>${inline(m[1])}</li>`);
      } else if (list && line && /^\s/.test(raw)) {
        out[out.length - 1] = out[out.length - 1].replace(/<\/li>$/, ' ' + inline(line) + '</li>');
      } else if (line) {
        flush();
        out.push(`<p>${inline(line)}</p>`);
      }
    }
    flush();
    return out.join('').replace(/&lt;(\/?)(details|summary)&gt;/g, '<$1$2>');
  }

  function waiting(n, what) {
    const retry = `<button data-retry="${esc(n.dir)}">다시 처리</button>`;
    if (n.state === '녹음중') return `<p class="muted">녹음이 끝나면 ${what}. 녹음된 데까지는 위 재생기로 들을 수 있습니다.</p>`;
    if (n.state === '대기' || n.state === '처리중') return `<p class="muted">${what === '전사합니다' ? '전사' : '요약'} ${n.state === '대기' ? '대기 중' : '중'}입니다. 끝나면 여기에 나옵니다.</p>`;
    if (n.state === '실패') return `<p class="err">처리 실패</p><pre>${esc((texts['error.log'] || '').slice(0, 2000))}</pre>${retry}`;
    return `<p class="muted">아직 처리하지 않았습니다.</p>${retry}`;
  }

  function show() {
    root.querySelectorAll('#notes_tabs [data-tab]').forEach(b => b.classList.toggle('on', b.dataset.tab === tab));
    now = -1;
    lines = [];
    const n = current;
    if (!n) {
      view.innerHTML = '<p class="muted">녹음이 없습니다. 위에서 녹음을 시작하세요.</p>';
      return;
    }
    if (!texts) {
      view.innerHTML = '<p class="muted">불러오는 중</p>';
      return;
    }
    if (tab === 'summary') {
      view.innerHTML = texts['summary.md'] ? `<div class="md">${md(texts['summary.md'])}</div>` : waiting(n, '요약합니다');
    } else if (tab === 'subtitle') {
      view.innerHTML = texts['subtitle.txt']
        ? '<p class="muted">강의 영상 기준 시각이라 녹음 시각과 다릅니다.</p>' + texts['subtitle.txt'].split(/\r?\n/).filter(Boolean).map(l => {
          const m = l.match(STAMP);
          return m ? `<div class="line"><span class="t">${esc(m[1])}</span>${esc(m[2])}</div>` : `<div class="line">${esc(l)}</div>`;
        }).join('')
        : '<p class="muted">받은 자막이 없습니다. 플레이어 자막(CC)을 켜고 녹음하면 모입니다.</p>';
    } else if (texts['transcript.txt'] !== undefined) {
      view.innerHTML = texts['transcript.txt'].split(/\r?\n/).filter(Boolean).map(l => {
        const m = l.match(STAMP);
        return m ? `<div class="line seek" data-t="${sec(m[1])}"><span class="t">${esc(m[1])}</span>${esc(m[2])}</div>` : `<div class="line">${esc(l)}</div>`;
      }).join('');
      lines = [...view.querySelectorAll('[data-t]')];
      if (!view.children.length) view.innerHTML = '<p class="muted">알아들은 말소리가 없습니다.</p>';
      mark();
    } else {
      view.innerHTML = waiting(n, '전사합니다');
    }
  }

  function mark() {
    if (!lines.length) return;
    const t = audio.currentTime;
    let i = -1;
    for (let lo = 0, hi = lines.length - 1; lo <= hi;) {
      const mid = (lo + hi) >> 1;
      if (+lines[mid].dataset.t <= t + 0.05) { i = mid; lo = mid + 1; } else hi = mid - 1;
    }
    if (i === now) return;
    lines[now]?.classList.remove('now');
    now = i;
    if (i < 0) return;
    lines[i].classList.add('now');
    if ($('follow').checked && !audio.paused) view.scrollTo({ top: lines[i].offsetTop - view.clientHeight / 2, behavior: 'smooth' });
  }

  async function loadTexts(n) {
    const got = {};
    await Promise.all(['transcript.txt', 'subtitle.txt', 'summary.md', 'error.log'].filter(f => has(n, f)).map(async f => {
      try { got[f] = await (await fetch(file(n, f) + '?v=' + Date.now())).text(); } catch {}
    }));
    if (n.dir !== current?.dir) return;
    texts = got;
    show();
  }

  function reload(play) {
    const t = audio.currentTime, go = play || !audio.paused;
    audio.src = file(current, 'audio.ogg') + '?v=' + Date.now();
    audio.addEventListener('loadedmetadata', () => {
      audio.currentTime = Math.min(t, isFinite(audio.duration) ? audio.duration : t);
      if (go) audio.play().catch(() => {});
    }, { once: true });
  }

  function select(dir) {
    const n = notes.find(x => x.dir === dir) || null;
    const changed = n?.dir !== current?.dir;
    const wasRecording = current?.state === '녹음중';
    current = n;
    $('reload').hidden = n?.state !== '녹음중';
    if (!n) {
      if (changed) {
        audio.removeAttribute('src');
        audio.load();
        noteSig = '';
        texts = {};
        show();
      }
      return;
    }
    const sig = n.state + '|' + n.files.join(',');
    if (changed) {
      $('pick').value = n.dir;
      texts = null;
      if (has(n, 'audio.ogg')) {
        audio.src = file(n, 'audio.ogg') + '?v=' + Date.now();
      } else {
        audio.removeAttribute('src');
        audio.load();
      }
      show();
    } else if (sig !== noteSig && wasRecording && n.state !== '녹음중' && has(n, 'audio.ogg')) {
      reload(false);
    }
    if (changed || sig !== noteSig) loadTexts(n);
    noteSig = sig;
  }

  function render(st, pick) {
    recording = st.recording;
    $('rec').textContent = recording ? '녹음 종료' : '녹음 시작';
    $('recState').innerHTML = recording
      ? `<span class="rec">녹음 중 ${clock(recording.seconds)}</span> · 자막 ${recording.subs}개`
      : st.subs ? '녹음 대기' : '녹음 대기 · 자막 수집 끊김 (브라우저 확인)';
    notes = st.notes;
    const sig = JSON.stringify(notes.map(n => [n.dir, n.no, n.title, n.state]));
    if (sig !== listSig) {
      listSig = sig;
      $('pick').innerHTML = notes.length
        ? notes.map(n => `<option value="${esc(n.dir)}">${esc(when(n.dir))} · ${esc([n.no, n.title].filter(Boolean).join(' '))} · ${esc(n.state)}</option>`).join('')
        : '<option value="">녹음 없음</option>';
      if (current) $('pick').value = current.dir;
    }
    select(pick || (current && notes.some(n => n.dir === current.dir) ? current.dir : notes[0]?.dir));
  }

  async function poll() {
    try { render(await api('/api/status')); } catch {}
  }

  $('rec').onclick = async () => {
    $('err').textContent = '';
    try {
      const st = recording ? await api('/api/stop', {}) : await api('/api/start', { no: $('no').value, title: $('title').value });
      render(st, st.recording?.dir);
    } catch (e) { $('err').textContent = e.message; }
  };
  $('pick').onchange = () => select($('pick').value);
  $('tabs').onclick = e => {
    if (!e.target.dataset.tab) return;
    tab = e.target.dataset.tab;
    show();
  };
  view.onclick = async e => {
    const line = e.target.closest('[data-t]');
    if (line) {
      audio.currentTime = +line.dataset.t;
      audio.play().catch(() => {});
      return;
    }
    if (e.target.dataset.retry) {
      try { render(await api('/api/retry', { dir: e.target.dataset.retry })); } catch (err) { $('err').textContent = err.message; }
    }
  };
  $('back').onclick = () => { audio.currentTime = Math.max(0, audio.currentTime - 10); };
  $('fwd').onclick = () => { audio.currentTime = Math.min(isFinite(audio.duration) ? audio.duration : Infinity, audio.currentTime + 10); };
  $('rate').onchange = () => { audio.playbackRate = audio.defaultPlaybackRate = +$('rate').value; };
  $('reload').onclick = () => reload(false);
  audio.ontimeupdate = mark;
  audio.onplay = () => player.mute(true);
  audio.onpause = () => player.mute(false);
  audio.onended = () => {
    player.mute(false);
    if (current?.state === '녹음중' && Date.now() - lastAuto > 3000) {
      lastAuto = Date.now();
      reload(true);
    }
  };

  show();

  return {
    open(v) {
      clearInterval(timer);
      timer = null;
      if (!v) return;
      poll();
      timer = setInterval(poll, 2000);
    },
  };
}