(function() {
'use strict';

// ─── State ────────────────────────────────────────────────
let DATA = null;
let searchTimer = null;
let activeTimers = [];
const $ = s => document.querySelector(s);
const $$ = s => document.querySelectorAll(s);
const esc = s => { const d = document.createElement('div'); d.textContent = s; return d.innerHTML; };

// ─── Router ───────────────────────────────────────────────
const ROUTES = { '': 'dash', skills: 'skills', commands: 'cmds', agents: 'agents', terminal: 'term', memory: 'mem', config: 'cfg', tests: 'tests' };
function getRoute() { const [page, param] = location.hash.slice(1).split('/'); return { page: ROUTES[page] || 'dash', param }; }
window.addEventListener('hashchange', render);

// ─── Sidebar ──────────────────────────────────────────────
function toggleSidebar() { const sb = $('#sidebar'); const btn = $('#menuBtn'); sb.classList.toggle('open'); btn.classList.toggle('on'); btn.setAttribute('aria-expanded', sb.classList.contains('open')); }
function closeSidebar() { $('#sidebar').classList.remove('open'); const btn = $('#menuBtn'); btn.classList.remove('on'); btn.setAttribute('aria-expanded', 'false'); }
window.toggleSidebar = toggleSidebar;
window.closeSidebar = closeSidebar;

// Backdrop close
document.addEventListener('click', e => { const sb = $('#sidebar'); if (sb.classList.contains('open') && !sb.contains(e.target) && !$('#menuBtn').contains(e.target)) closeSidebar(); });

// ─── Nav ──────────────────────────────────────────────────
function buildNav(page) {
  const R = { dash: '', skills: 'skills', cmds: 'commands', agents: 'agents', term: 'terminal', mem: 'memory', cfg: 'config', tests: 'tests' };
  const sections = [
    { title: null, items: [{ id: 'dash', icon: '◈', label: 'Dashboard' }] },
    { title: 'KIT', items: [
      { id: 'skills', icon: '⚡', label: 'Skills', count: DATA.skills.length },
      { id: 'cmds', icon: '▶', label: 'Commands', count: DATA.commands.length },
      { id: 'agents', icon: '●', label: 'Agents', count: DATA.agents.length }
    ]},
    { title: 'TOOLS', items: [
      { id: 'term', icon: '>_', label: 'Terminal' },
      { id: 'mem', icon: '◆', label: 'Memory', count: DATA.memory.length },
      { id: 'cfg', icon: '⚙', label: 'Config' },
      { id: 'tests', icon: '✓', label: 'Tests' }
    ]}
  ];
  let html = '';
  sections.forEach(sec => {
    if (sec.title) html += `<div class="nav-section">${sec.title}</div>`;
    sec.items.forEach(item => {
      const active = page === item.id;
      const badge = item.count !== undefined ? `<span class="badge">${item.count}</span>` : '';
      html += `<a href="#${R[item.id] || ''}" class="nav-item${active ? ' active' : ''}"${active ? ' aria-current="page"' : ''} onclick="closeSidebar()"><span class="icon">${item.icon}</span> ${item.label}${badge}</a>`;
    });
  });
  $('#nav').innerHTML = html;
}

// ─── Cards ────────────────────────────────────────────────
function skillCard(s) {
  return `<a href="#skills/${s.name}" class="card" data-name="${esc(s.name)}" data-desc="${esc(s.description || '')}">
    <div class="name">${esc(s.name)}</div>
    <div class="desc">${esc(s.description || 'No description')}</div>
    <div class="meta"><span class="tag ${s.hasRun ? 'green' : 'orange'}">${s.hasRun ? 'HAS RUN.SH' : 'SKILL.MD ONLY'}</span></div>
  </a>`;
}
function cmdCard(c) {
  return `<a href="#commands/${c.name}" class="card" data-name="${esc(c.name)}" data-desc="${esc(c.description || '')}">
    <div class="name">/${esc(c.name)}</div>
    <div class="desc">${esc(c.description || 'No description')}</div>
  </a>`;
}

// ─── Pages ────────────────────────────────────────────────
const P = {
  dash() {
    const s = DATA.skills, c = DATA.commands, a = DATA.agents, w = s.filter(x => x.hasRun).length;
    return `<div class="page-header"><h1 tabindex="-1">Dashboard</h1><span class="sub">v${DATA.version}</span></div>
<div class="stats" role="list"><div class="stat" role="listitem"><div class="label">Health</div><div class="val g">SEHAT</div></div><div class="stat" role="listitem"><div class="label">Skills</div><div class="val b">${s.length}</div></div><div class="stat" role="listitem"><div class="label">Commands</div><div class="val o">${c.length}</div></div><div class="stat" role="listitem"><div class="label">Agents</div><div class="val p">${a.length}</div></div><div class="stat" role="listitem"><div class="label">Has Runner</div><div class="val c">${w}</div></div></div>
<div class="btn-row"><a href="#skills" class="btn primary">Browse Skills</a><a href="#commands" class="btn primary">Browse Commands</a><a href="#terminal" class="btn">Terminal</a></div>
<h3 style="color:var(--tx-3);margin-bottom:12px">Recent Skills</h3>
<div class="grid-2">${s.slice(0, 6).map(skillCard).join('')}</div>`;
  },

  skills() {
    return `<div class="page-header"><h1 tabindex="-1">Skills</h1><span class="sub">${DATA.skills.length} total</span></div>
<div class="search-wrap"><input class="search" placeholder="Search skills... (Ctrl+K)" id="q" role="search" aria-label="Search skills" oninput="window._f()"></div>
<div class="filters" id="flt" role="group" aria-label="Filter by category"></div>
<div class="grid" id="grd" role="list">${DATA.skills.map(skillCard).join('')}</div>`;
  },

  'skills/:name'(name) {
    const s = DATA.skills.find(x => x.name === name);
    if (!s) return '<div class="empty"><h3>Skill not found</h3></div>';
    return `<a href="#skills" class="back">← Back to Skills</a>
<div class="detail"><div class="detail-head"><h2 tabindex="-1">${esc(s.name)}</h2><div class="meta">${s.hasRun ? '<span class="tag green">HAS RUN.SH</span>' : '<span class="tag orange">SKILL.MD ONLY</span>'}</div></div>
<div class="detail-body"><pre>${esc(s.content)}</pre></div></div>`;
  },

  cmds() {
    return `<div class="page-header"><h1 tabindex="-1">Commands</h1><span class="sub">${DATA.commands.length} total</span></div>
<div class="search-wrap"><input class="search" placeholder="Search commands... (Ctrl+K)" id="q" role="search" aria-label="Search commands" oninput="window._f()"></div>
<div class="grid" id="grd" role="list">${DATA.commands.map(cmdCard).join('')}</div>`;
  },

  'commands/:name'(name) {
    const c = DATA.commands.find(x => x.name === name);
    if (!c) return '<div class="empty"><h3>Not found</h3></div>';
    return `<a href="#commands" class="back">← Back to Commands</a>
<div class="detail"><div class="detail-head"><h2 tabindex="-1">/${esc(c.name)}</h2></div>
<div class="detail-body"><pre>${esc(c.content)}</pre></div></div>`;
  },

  agents() {
    return `<div class="page-header"><h1 tabindex="-1">Agents</h1><span class="sub">${DATA.agents.length} total</span></div>
<div class="grid">${DATA.agents.map(a => `<div class="card" data-agent="${esc(a.name)}" role="listitem" tabindex="0"><div class="name">${esc(a.name)}</div><div class="desc">${esc(a.description)}</div></div>`).join('')}</div>`;
  },

  term() {
    return `<div class="page-header"><h1 tabindex="-1">Terminal</h1></div>
<div class="term-notice">⚠ Static build — terminal requires backend server. <code>cd web && npm start</code></div>
<div class="btn-row">
<button class="btn sm" disabled>Lint</button><button class="btn sm" disabled>Self-Test</button>
<button class="btn sm" disabled>Eval</button><button class="btn sm" disabled>Doctor</button><button class="btn sm" disabled>Audit</button>
</div>
<div class="term" role="log" aria-label="Terminal output" id="trm"><div class="ln pr">$ agent-ai terminal</div><div class="ln out">Read-only mode. Deploy with Node.js for live execution.</div></div>
<div class="term-bar"><input id="tc" placeholder="Disabled in static mode" disabled aria-label="Terminal command"><button class="btn primary" disabled>RUN</button></div>`;
  },

  mem() {
    if (!DATA.memory.length) return '<div class="page-header"><h1 tabindex="-1">Memory</h1></div><div class="empty"><h3>No memory files</h3></div>';
    return `<div class="page-header"><h1 tabindex="-1">Memory</h1><span class="sub">${DATA.memory.length} files</span></div>
<div class="grid">${DATA.memory.map(m => `<a href="#memory/${m.name}" class="card"><div class="name">${esc(m.name)}</div><div class="desc">${esc((m.content || '').substring(0, 150))}</div></a>`).join('')}</div>`;
  },

  'memory/:file'(name) {
    const m = DATA.memory.find(x => x.name === name);
    if (!m) return '<div class="empty"><h3>Not found</h3></div>';
    return `<a href="#memory" class="back">← Back to Memory</a>
<div class="detail"><div class="detail-head"><h2 tabindex="-1">${esc(m.name)}</h2></div>
<div class="detail-body"><pre>${esc(m.content)}</pre></div></div>`;
  },

  cfg() {
    return `<div class="page-header"><h1 tabindex="-1">Config</h1><span class="sub">opencode.json</span></div>
<div class="detail"><div class="detail-head"><h2>opencode.json</h2></div>
<div class="detail-body"><pre id="cfg">Loading from GitHub...</pre></div></div>`;
  },

  tests() {
    const suites = ['lint-kit', 'self-test', 'eval', 'e2e-flow', 'run-demo', 'test-update', 'mutation', 'bench'];
    return `<div class="page-header"><h1 tabindex="-1">Tests</h1><span class="sub">${suites.length} suites</span></div>
<div class="detail"><div class="detail-head"><h2>Demo Mode</h2><span class="tag orange">SIMULATED</span></div>
<div class="detail-body"><p style="color:var(--tx-3);margin-bottom:16px">Test results below are simulated. For real results, run <code>make verify</code> locally.</p></div></div>
<table class="tbl"><thead><tr><th>Suite</th><th>Status</th><th></th></tr></thead>
<tbody>${suites.map(s => `<tr><td>${s}</td><td id="s-${s}">—</td><td><button class="btn sm" onclick="window._tr('${s}')">Demo</button></td></tr>`).join('')}</tbody></table>`;
  }
};

// ─── Actions ──────────────────────────────────────────────
// Event delegation for agent cards
document.addEventListener('click', e => {
  const card = e.target.closest('.card[data-agent]');
  if (card) { const name = card.dataset.agent; const a = DATA.agents.find(x => x.name === name); if (a) renderAgent(a); }
});

function renderAgent(a) {
  $('#app').innerHTML = `<a href="#agents" class="back">← Back to Agents</a>
<div class="detail"><div class="detail-head"><h2 tabindex="-1">${esc(a.name)}</h2></div>
<div class="detail-body"><pre>${esc(a.content)}</pre></div></div>`;
  const h = $('#app h2'); if (h) h.focus();
}

window._tr = function(suite) {
  const list = suite === 'all' ? ['lint-kit', 'self-test', 'eval', 'e2e-flow', 'run-demo', 'test-update', 'mutation', 'bench'] : [suite];
  // Clear previous timers
  activeTimers.forEach(id => clearTimeout(id));
  activeTimers = [];
  list.forEach(s => {
    const el = $(`#s-${s}`);
    if (!el) return;
    el.innerHTML = '<span class="spin"></span>';
    const id = setTimeout(() => { el.innerHTML = '<span style="color:var(--green)">✓ PASS</span>'; }, 800 + Math.random() * 1500);
    activeTimers.push(id);
  });
};

// Debounced search
window._f = function() {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(() => {
    const q = ($('#q')?.value || '').toLowerCase();
    $$('#grd .card').forEach(card => {
      const name = (card.dataset.name || card.querySelector('.name')?.textContent || '').toLowerCase();
      const desc = (card.dataset.desc || card.querySelector('.desc')?.textContent || '').toLowerCase();
      card.style.display = (name.includes(q) || desc.includes(q)) ? '' : 'none';
    });
  }, 150);
};

// ─── Keyboard shortcuts ───────────────────────────────────
document.addEventListener('keydown', e => {
  // Ctrl+K or / — focus search
  if ((e.ctrlKey && e.key === 'k') || (e.key === '/' && !['INPUT', 'TEXTAREA'].includes(e.target.tagName))) {
    e.preventDefault();
    const q = $('#q');
    if (q) { q.focus(); q.select(); }
    else { location.hash = '#skills'; setTimeout(() => { const q2 = $('#q'); if (q2) q2.focus(); }, 100); }
  }
  // Escape — close sidebar or go back
  if (e.key === 'Escape') {
    const sb = $('#sidebar');
    if (sb.classList.contains('open')) { closeSidebar(); return; }
    const { page } = getRoute();
    if (page !== 'dash') { location.hash = '#'; }
  }
});

// ─── Render ───────────────────────────────────────────────
function render() {
  const { page, param } = getRoute();
  buildNav(page);

  let html = '';
  if (param && P[page + '/:name']) html = P[page + '/:name'](param);
  else if (P[page]) html = P[page]();
  else html = P.dash();

  $('#app').innerHTML = html;
  $('#app').scrollTop = 0;
  closeSidebar();

  // Focus h1 for screen readers
  const h1 = $('#app h1');
  if (h1) setTimeout(() => h1.focus(), 50);

  // Update title
  const titles = { dash: 'Dashboard', skills: 'Skills', cmds: 'Commands', agents: 'Agents', term: 'Terminal', mem: 'Memory', cfg: 'Config', tests: 'Tests' };
  document.title = (titles[page] || 'Dashboard') + ' — AGENT-AI';

  // Config page
  if (page === 'cfg') {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 10000);
    fetch('https://raw.githubusercontent.com/nemoobc/agent-ai/main/opencode.json', { signal: controller.signal })
      .then(r => { clearTimeout(timer); if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
      .then(d => { const e = $('#cfg'); if (e) e.textContent = JSON.stringify(d, null, 2); })
      .catch(e => { const el = $('#cfg'); if (el) el.textContent = 'Failed: ' + esc(e.message); });
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
      flt.innerHTML = `<button class="fbtn on" data-c="all" aria-pressed="true">All</button>` +
        Object.keys(cats).map(k => `<button class="fbtn" data-c="${k}" aria-pressed="false">${k.charAt(0).toUpperCase() + k.slice(1)}</button>`).join('');
      flt.querySelectorAll('.fbtn').forEach(btn => {
        btn.onclick = () => {
          flt.querySelectorAll('.fbtn').forEach(b => { b.classList.remove('on'); b.setAttribute('aria-pressed', 'false'); });
          btn.classList.add('on'); btn.setAttribute('aria-pressed', 'true');
          const cat = btn.dataset.c;
          const q = ($('#q')?.value || '').toLowerCase();
          $$('#grd .card').forEach(card => {
            const name = (card.dataset.name || '').toLowerCase();
            const desc = (card.dataset.desc || '').toLowerCase();
            const matchCat = cat === 'all' || cats[cat]?.test(name);
            const matchQ = name.includes(q) || desc.includes(q);
            card.style.display = matchCat && matchQ ? '' : 'none';
          });
        };
      });
    }
  }
}

// ─── Init ─────────────────────────────────────────────────
// Loading state
$('#app').innerHTML = `<div class="empty" style="margin-top:100px"><div class="spin" style="margin-bottom:16px"></div><h3>Loading...</h3></div>`;

fetch('data.json', { cache: 'force-cache' })
  .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
  .then(d => {
    if (!d.skills || !d.commands) throw new Error('Invalid data');
    DATA = d;
    $('#ver').textContent = 'v' + d.version;
    render();
  })
  .catch(e => {
    $('#app').innerHTML = `<div class="empty" style="margin-top:100px"><h3>Failed to load data</h3><p>${esc(e.message)}</p><button class="btn primary" onclick="location.reload()">Retry</button></div>`;
  });

})();
