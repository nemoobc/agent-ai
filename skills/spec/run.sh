#!/usr/bin/env bash
# spec — formalisasi spesifikasi: format spesifikasi formal
# Usage: bash skills/spec/run.sh [input_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/spec/run.sh <file_atau_string>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         📋 SPEC — SPESIFIKASI RESMI        " 33
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

echo ""
p "▸ BLOK: SPESIFIKASI RESMI" 45
echo ""

# Acceptance Criteria
info "=== ACCEPTANCE CRITERIA ==="
CRITERIA=1
echo "$CONTENT" | grep -iE '(harus|wajib|must|should|shall|perlu)' | while read -r line; do
  ok "AC-$CRITERIA: $line"
  CRITERIA=$((CRITERIA + 1))
done

# Edge Cases
echo ""
info "=== EDGE CASES ==="
if echo "$CONTENT" | grep -qiE '(edge|corner|special|kasus khusus|batas|max|min|null|empty)'; then
  echo "$CONTENT" | grep -iE '(edge|corner|special|kasus khusus|batas|max|min|null|empty)' | while read -r line; do
    warn "EC: $line"
  done
else
  warn "Tidak ada edge case eksplisit terdeteksi — pertimbangkan manual"
fi

# Constraints
echo ""
info "=== CONSTRAINTS ==="
if echo "$CONTENT" | grep -qiE '(constraint|limit|batas|max|size|memory|time|timeout)'; then
  echo "$CONTENT" | grep -iE '(constraint|limit|batas|max|size|memory|time|timeout)' | while read -r line; do
    bad "CONSTRAINT: $line"
  done
else
  warn "Tidak ada constraint eksplisit terdeteksi"
fi

# Non-Goals
echo ""
info "=== NON-GOALS ==="
if echo "$CONTENT" | grep -qiE '(non-goal|bukan tujuan|tidak termasuk|exclude|out of scope)'; then
  echo "$CONTENT" | grep -iE '(non-goal|bukan tujuan|tidak termasuk|exclude|out of scope)' | while read -r line; do
    info "NON-GOAL: $line"
  done
else
  warn "Tidak ada non-goal eksplisit — tentukan batasan scope"
fi

echo ""
info "=== RINGKASAN SPESIFIKASI ==="
ok "Jumlah kata: $(echo "$CONTENT" | wc -w)"
ok "Panjang: $(echo "$CONTENT" | wc -l) baris"
ok "Status: Spesifikasi terformalisasi — gunakan untuk implementasi"

echo ""
p "═══════════════════════════════════════════" 33
p "         SPEC SELESAI                      " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
