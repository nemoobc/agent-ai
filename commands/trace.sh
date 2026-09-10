#!/usr/bin/env bash
# trace — trace claims to evidence
# Usage: bash commands/trace.sh "claim text"
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

CLAIM="${1:-}"
if [ -z "$CLAIM" ]; then
  p "Usage: bash commands/trace.sh \"claim to verify\"" 214
  exit 0
fi

p "═══ TRACE ═══" 213
p "CLAIM: $CLAIM" 248
p "" 0
p "Rantai bukti (HUKUM 11):" 213
p "  KLAIM → BENTUK → BUKTI → SELAIN" 248
p "" 0
p "Scan project for matching evidence..." 213

# Search for the claim keywords in files
WORDS=$(echo "$CLAIM" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | head -5)
FOUND=0
for word in $WORDS; do
  if [ ${#word} -gt 3 ]; then
    RESULTS=$(grep -rl "$word" "$DIR/tests/" "$DIR/skills/" "$DIR/docs/" 2>/dev/null | head -5)
    if [ -n "$RESULTS" ]; then
      p "  Found '$word' in:" 82
      echo "$RESULTS" | while read -r f; do
        p "    → $f" 248
      done
      FOUND=$((FOUND+1))
    fi
  fi
done

if [ "$FOUND" -eq 0 ]; then
  warn "No matching evidence found for this claim"
  p "Tip: create test/audit to back this claim" 214
fi
