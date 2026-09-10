#!/usr/bin/env bash
# learn — show lessons learned
# Usage: bash commands/learn.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
warn(){ p "  ⚠ $1" 214; }

p "═══ LESSONS LEARNED ═══" 213

if [ -f "$DIR/memory/lessons.md" ]; then
  cat "$DIR/memory/lessons.md"
else
  warn "No lessons.md found"
  p "Tip: create memory/lessons.md to track what you've learned" 248
  p "" 0
  p "Template:" 213
  p "# Lessons Learned" 248
  p "" 0
  p "## [date] - lesson title" 248
  p "- What happened" 248
  p "- What we learned" 248
  p "- What to do next time" 248
fi
