#!/usr/bin/env bash
# coverage — check test coverage
# Usage: bash commands/coverage.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
warn(){ p "  ⚠ $1" 214; }

p "═══ TEST COVERAGE ═══" 213

# Check which skills have tests
p "▶ Skills coverage:" 213
for skill in $(ls "$DIR/skills/" 2>/dev/null); do
  if [ -d "$DIR/skills/$skill" ]; then
    HAS_TEST=0
    [ -f "$DIR/skills/$skill/run.sh" ] && HAS_TEST=1
    [ -f "$DIR/skills/$skill/test.sh" ] && HAS_TEST=1
    [ "$HAS_TEST" -eq 1 ] && ok "$skill" || warn "$skill (no run/test script)"
  fi
done

# Check which skills are tested in eval
if [ -f "$DIR/tests/eval.sh" ]; then
  p "" 0
  p "▶ Eval coverage:" 213
  grep -c "skills/" "$DIR/tests/eval.sh" 2>/dev/null | xargs -I{} p "  Skills in eval: {}" 248
fi
