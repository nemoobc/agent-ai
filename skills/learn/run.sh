#!/usr/bin/env bash
# learn — ekstrak pelajaran dari task terakhir, simpan ke lessons.md
# Usage: bash skills/learn/run.sh [pattern] [evidence] [action]
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
DATE=$(date '+%Y-%m-%d')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo ""
p "═══════════════════════════════════════════" 33
p "         📚 LEARN — EKSTRAK PELAJARAN       " 33
p "═══════════════════════════════════════════" 33
echo ""

PATTERN="${1:-}"
EVIDENCE="${2:-}"
ACTION="${3:-}"

# Validasi input
if [ -z "$PATTERN" ]; then
  bad "Pattern wajib diisi."
  echo ""
  p "  Usage: bash skills/learn/run.sh <pattern> [evidence] [action]" 214
  p "  Contoh: bash skills/learn/run.sh 'Selalu baca file sebelum edit' 'Bug karena asumsi salah' 'Baca dulu dengan cat sebelum edit'" 214
  echo ""
  exit 1
fi

[ -z "$EVIDENCE" ] && EVIDENCE="(tidak ada bukti dicatat)"
[ -z "$ACTION"   ] && ACTION="(tidak ada aksi spesifik)"

# Tentukan direktori target
MEM_DIR="$GLOBAL_MEM"
if [ -d "$LOCAL_MEM" ]; then
  MEM_DIR="$LOCAL_MEM"
  info "Menggunakan local memory: $LOCAL_MEM"
else
  info "Menggunakan global memory: $GLOBAL_MEM"
fi

if ! mkdir -p "$MEM_DIR" 2>/dev/null; then
  bad "Gagal membuat direktori: $MEM_DIR"
  exit 1
fi

echo ""
p "▸ PELAJARAN BARU" 45
info "Pattern  : $PATTERN"
info "Bukti    : $EVIDENCE"
info "Aksi     : $ACTION"
info "Tanggal  : $DATE"

# ── lessons.md ─────────────────────────────────────────────────
LESSONS_FILE="$MEM_DIR/lessons.md"

# Inisialisasi file jika belum ada
if [ ! -f "$LESSONS_FILE" ]; then
  {
    echo "# Lessons Learned"
    echo ""
    echo "> File ini berisi pelajaran yang diekstrak dari pengerjaan task."
    echo ""
  } > "$LESSONS_FILE"
  ok "lessons.md dibuat baru"
fi

{
  echo ""
  echo "### $DATE — $PATTERN"
  echo ""
  echo "- **Pattern:** $PATTERN"
  echo "- **Bukti:** $EVIDENCE"
  echo "- **Aksi:** $ACTION"
  echo "- **Dicatat:** $TIMESTAMP"
  echo ""
  echo "---"
} >> "$LESSONS_FILE"
ok "Pelajaran disimpan ke lessons.md"

# Juga catat ringkas ke session-log.md
SESSION_FILE="$MEM_DIR/session-log.md"
{
  echo "[$TIMESTAMP] [LEARN] $PATTERN → $ACTION"
} >> "$SESSION_FILE"
ok "Ringkasan dicatat di session-log.md"

echo ""
p "▸ ISI LESSONS TERBARU" 45
tail -15 "$LESSONS_FILE" 2>/dev/null | while IFS= read -r line; do
  info "$line"
done

echo ""
p "▸ STATISTIK" 45
TOTAL=$(grep -c '^### ' "$LESSONS_FILE" 2>/dev/null || echo 0)
ok "Total pelajaran tersimpan: $TOTAL"
ok "File: $LESSONS_FILE"

echo ""
p "═══════════════════════════════════════════" 33
p "         LEARN SELESAI                     " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
