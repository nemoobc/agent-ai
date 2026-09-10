#!/usr/bin/env bash
# ship — prepare for ship (verify + clean + deliver)
# Usage: bash commands/ship.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ SHIP — PREPARE DELIVERY ═══" 213

# Step 1: Verify
p "▶ Step 1: Verify" 213
bash "$DIR/commands/verify.sh"
VERIFY_EXIT=$?
if [ "$VERIFY_EXIT" -ne 0 ]; then
  bad "VERIFY gagal — ship dibatalkan"
  exit 1
fi

# Step 2: Clean
p "▶ Step 2: Clean" 213
bash "$DIR/commands/clean.sh"

# Step 3: Deliver
p "▶ Step 3: Deliver" 213
bash "$DIR/skills/deliver/run.sh" .

p "═══ SHIP SELESAI ═══" 82
