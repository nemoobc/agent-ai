#!/usr/bin/env bash
# fix — run fixer mode (fix semua temuan test/audit)
# Usage: bash commands/fix.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ FIXER MODE ═══" 213

# Run audit first to find issues
p "▶ Running audit..." 213
AUDIT_OUT=$(bash "$DIR/skills/audit-full/run.sh" . 2>&1)
echo "$AUDIT_OUT"

# Run tests to find failures
p "▶ Running tests..." 213
bash "$DIR/tests/self-test.sh" 2>&1
TEST_EXIT=$?

# Run lint
p "▶ Running lint..." 213
bash "$DIR/tests/lint-kit.sh" 2>&1
LINT_EXIT=$?

if [ "$TEST_EXIT" -ne 0 ] || [ "$LINT_EXIT" -ne 0 ]; then
  p "═══ ISSUES FOUND — apply fixes manually or run fixer agent ═══" 214
  p "Tip: panggil fixer agent untuk auto-fix" 248
  exit 1
else
  ok "No issues found — all clean"
  p "═══ FIX: TIDAK ADA TEMUAN ═══" 82
  exit 0
fi
