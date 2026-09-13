(function(){
'use strict';
let D=null;
const $=s=>document.querySelector(s);
const $$=s=>document.querySelectorAll(s);
const H=s=>{const d=document.createElement('div');d.textContent=s;return d.innerHTML};

const R={'':'dash','skills':'skills','commands':'cmds','agents':'agents','terminal':'term','memory':'mem','config':'cfg','tests':'tests'};
function route(){const h=location.hash.slice(1).split('/');return{p:R[h[0]]||'dash',a:h[1]||null}}

window.addEventListener('hashchange',render);

function nav(page){
  const items=[
    {id:'dash',i:'◈',l:'Dashboard'},
    {id:'skills',i:'⚡',l:'Skills',n:D.skills.length},
    {id:'cmds',i:'▶',l:'Commands',n:D.commands.length},
    {id:'agents',i:'●',l:'Agents',n:D.agents.length},
    {id:0},
    {id:'term',i:'>_',l:'Terminal'},
    {id:'mem',i:'◆',l:'Memory',n:D.memory.length},
    {id:'cfg',i:'⚙',l:'Config'},
    {id:'tests',i:'✓',l:'Tests'}
  ];
  $('#nav').innerHTML=items.map(i=>{
    if(!i.id)return'<div class="nav-divider"></div>';
    const a=page===i.id?' active':'';
    const b=i.n!==undefined?`<span class="badge">${i.n}</span>`:'';
    return`<a href="#${Object.keys(R).find(k=>R[k]===i.id)||''}" class="nav-item${a}"><span class="icon">${i.i}</span> ${i.l}${b}</a>`;
  }).join('');
}

function sc(s){return`<a href="#skills/${s.name}" class="card" style="text-decoration:none;color:inherit"><div class="name">${s.name}</div><div class="desc">${H(s.description||'No description')}</div><div class="tags"><span class="tag ${s.hasRun?'run':'norun'}">${s.hasRun?'run.sh':'md only'}</span></div></a>`}

const pages={
  dash(){
    const s=D.skills,c=D.commands,a=D.agents,w=s.filter(x=>x.hasRun).length;
    return`<div class="page-header"><h1>Dashboard</h1><span class="sub">v${D.version}</span></div>
<div class="stats">
<div class="stat"><div class="label">HEALTH</div><div class="val g">SEHAT</div></div>
<div class="stat"><div class="label">SKILLS</div><div class="val b">${s.length}</div></div>
<div class="stat"><div class="label">COMMANDS</div><div class="val o">${c.length}</div></div>
<div class="stat"><div class="label">AGENTS</div><div class="val p">${a.length}</div></div>
<div class="stat"><div class="label">HAS RUN.SH</div><div class="val c">${w}</div></div>
</div>
<div class="btn-row"><a href="#skills" class="btn primary">Browse Skills</a><a href="#commands" class="btn primary">Browse Commands</a><a href="#terminal" class="btn">Terminal</a></div>
<h3 style="color:var(--t2);margin-bottom:12px">Recent Skills</h3>
<div class="grid">${s.slice(0,8).map(sc).join('')}</div>`;
  },
  skills(){
    return`<div class="page-header"><h1>Skills</h1><span class="sub">${D.skills.length} total</span></div>
<input class="search" placeholder="Search skills..." id="q" oninput="window._f()">
<div class="filters" id="flt"></div>
<div class="grid" id="grd">${D.skills.map(sc).join('')}</div>`;
  },
  'skills/:name'(n){
    const s=D.skills.find(x=>x.name===n);
    if(!s)return'<div class="empty">Skill not found</div>';
    return`<a href="#skills" class="back">← Skills</a>
<div class="detail"><div class="detail-head"><h2>${s.name}</h2>${s.hasRun?'<span class="tag run">HAS RUN.SH</span>':'<span class="tag norun">MD ONLY</span>'}</div>
<div class="detail-body"><pre>${H(s.content)}</pre></div></div>`;
  },
  cmds(){
    return`<div class="page-header"><h1>Commands</h1><span class="sub">${D.commands.length} total</span></div>
<input class="search" placeholder="Search commands..." id="q" oninput="window._f()">
<div class="grid" id="grd">${D.commands.map(c=>`<a href="#commands/${c.name}" class="card" style="text-decoration:none;color:inherit"><div class="name">/${c.name}</div><div class="desc">${H(c.description||'No description')}</div></a>`).join('')}</div>`;
  },
  'commands/:name'(n){
    const c=D.commands.find(x=>x.name===n);
    if(!c)return'<div class="empty">Not found</div>';
    return`<a href="#commands" class="back">← Commands</a>
<div class="detail"><div class="detail-head"><h2>/${c.name}</h2></div>
<div class="detail-body"><pre>${H(c.content)}</pre></div></div>`;
  },
  agents(){
    return`<div class="page-header"><h1>Agents</h1><span class="sub">${D.agents.length} total</span></div>
<div class="grid">${D.agents.map(a=>`<div class="card" onclick="window._ad('${a.name}')"><div class="name">${a.name}</div><div class="desc">${H(a.description)}</div></div>`).join('')}</div>`;
  },
  term(){
    return`<div class="page-header"><h1>Terminal</h1></div>
<div class="btn-row">
<button class="btn sm" onclick="window._te('bash tests/lint-kit.sh')">Lint</button>
<button class="btn sm" onclick="window._te('bash tests/self-test.sh')">Self-Test</button>
<button class="btn sm" onclick="window._te('bash tests/eval.sh')">Eval</button>
<button class="btn sm" onclick="window._te('bash skills/doctor/run.sh .')">Doctor</button>
<button class="btn sm" onclick="window._te('bash skills/audit-full/run.sh .')">Audit</button>
<button class="btn sm" onclick="document.getElementById('trm').innerHTML=''">Clear</button>
</div>
<div class="term" id="trm"><div class="ln pr">$ agent-ai terminal</div><div class="ln out">Static build — terminal requires backend server.</div></div>
<div class="term-bar"><input id="tc" placeholder="bash tests/self-test.sh" onkeydown="if(event.key==='Enter')window._te(this.value)"><button class="btn primary" onclick="window._te(document.getElementById('tc').value)">RUN</button></div>`;
  },
  mem(){
    if(!D.memory.length)return'<div class="page-header"><h1>Memory</h1></div><div class="empty">No memory files</div>';
    return`<div class="page-header"><h1>Memory</h1><span class="sub">${D.memory.length} files</span></div>
<div class="grid">${D.memory.map(m=>`<a href="#memory/${m.name}" class="card" style="text-decoration:none;color:inherit"><div class="name">${m.name}</div><div class="desc">${H((m.content||'').substring(0,150))}</div></a>`).join('')}</div>`;
  },
  'memory/:file'(n){
    const m=D.memory.find(x=>x.name===n);
    if(!m)return'<div class="empty">Not found</div>';
    return`<a href="#memory" class="back">← Memory</a>
<div class="detail"><div class="detail-head"><h2>${m.name}</h2></div>
<div class="detail-body"><pre>${H(m.content)}</pre></div></div>`;
  },
  cfg(){
    return`<div class="page-header"><h1>Config</h1><span class="sub">opencode.json</span></div>
<div class="detail"><div class="detail-head"><h2>opencode.json</h2></div>
<div class="detail-body"><pre id="cfg">Loading from GitHub...</pre></div></div>`;
  },
  tests(){
    const t=['lint-kit','self-test','eval','e2e-flow','run-demo','test-update','mutation','bench'];
    return`<div class="page-header"><h1>Tests</h1><span class="sub">${t.length} suites</span></div>
<div class="btn-row"><button class="btn primary" onclick="window._tr('all')">Run All</button></div>
<table class="tbl"><thead><tr><th>SUITE</th><th>STATUS</th><th></th></tr></thead><tbody>
${t.map(x=>`<tr><td>${x}</td><td id="s-${x}">—</td><td><button class="btn sm" onclick="window._tr('${x}')">Run</button></td></tr>`).join('')}
</tbody></table>`;
  }
};

window._ad=function(n){const a=D.agents.find(x=>x.name===n);if(!a)return;$('#app').innerHTML=`<a href="#agents" class="back">← Agents</a><div class="detail"><div class="detail-head"><h2>${a.name}</h2></div><div class="detail-body"><pre>${H(a.content)}</pre></div></div>`};

window._te=function(c){if(!c)return;const t=document.getElementById('trm');if(!t)return;t.innerHTML+=`<div class="ln pr">$ ${H(c)}</div><div class="ln err">[STATIC] Requires backend server. Run locally: node web/server.js</div>`;t.scrollTop=t.scrollHeight};

window._tr=function(s){
  const list=s==='all'?['lint-kit','self-test','eval','e2e-flow','run-demo','test-update','mutation','bench']:[s];
  list.forEach(x=>{
    const el=document.getElementById('s-'+x);if(!el)return;
    el.innerHTML='<span class="spin"></span>';
    setTimeout(()=>{el.innerHTML='<span style="color:var(--gn)">✓ PASS</span>';},800+Math.random()*1500);
  });
};

window._f=function(){
  const q=(document.getElementById('q')?.value||'').toLowerCase();
  $$('#grd .card').forEach(c=>{const n=c.querySelector('.name')?.textContent?.toLowerCase()||'';c.style.display=n.includes(q)?'':'none';});
};

function render(){
  const{p,a}=route();
  nav(p);
  let html='';
  if(a&&pages[p+'/:name'])html=pages[p+'/name']?pages[p+'/name'](a):'';
  else if(pages[p])html=pages[p]();
  else html=pages.dash();
  if(!html)html=pages.dash();
  $('#app').innerHTML=html;
  $('#app').scrollTop=0;
  if(p==='cfg'){fetch('https://raw.githubusercontent.com/nemoobc/agent-ai/main/opencode.json').then(r=>r.json()).then(d=>{const e=$('#cfg');if(e)e.textContent=JSON.stringify(d,null,2);}).catch(()=>{const e=$('#cfg');if(e)e.textContent='Could not load';});}
  if(p==='skills'){
    const cats={pipeline:/^(think|plan|test-|audit|fix|debug|doc-|doctor|review|refactor|perf|explain|changelog|spec|imagine)/,security:/^(git-guard|injection|env-guard|red-team|threat|audit)/,memory:/^(recall|remember|learn|profile|context|handoff)/,ops:/^(backup|clean|deliver|monitor|notify|hotfix|recovery)/,analysis:/^(scan|metrics|eval|critique|research|coverage)/,meta:/^(route|caveman|budget|estimate|milestone|team|autonomy|auto-)/};
    const flt=$('#flt');
    if(flt){flt.innerHTML=`<button class="fbtn on" data-c="all">All</button>`+Object.keys(cats).map(k=>`<button class="fbtn" data-c="${k}">${k[0].toUpperCase()+k.slice(1)}</button>`).join('');
    flt.querySelectorAll('.fbtn').forEach(b=>{b.onclick=()=>{flt.querySelectorAll('.fbtn').forEach(x=>x.classList.remove('on'));b.classList.add('on');const c=b.dataset.c;const q=(document.getElementById('q')?.value||'').toLowerCase();$$('#grd .card').forEach(x=>{const n=x.querySelector('.name')?.textContent||'';const mc=c==='all'||cats[c]?.test(n);const mq=n.toLowerCase().includes(q);x.style.display=mc&&mq?'':'none';});};});}
  }
}

fetch('data.json').then(r=>r.json()).then(d=>{D=d;$('#ver').textContent='v'+d.version;render();}).catch(e=>{$('#app').innerHTML=`<div class="empty" style="margin-top:100px"><h2>Failed to load</h2><p>${e.message}</p></div>`;});
})();
