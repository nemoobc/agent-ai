#!/usr/bin/env bash
# multi-model — run skill multi-model
# Usage: bash commands/multi-model.sh [args]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ MULTI-MODEL ═══" 213
if [ -f "$DIR/skills/multi-model/run.sh" ]; then
  bash "$DIR/skills/multi-model/run.sh" "$@"
  EXIT=$?
  [ "$EXIT" -eq 0 ] && ok "multi-model clean" || bad "multi-model exit $EXIT"
  exit $EXIT
else
  bad "skills/multi-model/run.sh not found"
  exit 1
fi
