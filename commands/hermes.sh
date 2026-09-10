#!/usr/bin/env bash
# hermes — run hermes multi-domain task
# Usage: bash commands/hermes.sh "task description"
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

TASK="${1:-}"
if [ -z "$TASK" ]; then
  p "Usage: bash commands/hermes.sh \"task description\"" 214
  p "" 0
  p "HERMES domains:" 213
  p "  INFRA     : setup env, config, container, tooling" 248
  p "  INTEGRASI : wiring API/service luar" 248
  p "  OPERASI   : deploy, backup, restore, cleanup" 248
  p "  DOKUMEN   : README ops, runbook, changelog" 248
  p "  RISET     : versi, kompatibilitas, harga" 248
  p "  DATA      : migrasi, fixture, seed, dump" 248
  exit 0
fi

p "═══ HERMES ═══" 213
p "TASK: $TASK" 248

# Check hermes agent
if [ -f "$DIR/agents/hermes.md" ]; then
  p "▶ Hermes agent loaded" 82
fi

# Route the task
if [ -f "$DIR/skills/route/run.sh" ]; then
  JALUR=$(bash "$DIR/skills/route/run.sh" "$TASK" 2>&1 | grep "JALUR:" | awk '{print $2}')
  p "Route: $JALUR" 213
fi

p "" 0
p "HERMES MODE: kamu utusan, bukan master satu bidang." 213
p "Jalankan command nyata, baca output nyata, lapor exit code nyata." 248
p "\"Harusnya jalan\" = belum jalan." 214
