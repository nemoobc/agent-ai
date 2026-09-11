#!/usr/bin/env bash
# recall — baca memory files dan tampilkan ringkasan relevan
# Usage: bash skills/recall/run.sh [keyword]
set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

KEYWORD="${1:-}"
GLOBAL_MEM="$HOME/.config/opencode/memory"
LOCAL_MEM=".opencode/memory"

echo ""
p "═══════════════════════════════════════════" 33
p "         🧠 RECALL — MEMORY READER          " 33
p "═══════════════════════════════════════════" 33
echo ""

read_section(){
  local label="$1"
  local file="$2"
  local tail_lines="${3:-}"

  if [ ! -f "$file" ]; then
    warn "$label: tidak ditemukan ($file)"
    return
  fi

  echo ""
  p "▸ $label" 45
  if [ -n "$tail_lines" ]; then
    local content
    content=$(tail -n "$tail_lines" "$file" 2>/dev/null)
  else
    local content
    content=$(cat "$file" 2>/dev/null)
  fi

  if [ -z "$content" ]; then
    warn "  (kosong)"
    return
  fi

  if [ -n "$KEYWORD" ]; then
    local filtered
    filtered=$(echo "$content" | grep -i "$KEYWORD" 2>/dev/null)
    if [ -n "$filtered" ]; then
      echo "$filtered" | while IFS= read -r line; do
        info "$line"
      done
      ok "  → match ditemukan untuk keyword: '$KEYWORD'"
    else
      warn "  → tidak ada match untuk keyword: '$KEYWORD'"
    fi
  else
    echo "$content" | while IFS= read -r line; do
      info "$line"
    done
  fi
}

for MEM_DIR in "$GLOBAL_MEM" "$LOCAL_MEM"; do
  if [ ! -d "$MEM_DIR" ]; then
    [ "$MEM_DIR" = "$LOCAL_MEM" ] && warn "Local memory tidak ada: $MEM_DIR" || warn "Global memory tidak ada: $MEM_DIR"
    continue
  fi

  echo ""
  p "━━━ SUMBER: $MEM_DIR ━━━" 213

  read_section "MEMORY.md (full)" "$MEM_DIR/MEMORY.md"
  read_section "decisions.md (full)" "$MEM_DIR/decisions.md"
  read_section "lessons.md (last 10)" "$MEM_DIR/lessons.md" "10"
  read_section "session-log.md (last 10)" "$MEM_DIR/session-log.md" "10"
done

echo ""
p "▸ RINGKASAN" 45
ok "Recall selesai. Gunakan output di atas sebagai konteks sesi ini."
[ -n "$KEYWORD" ] && ok "Filter aktif: '$KEYWORD'" || info "Tip: bash skills/recall/run.sh <keyword> untuk filter"

echo ""
p "═══════════════════════════════════════════" 33
p "         RECALL SELESAI                    " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
