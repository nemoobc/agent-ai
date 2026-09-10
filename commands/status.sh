#!/usr/bin/env bash
# status — show project status (version, last commit, test result)
# Usage: bash commands/status.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
warn(){ p "  ⚠ $1" 214; }

p "═══ PROJECT STATUS ═══" 213

# Version
[ -f "$DIR/VERSION" ] && p "VERSION: $(cat "$DIR/VERSION")" 82 || warn "VERSION: not found"

# Git
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null || echo "detached")
  HASH=$(git -C "$DIR" rev-parse --short HEAD 2>/dev/null || echo "?")
  MSG=$(git -C "$DIR" log -1 --pretty=%s 2>/dev/null || echo "?")
  DATE=$(git -C "$DIR" log -1 --pretty=%ci 2>/dev/null || echo "?")
  DIRTY=$(git -C "$DIR" status --porcelain 2>/dev/null | wc -l)
  p "GIT: $BRANCH @ $HASH" 248
  p "  Last: $MSG" 248
  p "  Date: $DATE" 248
  [ "$DIRTY" -gt 0 ] && warn "  Uncommitted: $DIRTY files" || ok "Working tree clean"
else
  warn "Not a git repo"
fi

# Test result (quick)
if [ -f "$DIR/tests/self-test.sh" ]; then
  bash "$DIR/tests/self-test.sh" > /dev/null 2>&1 && ok "Tests: PASS" || warn "Tests: FAIL"
fi

# Skills/agents count
SKILLS=$(ls "$DIR/skills/" 2>/dev/null | wc -l)
AGENTS=$(ls "$DIR/agents/" 2>/dev/null | wc -l)
p "SKILLS: $SKILLS | AGENTS: $AGENTS" 248
