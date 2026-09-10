#!/usr/bin/env bash
# audit — run audit-full
# Usage: bash commands/audit.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ AUDIT ═══" 213
if [ -f "$DIR/skills/audit-full/run.sh" ]; then
  bash "$DIR/skills/audit-full/run.sh" .
  EXIT=$?
  [ "$EXIT" -eq 0 ] && ok "Audit clean" || bad "Audit found issues (exit $EXIT)"
  exit $EXIT
else
  bad "skills/audit-full/run.sh not found"
  exit 1
fi
