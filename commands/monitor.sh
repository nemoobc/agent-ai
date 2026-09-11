#!/usr/bin/env bash
# monitor — run skill monitor
# Usage: bash commands/monitor.sh [args]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ MONITOR ═══" 213
if [ -f "$DIR/skills/monitor/run.sh" ]; then
  bash "$DIR/skills/monitor/run.sh" "$@"
  EXIT=$?
  [ "$EXIT" -eq 0 ] && ok "monitor clean" || bad "monitor exit $EXIT"
  exit $EXIT
else
  bad "skills/monitor/run.sh not found"
  exit 1
fi
