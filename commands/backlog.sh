#!/usr/bin/env bash
# backlog — show backlog items
# Usage: bash commands/backlog.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

p "═══ BACKLOG ═══" 213

if [ -f "$DIR/docs/BACKLOG.md" ]; then
  cat "$DIR/docs/BACKLOG.md"
elif [ -f "$DIR/command/backlog.md" ]; then
  cat "$DIR/command/backlog.md"
else
  p "No BACKLOG.md found" 214
  p "Tip: create docs/BACKLOG.md to track items" 248
fi
