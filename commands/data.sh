#!/usr/bin/env bash
# data — run skill data
# Usage: bash commands/data.sh [args]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ DATA ═══" 213
if [ -f "$DIR/skills/data/run.sh" ]; then
  bash "$DIR/skills/data/run.sh" "$@"
  EXIT=$?
  [ "$EXIT" -eq 0 ] && ok "data clean" || bad "data exit $EXIT"
  exit $EXIT
else
  bad "skills/data/run.sh not found"
  exit 1
fi
