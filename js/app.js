(function() {
'use strict';

// ─── State ────────────────────────────────────────────────
let DATA = null;
let searchTimer = null;
let activeTimers = [];
const $ = s => document.querySelector(s);
const $$ = s => document.querySelectorAll(s);
const esc = s => { const d = document.createElement('div'); d.textContent = s; return d.innerHTML; };

// ─── Markdown Renderer (lightweight) ──────────────────────
function md(text) {
  if (!text) return '';
  return text
    .replace(/^```[\s\S]*?^```/gm, m => '<pre><code>' + esc(m.replace(/^```\w*\n?/gm,'').replace(/```$/m,'')) + '</code></pre>')
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/^### (.+)$/gm, '<h3>$1</h3>')
    .replace(/^## (.+)$/gm, '<h2>$1</h2>')
    .replace(/^# (.+)$/gm, '<h1>$1</h1>')
    .replace(/^\*\*(.+?)\*\*/gm, '<strong>$1</strong>')
    .replace(/^\*(.+?)\*/gm, '<em>$1</em>')
    .replace(/^> (.+)$/gm, '<blockquote>$1</blockquote>')
    .replace(/^---$/gm, '<hr>')
    .replace(/^\- (.+)$/gm, '<li>$1</li>')
    .replace(/(<li>.*<\/li>)/gs, '<ul>$1</ul>')
    .replace(/\n{2,}/g, '</p><p>')
    .replace(/\n/g, '<br>');
}

// ─── Toast ────────────────────────────────────────────────
function toast(msg, type='info') {
  const c = $('#toasts');
  const t = document.createElement('div');
  t.className = 'toast ' + type;
  t.textContent = msg;
  c.appendChild(t);
  setTimeout(() => { t.classList.add('fade-out'); setTimeout(() => t.remove(), 300); }, 3000);
}
window.toast = toast;

// ─── Router ───────────────────────────────────────────────
const ROUTES = { '': 'dash', skills: 'skills', commands: 'cmds', agents: 'agents', terminal: 'term', memory: 'mem', config: 'cfg', tests: 'tests' };
function getRoute() { const [page, param] = location.hash.slice(1).split('/'); return { page: ROUTES[page] || 'dash', param }; }
window.addEventListener('hashchange', render);

// ─── Theme ────────────────────────────────────────────────
function getTheme() { return localStorage.getItem('agent-ai-theme') || 'dark'; }
function setTheme(t) { document.documentElement.setAttribute('data-theme', t); localStorage.setItem('agent-ai-theme', t); const btn = $('#themeBtn'); if (btn) btn.textContent = t === 'dark' ? '☀' : '☾'; }
window.toggleTheme = () => { const cur = getTheme(); setTheme(cur === 'dark' ? 'light' : 'dark'); toast('Theme: ' + getTheme(), 'info'); };
setTheme(getTheme());

// ─── Sidebar ──────────────────────────────────────────────
function toggleSidebar() { const sb = $('#sidebar'); const btn = $('#menuBtn'); const isMobile = window.innerWidth <= 768; if (isMobile) { sb.classList.toggle('open'); btn.classList.toggle('on'); } else { sb.classList.toggle('collapsed'); } btn.setAttribute('aria-expanded', sb.classList.contains('open') || !sb.classList.contains('collapsed')); }
function closeSidebar() { const sb = $('#sidebar'); const btn = $('#menuBtn'); sb.classList.remove('open'); btn.classList.remove('on'); btn.setAttribute('aria-expanded', 'false'); }
window.toggleSidebar = toggleSidebar;
window.closeSidebar = closeSidebar;
document.addEventListener('click', e => { const sb = $('#sidebar'); if (sb.classList.contains('open') && !sb.contains(e.target) && !$('#menuBtn')?.contains(e.target)) closeSidebar(); });

// ─── Welcome ──────────────────────────────────────────────
function showWelcome() {
  if (localStorage.getItem('agent-ai-seen')) return false;
  const o = document.createElement('div');
  o.className = 'welcome-overlay';
  o.innerHTML = `<div class="welcome"><img src="img/logo.svg" alt="" class="welcome-icon-svg"><h1>AGENT-AI</h1><p class="welcome-sub">DEV-BRAIN Kit Dashboard</p><div class="welcome-stats"><div class="ws"><span class="ws-val" id="wv1">0</span><span class="ws-label">Skills</span></div><div class="ws"><span class="ws-val" id="wv2">0</span><span class="ws-label">Commands</span></div><div class="ws"><span class="ws-val" id="wv3">0</span><span class="ws-label">Agents</span></div></div><p class="welcome-desc">Browse skills, commands, agents, and explore the DEV-BRAIN kit.</p><button class="welcome-btn" id="welcomeBtn">Get Started</button><div class="welcome-footer">v<span id="wv"></span> • Built with ♥</div></div>`;
  document.body.appendChild(o);
  let s=0,c=0,a=0;
  const ti = setInterval(() => { if(s<DATA.skills.length){s++;$('#wv1').textContent=s} if(c<DATA.commands.length){c++;$('#wv2').textContent=c} if(a<DATA.agents.length){a++;$('#wv3').textContent=a} if(s>=DATA.skills.length&&c>=DATA.commands.length&&a>=DATA.agents.length)clearInterval(ti); }, 25);
  $('#wv').textContent = DATA.version;
  $('#welcomeBtn').onclick = () => { o.classList.add('fade-out'); setTimeout(() => o.remove(), 400); localStorage.setItem('agent-ai-seen', '1'); toast('Welcome to AGENT-AI!', 'success'); };
  return true;
}

// ─── Shortcuts Modal ──────────────────────────────────────
window.closeShortcuts = () => { $('#shortcutsModal').classList.remove('open'); };

// ─── Back to Top ──────────────────────────────────────────
function initBackTop() {
  const btn = document.createElement('button');
  btn.className = 'back-top';
  btn.innerHTML = '↑';
  btn.onclick = () => { const c = $('.content'); if(c) c.scrollTo({top:0,behavior:'smooth'}); };
  btn.setAttribute('aria-label', 'Back to top');
  document.body.appendChild(btn);
  const c = $('.content');
  if (c) c.addEventListener('scroll', () => { btn.classList.toggle('visible', c.scrollTop > 300); });
}

// ─── Counter Animation ────────────────────────────────────
function animateCounter(el, target) {
  let current = 0;
  const step = Math.max(1, Math.ceil(target / 30));
  const timer = setInterval(() => {
    current += step;
    if (current >= target) { current = target; clearInterval(timer); }
    el.textContent = current;
  }, 20);
}

// ─── Bottom Nav ───────────────────────────────────────────
function buildBottomNav(page) {
  const items = [
    { id: 'dash', icon: '◈', label: 'Home' },
    { id: 'skills', icon: '⚡', label: 'Skills' },
    { id: 'cmds', icon: '▶', label: 'Commands' },
    { id: 'agents', icon: '●', label: 'Agents' },
    { id: 'term', icon: '>_', label: 'Terminal' },
  ];
  const R = { dash:'', skills:'skills', cmds:'commands', agents:'agents', term:'terminal' };
  $('#bottomNav').innerHTML = items.map(i => `<a href="#${R[i.id]}" class="${page===i.id?'active':''}"><span class="bi">${i.icon}</span>${i.label}</a>`).join('');
}

// ─── Nav ──────────────────────────────────────────────────
function buildNav(page) {
  const R = { dash:'', skills:'skills', cmds:'commands', agents:'agents', term:'terminal', mem:'memory', cfg:'config', tests:'tests' };
  const sections = [
    { title: null, items: [{ id:'dash', icon:'◈', label:'Dashboard' }] },
    { title:'KIT', items: [
      { id:'skills', icon:'⚡', label:'Skills', count:DATA.skills.length },
      { id:'cmds', icon:'▶', label:'Commands', count:DATA.commands.length },
      { id:'agents', icon:'●', label:'Agents', count:DATA.agents.length }
    ]},
    { title:'TOOLS', items: [
      { id:'term', icon:'>_', label:'Terminal' },
      { id:'mem', icon:'◆', label:'Memory', count:DATA.memory.length },
      { id:'cfg', icon:'⚙', label:'Config' },
      { id:'tests', icon:'✓', label:'Tests' }
    ]}
  ];
  let html = '';
  sections.forEach(sec => {
    if(sec.title) html += `<div class="nav-section">${sec.title}</div>`;
    sec.items.forEach(item => {
      const active = page === item.id;
      const badge = item.count !== undefined ? `<span class="badge">${item.count}</span>` : '';
      html += `<a href="#${R[item.id]||''}" class="nav-item${active?' active':''}"${active?' aria-current="page"':''} onclick="closeSidebar()"><span class="icon">${item.icon}</span> ${item.label}${badge}</a>`;
    });
  });
  $('#nav').innerHTML = html;
  buildBottomNav(page);
}

// ─── Breadcrumb ───────────────────────────────────────────
function breadcrumb(parts) {
  if (!parts.length) return '';
  return `<div class="breadcrumb">${parts.map((p,i) => i === parts.length-1 ? `<span class="current">${esc(p)}</span>` : `<a href="#${p.toLowerCase()}">${esc(p)}</a><span class="sep">/</span>`).join('')}</div>`;
}

// ─── Cards ────────────────────────────────────────────────
function skillCard(s, i) {
  return `<a href="#skills/${s.name}" class="card" data-name="${esc(s.name)}" data-desc="${esc(s.description||'')}" style="animation-delay:${Math.min(i*.03,.3)}s">
    <div class="name">${esc(s.name)}</div>
    <div class="desc">${esc(s.description||'No description')}</div>
    <div class="meta"><span class="tag ${s.hasRun?'green':'orange'}">${s.hasRun?'HAS RUN.SH':'SKILL.MD ONLY'}</span></div>
  </a>`;
}
function cmdCard(c, i) {
  return `<a href="#commands/${c.name}" class="card" data-name="${esc(c.name)}" data-desc="${esc(c.description||'')}" style="animation-delay:${Math.min(i*.03,.3)}s">
    <div class="name">/${esc(c.name)}</div>
    <div class="desc">${esc(c.description||'No description')}</div>
  </a>`;
}

// ─── Pages ────────────────────────────────────────────────
const P = {
  dash() {
    const s=DATA.skills, c=DATA.commands, a=DATA.agents, w=s.filter(x=>x.hasRun).length;
    return `${breadcrumb(['Home'])}
<div class="page-header"><h1 tabindex="-1">Dashboard</h1><span class="sub">v${DATA.version}</span></div>
<div class="stats" role="list">
  <div class="stat" role="listitem"><div class="label">Health</div><div class="val g">SEHAT</div></div>
  <div class="stat" role="listitem"><div class="label">Skills</div><div class="val b counter" data-target="${s.length}">0</div></div>
  <div class="stat" role="listitem"><div class="label">Commands</div><div class="val o counter" data-target="${c.length}">0</div></div>
  <div class="stat" role="listitem"><div class="label">Agents</div><div class="val p counter" data-target="${a.length}">0</div></div>
  <div class="stat" role="listitem"><div class="label">Has Runner</div><div class="val c counter" data-target="${w}">0</div></div>
</div>
<div class="btn-row">
  <a href="#skills" class="btn primary">⚡ Browse Skills</a>
  <a href="#commands" class="btn primary">▶ Browse Commands</a>
  <a href="#terminal" class="btn">>_ Terminal</a>
</div>
<h3 style="color:var(--tx-3);margin-bottom:14px;font-size:.9rem">Recent Skills</h3>
<div class="grid-2">${s.slice(0,6).map((x,i)=>skillCard(x,i)).join('')}</div>`;
  },

  skills() {
    return `${breadcrumb(['Home','Skills'])}
<div class="page-header"><h1 tabindex="-1">Skills</h1><span class="sub">${DATA.skills.length} total</span></div>
<div class="search-wrap"><input class="search" placeholder="Search skills... (Ctrl+K)" id="q" role="search" aria-label="Search skills" oninput="window._f()"></div>
<div class="filters" id="flt" role="group" aria-label="Filter by category"></div>
<div class="grid" id="grd" role="list">${DATA.skills.map((x,i)=>skillCard(x,i)).join('')}</div>`;
  },

  'skills/:name'(name) {
    const s=DATA.skills.find(x=>x.name===name);
    if(!s) return '<div class="empty"><h3>Skill not found</h3></div>';
    return `${breadcrumb(['Home','Skills',s.name])}
<div class="detail"><div class="detail-head"><h2 tabindex="-1">${esc(s.name)}</h2><div class="meta">${s.hasRun?'<span class="tag green">HAS RUN.SH</span>':'<span class="tag orange">SKILL.MD ONLY</span>'}</div></div>
<div class="detail-body">${md(s.content)}</div></div>`;
  },

  cmds() {
    return `${breadcrumb(['Home','Commands'])}
<div class="page-header"><h1 tabindex="-1">Commands</h1><span class="sub">${DATA.commands.length} total</span></div>
<div class="search-wrap"><input class="search" placeholder="Search commands... (Ctrl+K)" id="q" role="search" aria-label="Search commands" oninput="window._f()"></div>
<div class="grid" id="grd" role="list">${DATA.commands.map((x,i)=>cmdCard(x,i)).join('')}</div>`;
  },

  'commands/:name'(name) {
    const c=DATA.commands.find(x=>x.name===name);
    if(!c) return '<div class="empty"><h3>Not found</h3></div>';
    return `${breadcrumb(['Home','Commands',c.name])}
<div class="detail"><div class="detail-head"><h2 tabindex="-1">/${esc(c.name)}</h2></div>
<div class="detail-body">${md(c.content)}</div></div>`;
  },

  agents() {
    return `${breadcrumb(['Home','Agents'])}
<div class="page-header"><h1 tabindex="-1">Agents</h1><span class="sub">${DATA.agents.length} total</span></div>
<div class="grid">${DATA.agents.map((a,i) => `<div class="card" data-agent="${esc(a.name)}" role="listitem" tabindex="0" style="animation-delay:${Math.min(i*.05,.4)}s"><div class="name">${esc(a.name)}</div><div class="desc">${esc(a.description)}</div></div>`).join('')}</div>`;
  },

  term() {
    return `${breadcrumb(['Home','Terminal'])}
<div class="page-header"><h1 tabindex="-1">Terminal</h1><span class="sub">agent-ai shell</span></div>
<div class="term" role="log" aria-label="Terminal output" aria-live="polite" id="trm" tabindex="0"></div>
<div class="term-bar"><span class="term-ps" aria-hidden="true">$</span><input id="tc" placeholder="Type 'help' and press Enter" autocomplete="off" autocapitalize="off" spellcheck="false" aria-label="Terminal input"><button class="btn primary" id="trun">RUN</button></div>
<div class="term-hint">Tab autocomplete &bull; &uarr;/&darr; history &bull; Ctrl+L clear</div>`;
  },

  mem() {
    if(!DATA.memory.length) return `<div class="page-header"><h1 tabindex="-1">Memory</h1></div><div class="empty"><h3>No memory files</h3></div>`;
    return `${breadcrumb(['Home','Memory'])}
<div class="page-header"><h1 tabindex="-1">Memory</h1><span class="sub">${DATA.memory.length} files</span></div>
<div class="grid">${DATA.memory.map((m,i) => `<a href="#memory/${m.name}" class="card" style="animation-delay:${Math.min(i*.05,.3)}s"><div class="name">${esc(m.name)}</div><div class="desc">${esc((m.content||'').substring(0,150))}</div></a>`).join('')}</div>`;
  },

  'memory/:file'(name) {
    const m=DATA.memory.find(x=>x.name===name);
    if(!m) return '<div class="empty"><h3>Not found</h3></div>';
    return `${breadcrumb(['Home','Memory',m.name])}
<div class="detail"><div class="detail-head"><h2 tabindex="-1">${esc(m.name)}</h2></div>
<div class="detail-body"><pre>${esc(m.content)}</pre></div></div>`;
  },

  cfg() {
    return `${breadcrumb(['Home','Config'])}
<div class="page-header"><h1 tabindex="-1">Config</h1><span class="sub">opencode.json</span></div>
<div class="detail"><div class="detail-head"><h2>opencode.json</h2></div>
<div class="detail-body"><pre id="cfg">Loading from GitHub...</pre></div></div>`;
  },

  tests() {
    const suites=['lint-kit','self-test','eval','e2e-flow','run-demo','test-update','mutation','bench'];
    return `${breadcrumb(['Home','Tests'])}
<div class="page-header"><h1 tabindex="-1">Tests</h1><span class="sub">${suites.length} suites</span></div>
<div class="detail"><div class="detail-head"><h2>Demo Mode</h2><span class="tag orange">SIMULATED</span></div>
<div class="detail-body"><p style="color:var(--tx-3);margin-bottom:0">Simulated results. Run <code>make verify</code> for real.</p></div></div>
<table class="tbl"><thead><tr><th>Suite</th><th>Status</th><th></th></tr></thead>
<tbody>${suites.map(s=>`<tr><td>${s}</td><td id="s-${s}">—</td><td><button class="btn sm" onclick="window._tr('${s}')">Demo</button></td></tr>`).join('')}</tbody></table>`;
  }
};

// ─── Actions ──────────────────────────────────────────────
document.addEventListener('click', e => {
  const card = e.target.closest('.card[data-agent]');
  if(card) { const name=card.dataset.agent; const a=DATA.agents.find(x=>x.name===name); if(a) renderAgent(a); }
});

function renderAgent(a) {
  $('#app').innerHTML = `${breadcrumb(['Home','Agents',a.name])}
<a href="#agents" class="back">← Back to Agents</a>
<div class="detail"><div class="detail-head"><h2 tabindex="-1">${esc(a.name)}</h2></div>
<div class="detail-body">${md(a.content)}</div></div>`;
  const h=$('#app h2'); if(h) h.focus();
}

window._tr = function(suite) {
  const list = suite==='all' ? ['lint-kit','self-test','eval','e2e-flow','run-demo','test-update','mutation','bench'] : [suite];
  activeTimers.forEach(id=>clearTimeout(id)); activeTimers=[];
  list.forEach(s => {
    const el=$(`#s-${s}`); if(!el) return;
    el.innerHTML='<span class="spin"></span>';
    const id=setTimeout(()=>{el.innerHTML='<span style="color:var(--green)">✓ PASS</span>';},800+Math.random()*1500);
    activeTimers.push(id);
  });
  toast('Running ' + list.length + ' test(s)...', 'info');
};

window._f = function() {
  clearTimeout(searchTimer);
  searchTimer=setTimeout(()=>{
    const q=($('#q')?.value||'').toLowerCase();
    $$('#grd .card').forEach(card=>{
      const name=(card.dataset.name||card.querySelector('.name')?.textContent||'').toLowerCase();
      const desc=(card.dataset.desc||card.querySelector('.desc')?.textContent||'').toLowerCase();
      card.style.display=(name.includes(q)||desc.includes(q))?'':'none';
    });
  },150);
};

// ─── Keyboard shortcuts ───────────────────────────────────
document.addEventListener('keydown', e => {
  // Ctrl+K or / — search
  if((e.ctrlKey&&e.key==='k')||(e.key==='/'&&!['INPUT','TEXTAREA'].includes(e.target.tagName))){
    e.preventDefault();
    const q=$('#q');
    if(q){q.focus();q.select();}
    else{location.hash='#skills';setTimeout(()=>{const q2=$('#q');if(q2)q2.focus();},100);}
  }
  // Escape
  if(e.key==='Escape'){
    if($('#shortcutsModal').classList.contains('open')){closeShortcuts();return;}
    const sb=$('#sidebar');
    if(sb.classList.contains('open')){closeSidebar();return;}
    const{page}=getRoute();
    if(page!=='dash')location.hash='#';
  }
  // ? — shortcuts
  if(e.key==='?'&&!['INPUT','TEXTAREA'].includes(e.target.tagName)){
    e.preventDefault();
    $('#shortcutsModal').classList.toggle('open');
  }
  // T — theme
  if(e.key==='t'&&!['INPUT','TEXTAREA'].includes(e.target.tagName)){
    e.preventDefault();
    window.toggleTheme();
  }
  // 1-8 — pages
  if(!['INPUT','TEXTAREA'].includes(e.target.tagName)){
    const pages=['dash','skills','cmds','agents','term','mem','cfg','tests'];
    const idx=parseInt(e.key)-1;
    if(idx>=0&&idx<pages.length){
      const R={dash:'',skills:'skills',cmds:'commands',agents:'agents',term:'terminal',mem:'memory',cfg:'config',tests:'tests'};
      location.hash='#'+R[pages[idx]];
    }
  }
});

// ─── Terminal ─────────────────────────────────────────────
let termHist = [];
let termHistIdx = -1;

const TERM_ALL = ['help','status','skills','skill','commands','command','agents','agent','memory','cat','theme','clear','about','neofetch','date','echo'];

const TERM_HELP = {
  help: 'list all commands, or detail for one: help <cmd>',
  status: 'show kit status (version, counts)',
  skills: 'list all skills',
  skill: 'show skill detail: skill <name>',
  commands: 'list all commands',
  command: 'show command detail: command <name>',
  agents: 'list all agents',
  agent: 'show agent detail: agent <name>',
  memory: 'list memory files',
  cat: 'show memory file content: cat <file>',
  theme: 'toggle theme, or set it: theme [dark|light]',
  clear: "clear terminal (also Ctrl+L)",
  about: 'about agent-ai',
  neofetch: 'system info display',
  date: 'current date/time',
  echo: 'echo text: echo <text>'
};

const TERM_BANNER = [
' █████╗  ██████╗ ███████╗███╗   ██╗████████╗         █████╗ ██╗',
'██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝        ██╔══██╗██║',
'███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║           ███████║██║',
'██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║           ██╔══██║██║',
'██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║           ██║  ██║██║',
'╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝           ╚═╝  ╚═╝╚═╝'
].join('\n');

function termEnsureStyle() {
  if (document.getElementById('termExtra')) return;
  const st = document.createElement('style');
  st.id = 'termExtra';
  st.textContent = '.term-ps{color:var(--green);font-family:var(--font-mono);font-weight:700}'
    + '.term-hint{color:var(--tx-3);font-size:.75rem;margin-top:10px}'
    + '.term .ok{color:#00ff9f}.term .cy{color:#00e5ff}.term .yl{color:#ffcf4d}'
    + '.term-art{color:#00ff9f;margin:0;font-size:.68rem;line-height:1.35;overflow-x:auto}'
    + '.term pre{white-space:pre-wrap;word-break:break-word;margin:4px 0}'
    + '.term a{color:#00e5ff}';
  document.head.appendChild(st);
}

function termScroll() {
  const box = $('#trm');
  if (box) box.scrollTop = box.scrollHeight;
}

function termPrint(html, cls) {
  const box = $('#trm');
  if (!box) return;
  const d = document.createElement('div');
  d.className = 'ln ' + (cls || 'out');
  d.innerHTML = html;
  box.appendChild(d);
}

function termFind(list, name) {
  const n = (name || '').toLowerCase();
  return list.find(x => (x.name || '').toLowerCase() === n);
}

function termPreview(content, link) {
  const t = (content || '').trim();
  if (!t) return;
  const cut = t.length > 1200;
  termPrint('<pre>' + esc(cut ? t.slice(0, 1200) : t) + '</pre>', 'out');
  if (cut) termPrint('... (' + t.length + ' chars — full: <a href="#' + link + '">' + esc(link) + '</a>)', 'yl');
}

function tHelp(arg) {
  const a = (arg || '').toLowerCase();
  if (!a) {
    termPrint('Available commands:', 'yl');
    TERM_ALL.forEach(c => termPrint('<span class="cy">' + c + '</span> — ' + esc(TERM_HELP[c]), 'out'));
    return;
  }
  if (TERM_HELP[a]) termPrint('<span class="cy">' + esc(a) + '</span> — ' + esc(TERM_HELP[a]), 'out');
  else termPrint("no help for '" + esc(a) + "'. Type 'help'.", 'err');
}

function tStatus() {
  const rows = [
    ['version', DATA.version],
    ['skills', DATA.skills.length],
    ['commands', DATA.commands.length],
    ['agents', DATA.agents.length],
    ['memory files', DATA.memory.length],
    ['skills with runner', DATA.skills.filter(s => s.hasRun).length],
    ['theme', getTheme()]
  ];
  termPrint('AGENT-AI status:', 'yl');
  rows.forEach(r => termPrint('<span class="cy">' + esc(r[0]) + '</span>: ' + esc(String(r[1])), 'out'));
}

function tSkills() {
  termPrint(DATA.skills.length + ' skills:', 'yl');
  DATA.skills.forEach(s => termPrint('<span class="cy">' + esc(s.name) + '</span> <span class="tag ' + (s.hasRun ? 'green' : 'orange') + '">' + (s.hasRun ? 'RUN' : 'MD') + '</span> ' + esc((s.description || '').slice(0, 80)), 'out'));
}

function tSkill(arg) {
  if (!arg) { termPrint('usage: skill <name>', 'err'); return; }
  const s = termFind(DATA.skills, arg);
  if (!s) { termPrint("skill not found: '" + esc(arg) + "'", 'err'); return; }
  termPrint('<span class="cy">skill: ' + esc(s.name) + '</span> ' + (s.hasRun ? '[has run.sh]' : '[skill.md only]'), 'yl');
  if (s.description) termPrint(esc(s.description), 'out');
  termPreview(s.content, 'skills/' + s.name);
}

function tCmds() {
  termPrint(DATA.commands.length + ' commands:', 'yl');
  DATA.commands.forEach(c => termPrint('<span class="cy">/' + esc(c.name) + '</span> ' + esc((c.description || '').slice(0, 80)), 'out'));
}

function tCmd(arg) {
  if (!arg) { termPrint('usage: command <name>', 'err'); return; }
  const c = termFind(DATA.commands, arg.replace(/^\//, ''));
  if (!c) { termPrint("command not found: '" + esc(arg) + "'", 'err'); return; }
  termPrint('<span class="cy">command: /' + esc(c.name) + '</span>', 'yl');
  if (c.description) termPrint(esc(c.description), 'out');
  termPreview(c.content, 'commands/' + c.name);
}

function tAgents() {
  termPrint(DATA.agents.length + ' agents:', 'yl');
  DATA.agents.forEach(a => termPrint('<span class="cy">' + esc(a.name) + '</span> ' + esc((a.description || '').slice(0, 80)), 'out'));
}

function tAgent(arg) {
  if (!arg) { termPrint('usage: agent <name>', 'err'); return; }
  const a = termFind(DATA.agents, arg);
  if (!a) { termPrint("agent not found: '" + esc(arg) + "'", 'err'); return; }
  termPrint('<span class="cy">agent: ' + esc(a.name) + '</span>', 'yl');
  if (a.description) termPrint(esc(a.description), 'out');
  termPreview(a.content, 'agents');
}

function tMem() {
  if (!DATA.memory.length) { termPrint('No memory files.', 'out'); return; }
  termPrint(DATA.memory.length + ' memory files — use: cat <file>', 'yl');
  DATA.memory.forEach(m => termPrint('<span class="cy">' + esc(m.name) + '</span> (' + (m.content || '').length + ' chars)', 'out'));
}

function tCat(arg) {
  if (!arg) { termPrint('usage: cat <file>', 'err'); return; }
  const m = termFind(DATA.memory, arg);
  if (!m) { termPrint("file not found: '" + esc(arg) + "'. Files: " + DATA.memory.map(x => esc(x.name)).join(', '), 'err'); return; }
  termPrint('<span class="cy">' + esc(m.name) + '</span>', 'yl');
  termPrint('<pre>' + esc(m.content || '(empty)') + '</pre>', 'out');
}

function tTheme(arg) {
  const a = (arg || '').toLowerCase();
  if (a === 'dark' || a === 'light') setTheme(a);
  else window.toggleTheme();
  termPrint('theme: ' + esc(getTheme()), 'ok');
}

function tClear() {
  const box = $('#trm');
  if (box) box.innerHTML = '';
}

function tAbout() {
  termPrint('AGENT-AI — DEV-BRAIN Kit Dashboard', 'yl');
  termPrint('Browse skills, commands, agents and kit memory in your browser. Live data from data.json, in-terminal shell on the Terminal page.', 'out');
  termPrint('v' + esc(DATA.version) + ' — type \'help\' to begin.', 'cy');
}

function tNeo() {
  termPrint('<pre class="term-art">   ▲\n  ▲▲▲\n ▲▲▲▲▲\n▲▲▲▲▲▲▲</pre>', 'ok');
  const rows = [
    ['agent-ai', 'v' + DATA.version],
    ['skills', DATA.skills.length + ' (' + DATA.skills.filter(s => s.hasRun).length + ' with runner)'],
    ['commands', DATA.commands.length],
    ['agents', DATA.agents.length],
    ['memory', DATA.memory.length + ' files'],
    ['theme', getTheme()],
    ['platform', (navigator && navigator.platform) || 'web'],
    ['date', new Date().toLocaleString()]
  ];
  rows.forEach(r => termPrint('<span class="cy">' + esc(r[0]) + '</span>: ' + esc(String(r[1])), 'out'));
}

function tDate() {
  termPrint(esc(new Date().toString()), 'cy');
}

function tEcho(arg) {
  termPrint(esc(arg), 'out');
}

const TERM_FN = { help: tHelp, status: tStatus, skills: tSkills, skill: tSkill, commands: tCmds, command: tCmd, agents: tAgents, agent: tAgent, memory: tMem, cat: tCat, theme: tTheme, clear: tClear, about: tAbout, neofetch: tNeo, date: tDate, echo: tEcho };

function termExec(raw) {
  if (!DATA) { termPrint('Data not loaded yet.', 'err'); return; }
  termPrint('$ ' + esc(raw), 'pr');
  const line = (raw || '').trim();
  if (!line) { termScroll(); return; }
  const sp = line.indexOf(' ');
  const cmd = (sp < 0 ? line : line.slice(0, sp)).toLowerCase();
  const arg = sp < 0 ? '' : line.slice(sp + 1).trim();
  const fn = TERM_FN[cmd];
  if (fn) fn(arg);
  else {
    const sug = TERM_ALL.filter(c => c.indexOf(cmd) === 0);
    termPrint("command not found: '" + esc(cmd) + "'. Type 'help'." + (sug.length ? ' Did you mean: ' + sug.map(s => esc(s)).join(', ') + '?' : ''), 'err');
  }
  termScroll();
}

function termComplete(val) {
  const m = val.match(/^(.*\s)?(\S*)$/);
  const head = (val.trim().split(/\s+/)[0] || '').toLowerCase();
  const frag = ((m && m[2]) || '').toLowerCase();
  const prefix = (m && m[1]) || '';
  let pool = null;
  if (!prefix) pool = TERM_ALL;
  else if (head === 'skill') pool = DATA.skills.map(s => s.name);
  else if (head === 'command') pool = DATA.commands.map(c => c.name);
  else if (head === 'agent') pool = DATA.agents.map(a => a.name);
  else if (head === 'cat') pool = DATA.memory.map(x => x.name);
  else if (head === 'help') pool = TERM_ALL;
  else return val;
  const hit = pool.filter(n => n.toLowerCase().indexOf(frag) === 0);
  if (hit.length === 1) return prefix + hit[0] + ' ';
  if (hit.length > 1) termPrint(hit.map(s => esc(s)).join('   '), 'cy');
  return val;
}

function initTerm() {
  termEnsureStyle();
  const box = $('#trm'), input = $('#tc');
  if (!box || !input || box.dataset.live) return;
  box.dataset.live = '1';
  termPrint('<pre class="term-art">' + TERM_BANNER + '</pre>', 'ok');
  termPrint('AGENT-AI v' + esc(DATA.version) + ' — ' + DATA.skills.length + ' skills, ' + DATA.commands.length + ' commands, ' + DATA.agents.length + ' agents. Type \'help\'.', 'out');
  termScroll();
  const run = () => {
    const v = input.value;
    input.value = '';
    if (v.trim()) { termHist.push(v); termHistIdx = termHist.length; }
    termExec(v);
    input.focus();
  };
  const btn = $('#trun');
  if (btn) btn.onclick = run;
  input.addEventListener('keydown', e => {
    if ((e.ctrlKey && (e.key === 'k' || e.key === 'K')) || e.key === 'Escape') e.stopPropagation();
    if (e.key === 'Enter') run();
    else if (e.key === 'ArrowUp') { e.preventDefault(); if (termHist.length && termHistIdx > 0) { termHistIdx--; input.value = termHist[termHistIdx]; } }
    else if (e.key === 'ArrowDown') { e.preventDefault(); if (termHistIdx < termHist.length - 1) { termHistIdx++; input.value = termHist[termHistIdx]; } else { termHistIdx = termHist.length; input.value = ''; } }
    else if (e.key === 'Tab') { e.preventDefault(); input.value = termComplete(input.value); }
    else if (e.key === 'l' && e.ctrlKey) { e.preventDefault(); tClear(); }
  });
  box.onclick = () => input.focus();
  setTimeout(() => input.focus(), 50);
}

// ─── Render ───────────────────────────────────────────────
function render() {
  const{page,param}=getRoute();
  buildNav(page);
  let html='';
  if(param&&P[page+'/:name'])html=P[page+'/name'](param);
  else if(P[page])html=P[page]();
  else html=P.dash();
  $('#app').innerHTML=html;
  $('#app').scrollTop=0;
  closeSidebar();
  const h1=$('#app h1'); if(h1)setTimeout(()=>h1.focus(),50);
  const titles={dash:'Dashboard',skills:'Skills',cmds:'Commands',agents:'Agents',term:'Terminal',mem:'Memory',cfg:'Config',tests:'Tests'};
  document.title=(titles[page]||'Dashboard')+' — AGENT-AI';

  // Animate counters
  $$('.counter[data-target]').forEach(el => { animateCounter(el, parseInt(el.dataset.target)); });

  // Terminal
  if (page === 'term') initTerm();

  // Config
  if(page==='cfg'){
    const ctrl=new AbortController();
    const timer=setTimeout(()=>ctrl.abort(),10000);
    fetch('https://raw.githubusercontent.com/nemoobc/agent-ai/main/opencode.json',{signal:ctrl.signal})
      .then(r=>{clearTimeout(timer);if(!r.ok)throw new Error('HTTP '+r.status);return r.json();})
      .then(d=>{const e=$('#cfg');if(e)e.textContent=JSON.stringify(d,null,2);})
      .catch(e=>{const el=$('#cfg');if(el)el.textContent='Failed: '+esc(e.message);});
  }

  // Skills filters
  if(page==='skills'){
    const cats={
      pipeline:/^(think|plan|test-|audit|fix|debug|doc-|doctor|review|refactor|perf|explain|changelog|spec|imagine)/,
      security:/^(git-guard|injection|env-guard|red-team|threat|audit)/,
      memory:/^(recall|remember|learn|profile|context|handoff)/,
      ops:/^(backup|clean|deliver|monitor|notify|hotfix|recovery)/,
      analysis:/^(scan|metrics|eval|critique|research|coverage)/,
      meta:/^(route|caveman|budget|estimate|milestone|team|autonomy|auto-)/
    };
    const flt=$('#flt');
    if(flt){
      flt.innerHTML=`<button class="fbtn on" data-c="all" aria-pressed="true">All</button>`+Object.keys(cats).map(k=>`<button class="fbtn" data-c="${k}" aria-pressed="false">${k.charAt(0).toUpperCase()+k.slice(1)}</button>`).join('');
      flt.querySelectorAll('.fbtn').forEach(btn=>{
        btn.onclick=()=>{
          flt.querySelectorAll('.fbtn').forEach(b=>{b.classList.remove('on');b.setAttribute('aria-pressed','false');});
          btn.classList.add('on');btn.setAttribute('aria-pressed','true');
          const cat=btn.dataset.c;
          const q=($('#q')?.value||'').toLowerCase();
          $$('#grd .card').forEach(card=>{
            const name=(card.dataset.name||'').toLowerCase();
            const desc=(card.dataset.desc||'').toLowerCase();
            card.style.display=((cat==='all'||cats[cat]?.test(name))&&(name.includes(q)||desc.includes(q)))?'':'none';
          });
        };
      });
    }
  }
}

// ─── Particles ────────────────────────────────────────────
function initParticles() {
  const container = document.createElement('div');
  container.className = 'particles';
  document.body.appendChild(container);
  const colors = ['#ff69b4', '#bf40ff', '#00ffff', '#00ff9f', '#ffaa00'];
  for (let i = 0; i < 30; i++) {
    const p = document.createElement('div');
    p.className = 'particle';
    p.style.left = Math.random() * 100 + '%';
    p.style.setProperty('--dur', (8 + Math.random() * 12) + 's');
    p.style.setProperty('--delay', (Math.random() * 10) + 's');
    p.style.width = p.style.height = (2 + Math.random() * 4) + 'px';
    const c = colors[Math.floor(Math.random() * colors.length)];
    p.style.background = c;
    p.style.boxShadow = `0 0 ${4 + Math.random() * 8}px ${c}`;
    container.appendChild(p);
  }
}

// ─── Init ─────────────────────────────────────────────────
$('#app').innerHTML=`<div class="empty" style="margin-top:100px"><div class="spin" style="margin-bottom:16px"></div><h3>Loading...</h3></div>`;

fetch('data.json',{cache:'force-cache'})
  .then(r=>{if(!r.ok)throw new Error('HTTP '+r.status);return r.json();})
  .then(d=>{
    if(!d.skills||!d.commands)throw new Error('Invalid data');
    DATA=d;
    $('#ver').textContent='v'+d.version;
    showWelcome();
    render();
    initBackTop();
    initParticles();
  })
  .catch(e=>{
    $('#app').innerHTML=`<div class="empty" style="margin-top:100px"><h3>Failed to load data</h3><p>${esc(e.message)}</p><button class="btn primary" onclick="location.reload()">Retry</button></div>`;
  });

})();
