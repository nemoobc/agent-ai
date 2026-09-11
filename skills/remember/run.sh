#!/usr/bin/env bash
# remember — simpan memory entry ke MEMORY.md, decisions.md, session-log.md
# Usage: bash skills/remember/run.sh [title] [context] [decision] [learning]
#        atau: echo "content" | bash skills/remember/run.sh
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

GLOBAL_MEM="$HOME/.config/opencode/memory"
LOCAL_MEM=".opencode/memory"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE=$(date '+%Y-%m-%d')

echo ""
p "═══════════════════════════════════════════" 33
p "         💾 REMEMBER — MEMORY SAVER        " 33
p "═══════════════════════════════════════════" 33
echo ""

# Tentukan direktori target
MEM_DIR="$GLOBAL_MEM"
if [ -d "$LOCAL_MEM" ]; then
  MEM_DIR="$LOCAL_MEM"
  info "Menggunakan local memory: $LOCAL_MEM"
else
  info "Menggunakan global memory: $GLOBAL_MEM"
fi

# Buat direktori jika belum ada
if ! mkdir -p "$MEM_DIR" 2>/dev/null; then
  bad "Gagal membuat direktori: $MEM_DIR"
  exit 1
fi

# Baca input: dari args atau stdin
if [ $# -ge 1 ]; then
  TITLE="${1:-}"
  CONTEXT="${2:-}"
  DECISION="${3:-}"
  LEARNING="${4:-}"
  info "Input dari argumen"
else
  # Baca dari stdin
  if [ -t 0 ]; then
    bad "Tidak ada input. Gunakan: bash skills/remember/run.sh <title> [context] [decision] [learning]"
    bad "atau: echo 'content' | bash skills/remember/run.sh"
    exit 1
  fi
  STDIN_CONTENT=$(cat)
  TITLE="Note $TIMESTAMP"
  CONTEXT="$STDIN_CONTENT"
  DECISION=""
  LEARNING=""
  info "Input dari stdin"
fi

if [ -z "$TITLE" ] && [ -z "$CONTEXT" ]; then
  bad "Input kosong — tidak ada yang disimpan"
  exit 1
fi

echo ""
p "▸ MENYIMPAN ENTRY" 45
info "Judul   : ${TITLE:-—}"
info "Konteks : ${CONTEXT:0:60}${#CONTEXT:+...}"
info "Putusan : ${DECISION:-—}"
info "Pelajaran: ${LEARNING:-—}"

# ── MEMORY.md ──────────────────────────────────────────────────
MEMORY_FILE="$MEM_DIR/MEMORY.md"
{
  echo ""
  echo "## $TITLE"
  echo "_Disimpan: $TIMESTAMP_"
  echo ""
  [ -n "$CONTEXT" ]  && echo "**Konteks:** $CONTEXT"
  [ -n "$DECISION" ] && echo "**Putusan:** $DECISION"
  [ -n "$LEARNING" ] && echo "**Pelajaran:** $LEARNING"
  echo ""
  echo "---"
} >> "$MEMORY_FILE"
ok "MEMORY.md diperbarui"

# ── decisions.md ───────────────────────────────────────────────
if [ -n "$DECISION" ]; then
  DECISIONS_FILE="$MEM_DIR/decisions.md"
  {
    echo ""
    echo "### [$DATE] $TITLE"
    echo "- **Konteks:** ${CONTEXT:-—}"
    echo "- **Putusan:** $DECISION"
    echo ""
  } >> "$DECISIONS_FILE"
  ok "decisions.md diperbarui"
else
  warn "decisions.md dilewati — tidak ada putusan"
fi

# ── session-log.md ─────────────────────────────────────────────
SESSION_FILE="$MEM_DIR/session-log.md"
{
  echo "[$TIMESTAMP] **$TITLE** — ${CONTEXT:0:80}"
} >> "$SESSION_FILE"
ok "session-log.md diperbarui"

echo ""
p "▸ HASIL" 45
ok "Entry berhasil disimpan ke: $MEM_DIR"
info "Gunakan 'bash skills/recall/run.sh' untuk membaca kembali"

echo ""
p "═══════════════════════════════════════════" 33
p "         REMEMBER SELESAI                  " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
