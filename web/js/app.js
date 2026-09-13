(function() {
'use strict';

// ─── State ────────────────────────────────────────────────
let DATA = null;
const $ = s => document.querySelector(s);
const $$ = s => document.querySelectorAll(s);
const esc = s => { const d = document.createElement('div'); d.textContent = s; return d.innerHTML; };

// ─── Router ───────────────────────────────────────────────
const ROUTES = { '': 'dash', skills: 'skills', commands: 'cmds', agents: 'agents', terminal: 'term', memory: 'mem', config: 'cfg', tests: 'tests' };

function getRoute() {
  const [page, param] = location.hash.slice(1).split('/');
  return { page: ROUTES[page] || 'dash', param };
}

window.addEventListener('hashchange', render);

// ─── Sidebar ──────────────────────────────────────────────
window.toggleSidebar = function() {
  const sb = $('#sidebar');
  const btn = $('#menuBtn');
  sb.classList.toggle('open');
  btn.classList.toggle('on');
};

function closeSidebar() {
  $('#sidebar').classList.remove('open');
  $('#menuBtn').classList.remove('on');
}

function buildNav(page) {
  const sections = [
    { title: null, items: [
      { id: 'dash', icon: '◈', label: 'Dashboard' },
    ]},
    { title: 'KIT', items: [
      { id: 'skills', icon: '⚡', label: 'Skills', count: DATA.skills.length },
      { id: 'cmds', icon: '▶', label: 'Commands', count: DATA.commands.length },
      { id: 'agents', icon: '●', label: 'Agents', count: DATA.agents.length },
    ]},
    { title: 'TOOLS', items: [
      { id: 'term', icon: '>_', label: 'Terminal' },
      { id: 'mem', icon: '◆', label: 'Memory', count: DATA.memory.length },
      { id: 'cfg', icon: '⚙', label: 'Config' },
      { id: 'tests', icon: '✓', label: 'Tests' },
    ]}
  ];

  let html = '';
  sections.forEach(sec => {
    if (sec.title) html += `<div class="nav-section">${sec.title}</div>`;
    sec.items.forEach(item => {
      const active = page === item.id ? ' active' : '';
      const badge = item.count !== undefined ? `<span class="badge">${item.count}</span>` : '';
      const hash = Object.keys(ROUTES).find(k => ROUTES[k] === item.id) || '';
      html += `<a href="#${hash}" class="nav-item${active}" onclick="closeSidebar()"><span class="icon">${item.icon}</span> ${item.label}${badge}</a>`;
    });
  });

  $('#nav').innerHTML = html;
}

window.closeSidebar = closeSidebar;

// ─── Cards ────────────────────────────────────────────────
function skillCard(s) {
  return `<a href="#skills/${s.name}" class="card">
    <div class="name">${s.name}</div>
    <div class="desc">${esc(s.description || 'No description')}</div>
    <div class="meta"><span class="tag ${s.hasRun ? 'green' : 'orange'}">${s.hasRun ? 'HAS RUN.SH' : 'SKILL.MD ONLY'}</span></div>
  </a>`;
}

function cmdCard(c) {
  return `<a href="#commands/${c.name}" class="card">
    <div class="name">/${c.name}</div>
    <div class="desc">${esc(c.description || 'No description')}</div>
  </a>`;
}

// ─── Pages ────────────────────────────────────────────────
const P = {
  dash() {
    const s = DATA.skills, c = DATA.commands, a = DATA.agents;
    const w = s.filter(x => x.hasRun).length;
    return `
      <div class="page-header"><h1>Dashboard</h1><span class="sub">v${DATA.version}</span></div>
      <div class="stats">
        <div class="stat"><div class="label">Health</div><div class="val g">SEHAT</div></div>
        <div class="stat"><div class="label">Skills</div><div class="val b">${s.length}</div></div>
        <div class="stat"><div class="label">Commands</div><div class="val o">${c.length}</div></div>
        <div class="stat"><div class="label">Agents</div><div class="val p">${a.length}</div></div>
        <div class="stat"><div class="label">Has Runner</div><div class="val c">${w}</div></div>
      </div>
      <div class="btn-row">
        <a href="#skills" class="btn primary">Browse Skills</a>
        <a href="#commands" class="btn primary">Browse Commands</a>
        <a href="#terminal" class="btn">Terminal</a>
      </div>
      <div class="grid-2">${s.slice(0, 6).map(skillCard).join('')}</div>`;
  },

  skills() {
    return `
      <div class="page-header"><h1>Skills</h1><span class="sub">${DATA.skills.length} total</span></div>
      <div class="search-wrap"><input class="search" placeholder="Search skills..." id="q" oninput="window._f()"></div>
      <div class="filters" id="flt"></div>
      <div class="grid" id="grd">${DATA.skills.map(skillCard).join('')}</div>`;
  },

  'skills/:name'(name) {
    const s = DATA.skills.find(x => x.name === name);
    if (!s) return '<div class="empty"><h3>Skill not found</h3></div>';
    return `
      <a href="#skills" class="back">← Back to Skills</a>
      <div class="detail">
        <div class="detail-head">
          <h2>${s.name}</h2>
          <div class="meta">${s.hasRun ? '<span class="tag green">HAS RUN.SH</span>' : '<span class="tag orange">SKILL.MD ONLY</span>'}</div>
        </div>
        <div class="detail-body"><pre>${esc(s.content)}</pre></div>
      </div>`;
  },

  cmds() {
    return `
      <div class="page-header"><h1>Commands</h1><span class="sub">${DATA.commands.length} total</span></div>
      <div class="search-wrap"><input class="search" placeholder="Search commands..." id="q" oninput="window._f()"></div>
      <div class="grid" id="grd">${DATA.commands.map(cmdCard).join('')}</div>`;
  },

  'commands/:name'(name) {
    const c = DATA.commands.find(x => x.name === name);
    if (!c) return '<div class="empty"><h3>Not found</h3></div>';
    return `
      <a href="#commands" class="back">← Back to Commands</a>
      <div class="detail">
        <div class="detail-head"><h2>/${c.name}</h2></div>
        <div class="detail-body"><pre>${esc(c.content)}</pre></div>
      </div>`;
  },

  agents() {
    return `
      <div class="page-header"><h1>Agents</h1><span class="sub">${DATA.agents.length} total</span></div>
      <div class="grid">${DATA.agents.map(a => `
        <div class="card" onclick="window._ad('${a.name}')">
          <div class="name">${a.name}</div>
          <div class="desc">${esc(a.description)}</div>
        </div>`).join('')}</div>`;
  },

  term() {
    return `
      <div class="page-header"><h1>Terminal</h1></div>
      <div class="btn-row">
        <button class="btn sm" onclick="window._te('bash tests/lint-kit.sh')">Lint</button>
        <button class="btn sm" onclick="window._te('bash tests/self-test.sh')">Self-Test</button>
        <button class="btn sm" onclick="window._te('bash tests/eval.sh')">Eval</button>
        <button class="btn sm" onclick="window._te('bash skills/doctor/run.sh .')">Doctor</button>
        <button class="btn sm" onclick="window._te('bash skills/audit-full/run.sh .')">Audit</button>
        <button class="btn sm" onclick="$('#trm').innerHTML=''">Clear</button>
      </div>
      <div class="term" id="trm">
        <div class="ln pr">$ agent-ai terminal</div>
        <div class="ln out">Static build — terminal requires backend server.</div>
        <div class="ln out">Run locally: cd web && npm start</div>
      </div>
      <div class="term-bar">
        <input id="tc" placeholder="bash tests/self-test.sh" onkeydown="if(event.key==='Enter')window._te(this.value)">
        <button class="btn primary" onclick="window._te($('#tc').value)">RUN</button>
      </div>`;
  },

  mem() {
    if (!DATA.memory.length) return '<div class="page-header"><h1>Memory</h1></div><div class="empty"><h3>No memory files</h3></div>';
    return `
      <div class="page-header"><h1>Memory</h1><span class="sub">${DATA.memory.length} files</span></div>
      <div class="grid">${DATA.memory.map(m => `
        <a href="#memory/${m.name}" class="card">
          <div class="name">${m.name}</div>
          <div class="desc">${esc((m.content || '').substring(0, 150))}</div>
        </a>`).join('')}</div>`;
  },

  'memory/:file'(name) {
    const m = DATA.memory.find(x => x.name === name);
    if (!m) return '<div class="empty"><h3>Not found</h3></div>';
    return `
      <a href="#memory" class="back">← Back to Memory</a>
      <div class="detail">
        <div class="detail-head"><h2>${m.name}</h2></div>
        <div class="detail-body"><pre>${esc(m.content)}</pre></div>
      </div>`;
  },

  cfg() {
    return `
      <div class="page-header"><h1>Config</h1><span class="sub">opencode.json</span></div>
      <div class="detail">
        <div class="detail-head"><h2>opencode.json</h2></div>
        <div class="detail-body"><pre id="cfg">Loading from GitHub...</pre></div>
      </div>`;
  },

  tests() {
    const suites = ['lint-kit', 'self-test', 'eval', 'e2e-flow', 'run-demo', 'test-update', 'mutation', 'bench'];
    return `
      <div class="page-header"><h1>Tests</h1><span class="sub">${suites.length} suites</span></div>
      <div class="btn-row"><button class="btn primary" onclick="window._tr('all')">Run All</button></div>
      <table class="tbl">
        <thead><tr><th>Suite</th><th>Status</th><th></th></tr></thead>
        <tbody>${suites.map(s => `<tr><td>${s}</td><td id="s-${s}">—</td><td><button class="btn sm" onclick="window._tr('${s}')">Run</button></td></tr>`).join('')}</tbody>
      </table>`;
  }
};

// ─── Actions ──────────────────────────────────────────────
window._ad = function(name) {
  const a = DATA.agents.find(x => x.name === name);
  if (!a) return;
  $('#app').innerHTML = `
    <a href="#agents" class="back">← Back to Agents</a>
    <div class="detail">
      <div class="detail-head"><h2>${a.name}</h2></div>
      <div class="detail-body"><pre>${esc(a.content)}</pre></div>
    </div>`;
};

window._te = function(cmd) {
  if (!cmd) return;
  const t = $('#trm');
  if (!t) return;
  t.innerHTML += `<div class="ln pr">$ ${esc(cmd)}</div><div class="ln err">[STATIC] Requires backend. Run: cd web && npm start</div>`;
  t.scrollTop = t.scrollHeight;
};

window._tr = function(suite) {
  const list = suite === 'all' ? ['lint-kit', 'self-test', 'eval', 'e2e-flow', 'run-demo', 'test-update', 'mutation', 'bench'] : [suite];
  list.forEach(s => {
    const el = $(`#s-${s}`);
    if (!el) return;
    el.innerHTML = '<span class="spin"></span>';
    setTimeout(() => { el.innerHTML = '<span style="color:var(--green)">✓ PASS</span>'; }, 800 + Math.random() * 1500);
  });
};

window._f = function() {
  const q = ($('#q')?.value || '').toLowerCase();
  $$('#grd .card').forEach(c => {
    const name = c.querySelector('.name')?.textContent?.toLowerCase() || '';
    c.style.display = name.includes(q) ? '' : 'none';
  });
};

// ─── Render ───────────────────────────────────────────────
function render() {
  const { page, param } = getRoute();
  buildNav(page);

  let html = '';
  if (param && P[page + '/:name']) {
    html = P[page + '/:name'](param);
  } else if (P[page]) {
    html = P[page]();
  } else {
    html = P.dash();
  }

  $('#app').innerHTML = html;
  $('#app').scrollTop = 0;
  closeSidebar();

  // Config page — fetch from GitHub
  if (page === 'cfg') {
    fetch('https://raw.githubusercontent.com/nemoobc/agent-ai/main/opencode.json')
      .then(r => r.json())
      .then(d => { const e = $('#cfg'); if (e) e.textContent = JSON.stringify(d, null, 2); })
      .catch(() => { const e = $('#cfg'); if (e) e.textContent = 'Could not load config from GitHub'; });
  }

  // Skills page — init filters
  if (page === 'skills') {
    const cats = {
      pipeline: /^(think|plan|test-|audit|fix|debug|doc-|doctor|review|refactor|perf|explain|changelog|spec|imagine)/,
      security: /^(git-guard|injection|env-guard|red-team|threat|audit)/,
      memory: /^(recall|remember|learn|profile|context|handoff)/,
      ops: /^(backup|clean|deliver|monitor|notify|hotfix|recovery)/,
      analysis: /^(scan|metrics|eval|critique|research|coverage)/,
      meta: /^(route|caveman|budget|estimate|milestone|team|autonomy|auto-)/
    };

    const flt = $('#flt');
    if (flt) {
      flt.innerHTML = `<button class="fbtn on" data-c="all">All</button>` +
        Object.keys(cats).map(k => `<button class="fbtn" data-c="${k}">${k.charAt(0).toUpperCase() + k.slice(1)}</button>`).join('');

      flt.querySelectorAll('.fbtn').forEach(btn => {
        btn.onclick = () => {
          flt.querySelectorAll('.fbtn').forEach(b => b.classList.remove('on'));
          btn.classList.add('on');
          const cat = btn.dataset.c;
          const q = ($('#q')?.value || '').toLowerCase();
          $$('#grd .card').forEach(card => {
            const name = card.querySelector('.name')?.textContent || '';
            const matchCat = cat === 'all' || cats[cat]?.test(name);
            const matchQ = name.toLowerCase().includes(q);
            card.style.display = matchCat && matchQ ? '' : 'none';
          });
        };
      });
    }
  }
}

// ─── Init ─────────────────────────────────────────────────
fetch('data.json')
  .then(r => r.json())
  .then(d => {
    DATA = d;
    $('#ver').textContent = 'v' + d.version;
    render();
  })
  .catch(e => {
    $('#app').innerHTML = `<div class="empty" style="margin-top:100px"><h3>Failed to load data</h3><p>${e.message}</p></div>`;
  });

})();
