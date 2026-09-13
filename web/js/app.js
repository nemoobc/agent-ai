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
  o.innerHTML = `<div class="welcome"><div class="welcome-icon">◈</div><h1>AGENT-AI</h1><p class="welcome-sub">DEV-BRAIN Kit Dashboard</p><div class="welcome-stats"><div class="ws"><span class="ws-val" id="wv1">0</span><span class="ws-label">Skills</span></div><div class="ws"><span class="ws-val" id="wv2">0</span><span class="ws-label">Commands</span></div><div class="ws"><span class="ws-val" id="wv3">0</span><span class="ws-label">Agents</span></div></div><p class="welcome-desc">Browse skills, commands, agents, and explore the DEV-BRAIN kit.</p><button class="welcome-btn" id="welcomeBtn">Get Started</button><div class="welcome-footer">v<span id="wv"></span> • Built with ♥</div></div>`;
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
<div class="page-header"><h1 tabindex="-1">Terminal</h1></div>
<div class="term-notice">⚠ Static build — terminal requires backend. <code>cd web && npm start</code></div>
<div class="btn-row"><button class="btn sm" disabled>Lint</button><button class="btn sm" disabled>Self-Test</button><button class="btn sm" disabled>Eval</button><button class="btn sm" disabled>Doctor</button><button class="btn sm" disabled>Audit</button></div>
<div class="term" role="log" id="trm"><div class="ln pr">$ agent-ai terminal</div><div class="ln out">Read-only mode. Deploy with Node.js for live execution.</div></div>
<div class="term-bar"><input id="tc" placeholder="Disabled in static mode" disabled><button class="btn primary" disabled>RUN</button></div>`;
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
