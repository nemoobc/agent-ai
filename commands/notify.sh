#!/usr/bin/env bash
# notify — run skill notify
# Usage: bash commands/notify.sh [args]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ NOTIFY ═══" 213
if [ -f "$DIR/skills/notify/run.sh" ]; then
  bash "$DIR/skills/notify/run.sh" "$@"
  EXIT=$?
  [ "$EXIT" -eq 0 ] && ok "notify clean" || bad "notify exit $EXIT"
  exit $EXIT
else
  bad "skills/notify/run.sh not found"
  exit 1
fi
