#!/usr/bin/env bash
# route — cek route intensity dari prompt
# Usage: bash commands/route.sh "prompt text"
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

PROMPT="${1:-}"
if [ -z "$PROMPT" ]; then
  p "Usage: bash commands/route.sh \"your prompt\"" 214
  exit 0
fi

if [ -f "$DIR/skills/route/run.sh" ]; then
  bash "$DIR/skills/route/run.sh" "$PROMPT"
else
  # Fallback: simple regex check
  L=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')
  if echo "$L" | grep -qE '(panggil|tunjukkan|semua|all).*(agent|skill|kemampuan)'; then
    p "JALUR: ULTRA" 196
  elif echo "$L" | grep -qE '(lengkap|bagus|matang|deep|improve|full|refine)'; then
    p "JALUR: FULL" 214
  else
    p "JALUR: NORMAL" 82
  fi
fi
