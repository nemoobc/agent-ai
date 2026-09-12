// build.js — generate data.json from kit
const fs = require('fs');
const path = require('path');
const KIT = path.join(__dirname, '..');

function read(f) { try { return fs.readFileSync(path.join(KIT, f), 'utf8'); } catch { return null; } }

const version = (read('VERSION') || '0.0.0').trim();

const skills = fs.readdirSync(path.join(KIT, 'skills')).filter(f => fs.existsSync(path.join(KIT, 'skills', f, 'SKILL.md'))).map(name => {
  const md = read('skills/' + name + '/SKILL.md') || '';
  const m = md.match(/^---[\s\S]*?description:\s*(.+)\n/m);
  const hasRun = fs.existsSync(path.join(KIT, 'skills', name, 'run.sh'));
  return { name, description: m ? m[1].trim() : '', hasRun, content: md };
});

const commands = fs.readdirSync(path.join(KIT, 'command')).filter(f => f.endsWith('.md')).map(f => {
  const name = f.replace('.md', '');
  const md = read('command/' + f) || '';
  const m = md.match(/^---[\s\S]*?description:\s*(.+)\n/m);
  return { name, description: m ? m[1].split('—')[0].trim() : '', content: md };
});

const agents = fs.readdirSync(path.join(KIT, 'agents')).filter(f => f.endsWith('.md')).map(f => {
  const name = f.replace('.md', '');
  const md = read('agents/' + f) || '';
  const line = md.split('\n').find(l => l && !l.startsWith('#') && !l.startsWith('---'));
  return { name, description: line ? line.substring(0, 120) : '', content: md };
});

const memDir = path.join(KIT, 'memory');
const memory = fs.existsSync(memDir) ? fs.readdirSync(memDir).filter(f => f.endsWith('.md')).map(f => ({
  name: f, content: read('memory/' + f) || ''
})) : [];

const data = { version, skills, commands, agents, memory };
fs.writeFileSync(path.join(__dirname, 'data.json'), JSON.stringify(data));
console.log('Built: data.json (' + (Buffer.byteLength(JSON.stringify(data)) / 1024).toFixed(0) + 'KB)');
console.log(`  ${skills.length} skills, ${commands.length} commands, ${agents.length} agents, ${memory.length} memory`);
