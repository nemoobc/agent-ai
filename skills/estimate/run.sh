#!/usr/bin/env bash
# estimate — estimasi skala: hitung file/line/baris → klasifikasi S/M/L/XL
# Usage: bash skills/estimate/run.sh [directory_or_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-.}"
echo ""
p "═══════════════════════════════════════════" 33
p "         📊 ESTIMATE — ESTIMASI SKALA       " 33
p "═══════════════════════════════════════════" 33
echo ""

# Hitung file
if [ -d "$INPUT" ]; then
  info "Menghitung direktori: $INPUT"
  FILE_COUNT=$(find "$INPUT" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.rb" -o -name "*.php" \) 2>/dev/null | wc -l)
  TOTAL_LINES=$(find "$INPUT" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.rb" -o -name "*.php" \) -exec cat {} + 2>/dev/null | wc -l)
  TOTAL_WORDS=$(find "$INPUT" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.rb" -o -name "*.php" \) -exec cat {} + 2>/dev/null | wc -w)
elif [ -f "$INPUT" ]; then
  info "Menghitung file: $INPUT"
  FILE_COUNT=1
  TOTAL_LINES=$(wc -l < "$INPUT" 2>/dev/null || echo 0)
  TOTAL_WORDS=$(wc -w < "$INPUT" 2>/dev/null || echo 0)
else
  bad "Input tidak valid: $INPUT"
  exit 1
fi

echo ""
info "=== HASIL PENGHITUNGAN ==="
ok "File: $FILE_COUNT"
ok "Baris kode: $TOTAL_LINES"
ok "Kata: $TOTAL_WORDS"

echo ""
info "=== KLASIFIKASI SKALA ==="
if [ "$TOTAL_LINES" -lt 100 ]; then
  ok "Skala: S (Small) — ≤100 baris"
  ok "Estimasi: 30 menit - 1 jam"
  ok "Complexity: Rendah"
elif [ "$TOTAL_LINES" -lt 500 ]; then
  ok "Skala: M (Medium) — 100-500 baris"
  ok "Estimasi: 1-4 jam"
  ok "Complexity: Sedang"
elif [ "$TOTAL_LINES" -lt 2000 ]; then
  ok "Skala: L (Large) — 500-2000 baris"
  ok "Estimasi: 1-2 hari"
  ok "Complexity: Tinggi"
else
  ok "Skala: XL (Extra Large) — ≥2000 baris"
  ok "Estimasi: 3-7 hari"
  ok "Complexity: Sangat tinggi"
fi

echo ""
info "=== REKOMENDASI ==="
if [ "$FILE_COUNT" -gt 10 ]; then
  warn "Banyak file — pertimbangkan modularisasi"
fi
if [ "$TOTAL_LINES" -gt 1000 ]; then
  warn "Kode besar — pastikan test coverage tinggi"
fi
ok "Break down menjadi task lebih kecil bila XL"
ok "Gunakan pair programming untuk L/XL"

echo ""
p "═══════════════════════════════════════════" 33
p "         ESTIMATE SELESAI                  " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
