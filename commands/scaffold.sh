#!/usr/bin/env bash
# scaffold — run skill scaffold
# Usage: bash commands/scaffold.sh [args]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ SCAFFOLD ═══" 213
if [ -f "$DIR/skills/scaffold/run.sh" ]; then
  bash "$DIR/skills/scaffold/run.sh" "$@"
  EXIT=$?
  [ "$EXIT" -eq 0 ] && ok "scaffold clean" || bad "scaffold exit $EXIT"
  exit $EXIT
else
  bad "skills/scaffold/run.sh not found"
  exit 1
fi
