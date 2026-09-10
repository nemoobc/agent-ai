#!/usr/bin/env bash
# critique — run critic mode
# Usage: bash commands/critique.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ CRITIC MODE ═══" 213

# Run self-test
p "▶ Self-test:" 213
bash "$DIR/tests/self-test.sh" 2>&1
SELF_EXIT=$?

# Run lint
p "▶ Lint kit:" 213
bash "$DIR/tests/lint-kit.sh" 2>&1
LINT_EXIT=$?

# Quick audit
p "▶ Audit:" 213
if [ -f "$DIR/skills/audit-full/run.sh" ]; then
  bash "$DIR/skills/audit-full/run.sh" . 2>&1
fi

p "" 0
if [ "$SELF_EXIT" -eq 0 ] && [ "$LINT_EXIT" -eq 0 ]; then
  ok "Critique: kit passes basic checks"
else
  bad "Critique: issues found — review above"
fi

p "Tip: run 'bash commands/verify.sh' for full gate check" 248
