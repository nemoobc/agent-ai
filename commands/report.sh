#!/usr/bin/env bash
# report — generate status report
# Usage: bash commands/report.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
warn(){ p "  ⚠ $1" 214; }

p "═══ STATUS REPORT ═══" 213

# Version
VER=$(cat "$DIR/VERSION" 2>/dev/null || echo "?")
p "Version: $VER" 248

# Git
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null || echo "?")
  COMMITS=$(git -C "$DIR" rev-list --count HEAD 2>/dev/null || echo "0")
  LAST=$(git -C "$DIR" log -1 --pretty=%s 2>/dev/null || echo "?")
  p "Git: $BRANCH ($COMMITS commits)" 248
  p "Last commit: $LAST" 248
fi

# Metrics
SKILLS=$(ls "$DIR/skills/" 2>/dev/null | wc -l)
AGENTS=$(ls "$DIR/agents/" 2>/dev/null | wc -l)
TESTS=$(ls "$DIR/tests/" 2>/dev/null | wc -l)
COMMANDS=$(ls "$DIR/commands/" 2>/dev/null | wc -l)
p "Skills: $SKILLS | Agents: $AGENTS | Tests: $TESTS | Commands: $COMMANDS" 248

# Test result
if [ -f "$DIR/tests/self-test.sh" ]; then
  bash "$DIR/tests/self-test.sh" > /dev/null 2>&1 && ok "Tests: PASS" || warn "Tests: FAIL"
fi

# Audit
if [ -f "$DIR/skills/audit-full/run.sh" ]; then
  p "" 0
  p "▶ Audit:" 213
  bash "$DIR/skills/audit-full/run.sh" . 2>&1
fi

# Lessons
if [ -f "$DIR/memory/lessons.md" ]; then
  LESSONS=$(wc -l < "$DIR/memory/lessons.md" 2>/dev/null || echo 0)
  p "Lessons learned: $LESSONS lines" 248
fi
