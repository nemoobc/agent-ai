#!/usr/bin/env bash
# handoff — handoff session to next agent
# Usage: bash commands/handoff.sh [target_agent]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }

TARGET="${1:-next}"

p "═══ HANDOFF ═══" 213

# Create handoff file
mkdir -p "$DIR/memory"
HANDOFF_FILE="$DIR/memory/handoff-$(date +%Y%m%d-%H%M%S).md"

cat > "$HANDOFF_FILE" << EOF
# Handoff to: $TARGET
## Time: $(date)
## Branch: $(git -C "$DIR" branch --show-current 2>/dev/null || echo "?")
## Last commit: $(git -C "$DIR" log -1 --pretty=%s 2>/dev/null || echo "?")

## Status
- Version: $(cat "$DIR/VERSION" 2>/dev/null || echo "?")
- Tests: $(bash "$DIR/tests/self-test.sh" > /dev/null 2>&1 && echo "PASS" || echo "FAIL")

## TODO
- [ ] Continue from last task
- [ ] Check memory/lessons.md for context

## Context
(Add context here)
EOF

ok "Handoff file: $HANDOFF_FILE"
p "" 0
p "HANDOFF RULES:" 213
p "  1. State what was done" 248
p "  2. State what remains" 248
p "  3. List critical context" 248
p "  4. Warn about gotchas" 248
p "  5. Don't assume memory transfer" 248
