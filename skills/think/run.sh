#!/usr/bin/env bash
# think — analisis masalah: baca input, identifikasi masalah, spesifikasi perilaku
# Usage: bash skills/think/run.sh [root_dir] [file_or_string]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${2:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/think/run.sh [root] <file_atau_string>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         🧠 THINK — ANALISIS MASALAH        " 33
p "═══════════════════════════════════════════" 33
echo ""

# Baca input
if [ -f "$INPUT" ]; then
  CONTENT=$(cat "$INPUT" 2>/dev/null)
  info "Membaca file: $INPUT"
else
  CONTENT="$INPUT"
  info "Input string langsung"
fi

if [ -z "$CONTENT" ]; then
  bad "Input kosong"
  exit 1
fi

# Analisis dasar
LINES=$(echo "$CONTENT" | wc -l)
WORDS=$(echo "$CONTENT" | wc -w)
CHARS=$(echo "$CONTENT" | wc -c)

echo ""
p "▸ BLOK 1: ANALISIS" 45
ok "Panjang input: $LINES baris, $WORDS kata, $CHARS karakter"

# Deteksi jenis masalah
if echo "$CONTENT" | grep -qiE '(error|bug|fix|broken|fail|rusak|error)'; then
  warn "Jenis: Bug/Error — ada referensi ke kesalahan"
elif echo "$CONTENT" | grep -qiE '(implement|buat|create|build|tambah|add)'; then
  info "Jenis: Implementasi — permintaan pembuatan baru"
elif echo "$CONTENT" | grep -qiE '(review|audit|cek|check|validasi)'; then
  info "Jenis: Review/Audit — permintaan pemeriksaan"
elif echo "$CONTENT" | grep -qiE '(optimize|perf|speed|cepat|lambat)'; then
  warn "Jenis: Performa — optimasi yang diminta"
else
  info "Jenis: Umum — analisis diperlukan lebih lanjut"
fi

# Deteksi bahasa
if echo "$CONTENT" | grep -qE '\.(js|ts|py|go|rs|java|cpp|c|rb|php)'; then
  ok "File target terdeteksi dalam kode"
fi

echo ""
p "▸ BLOK 2: SPESIFIKASI PERILAKU" 45
info "Input: $(echo "$CONTENT" | head -1 | cut -c1-60)"
info "Batasan: Perlu analisis konteks lebih lanjut"
info "Error: Tangkap dan laporkan dengan jelas"

echo ""
p "▸ BLOK 3: PUTUSAN" 45
ok "Analisis selesai. Gunakan output ini sebagai dasar keputusan."
ok "Rekomendasi: Lanjut ke skill 'spec' untuk formalisasi."

echo ""
p "═══════════════════════════════════════════" 33
p "         THINK SELESAI                     " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
