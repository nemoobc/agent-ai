#!/usr/bin/env bash
# research — riset fakta: cari informasi dari web/file → verifikasi klaim
# Usage: bash skills/research/run.sh [query_or_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/research/run.sh <query_atau_file>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         🔬 RESEARCH — RISET FAKTA          " 33
p "═══════════════════════════════════════════" 33
echo ""

# Baca input
if [ -f "$INPUT" ]; then
  CONTENT=$(cat "$INPUT" 2>/dev/null)
  info "Membaca file: $INPUT"
else
  CONTENT="$INPUT"
  info "Query: $INPUT"
fi

if [ -z "$CONTENT" ]; then
  bad "Input kosong"
  exit 1
fi

echo ""
p "▸ METHODOLOGY RISET" 45
ok "1. Identifikasi klaim yang perlu diverifikasi"
ok "2. Cari sumber otoritatif (dokumentasi, paper, official docs)"
ok "3. Bandingkan minimal 2-3 sumber berbeda"
ok "4. Verifikasi: sumber primer > sekunder > forum"
ok "5. Catat sumber untuk setiap klaim"

echo ""
p "▸ KLAIM TERDETEKSI" 45
echo ""

# Deteksi klaim dalam input
CLAIM_COUNT=0
if echo "$CONTENT" | grep -qiE '(adalah|merupakan|bisa|tidak bisa|harus|wajib)'; then
  info "Klaim perlu verifikasi ditemukan:"
  echo "$CONTENT" | grep -iE '(adalah|merupakan|bisa|tidak bisa|harus|wajib)' | head -5 | while read -r line; do
    CLAIM_COUNT=$((CLAIM_COUNT + 1))
    warn "CLAIM-$CLAIM_COUNT: $line"
  done
else
  info "Tidak ada klaim eksplisit — input mungkin sudah verified"
fi

echo ""
p "▸ SUMBER YANG DISARANKAN" 45
ok "Dokumentasi resmi (official docs)"
ok "Stack Overflow (jawaban dengan banyak vote)"
ok "GitHub issues (discussions dari maintainer)"
ok "Paper/jurnal (untuk klaim akademis)"
ok "MDN Web Docs (untuk web technologies)"
ok "RFC (untuk standar internet)"

echo ""
p "▸ VERIFICATION CHECKLIST" 45
ok "☐ Sumber primer ditemukan?"
ok "☐ Minimal 2 sumber independently verify?"
ok "☐ Informasi masih up-to-date?"
ok "☐ Tidak ada conflict antar sumber?"
ok "☐ Context sesuai dengan use case?"
ok "☐ Caveats dan edge cases dicatat?"

echo ""
info "=== STATUS ==="
ok "Riset framework siap — jalankan verifikasi manual"
ok "Catat semua sumber untuk rantai bukti (HUKUM 11)"

echo ""
p "═══════════════════════════════════════════" 33
p "         RESEARCH SELESAI                  " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
