#!/usr/bin/env bash
# team — show team/agent info
# Usage: bash commands/team.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }

p "═══ TEAM / AGENTS ═══" 213

if [ -d "$DIR/agents" ]; then
  for agent in "$DIR/agents/"*; do
    NAME=$(basename "$agent" .md)
    DESC=$(head -5 "$agent" 2>/dev/null | grep -v "^#" | grep -v "^$" | head -1)
    p "  $NAME" 82
    [ -n "$DESC" ] && p "    $DESC" 248
  done
else
  p "No agents/ directory found" 214
fi

p "" 0
p "═══ SKILLS ═══" 213
if [ -d "$DIR/skills" ]; then
  SKILL_COUNT=$(ls "$DIR/skills/" 2>/dev/null | wc -l)
  p "Total skills: $SKILL_COUNT" 248
  ls "$DIR/skills/" 2>/dev/null | tr '\n' ' ' | fold -s -w 60 | while read -r line; do
    p "  $line" 248
  done
fi
