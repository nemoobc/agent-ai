#!/usr/bin/env bash
# web — run skill web
# Usage: bash commands/web.sh [args]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ WEB ═══" 213
if [ -f "$DIR/skills/web/run.sh" ]; then
  bash "$DIR/skills/web/run.sh" "$@"
  EXIT=$?
  [ "$EXIT" -eq 0 ] && ok "web clean" || bad "web exit $EXIT"
  exit $EXIT
else
  bad "skills/web/run.sh not found"
  exit 1
fi
