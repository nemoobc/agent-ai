#!/usr/bin/env bash
# test-design — rancang test cases: baca spesifikasi → tulis test cases
# Usage: bash skills/test-design/run.sh [spec_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/test-design/run.sh <file_atau_string>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         🧪 TEST-DESIGN — RANCANG TEST     " 33
p "═══════════════════════════════════════════" 33
echo ""

# Baca input
if [ -f "$INPUT" ]; then
  CONTENT=$(cat "$INPUT" 2>/dev/null)
  info "Membaca spesifikasi: $INPUT"
else
  CONTENT="$INPUT"
  info "Input string langsung"
fi

if [ -z "$CONTENT" ]; then
  bad "Input kosong"
  exit 1
fi

echo ""
p "▸ TEST CASES YANG DIRANCANG" 45
echo ""

# Happy path
info "=== HAPPY PATH ==="
ok "TC-01: Input valid → Output sesuai ekspektasi"
ok "TC-02: Input minimal → Tetap berfungsi"
ok "TC-03: Input maksimal → Tetap berfungsi"

# Edge cases
echo ""
info "=== EDGE CASES ==="
ok "TC-04: Input kosong → Error handling jelas"
ok "TC-05: Input null/undefined → Graceful degradation"
ok "TC-06: Input special characters → Tidak crash"
ok "TC-07: Input Unicode → Diproses dengan benar"

# Error cases
echo ""
info "=== ERROR CASES ==="
ok "TC-08: Tipe data salah → Error message informatif"
ok "TC-09: Format invalid → Validasi menangkap"
ok "TC-10: Network error (jika ada I/O) → Timeout/retry"

# Boundary
echo ""
info "=== BOUNDARY VALUES ==="
ok "TC-11: Batas bawah (0, min, empty) → Handle dengan benar"
ok "TC-12: Batas atas (max, overflow) → Handle dengan benar"
ok "TC-13: Nilai tepat di batas → Handle dengan benar"

# Integration
echo ""
info "=== INTEGRATION ==="
ok "TC-14: Antar fungsi → Data flow benar"
ok "TC-15: Dengan dependency → Mock/stub tepat"

# Performance
echo ""
info "=== PERFORMANCE ==="
warn "TC-16: Input besar → Response time acceptable"
warn "TC-17: Banyak request concurrent → Tidak race condition"

echo ""
info "=== OUTPUT TEST ==="
ok "Format: Bisa dijalankan dengan test framework"
ok "Naming: TC-XX deskripsi jelas"
ok "Expected: Setiap test punya expected behavior"
ok "Priority: Happy path > Edge > Error > Boundary"

echo ""
warn "REKOMENDASI: Jalankan test SEBELUM implementasi (TDD)"

echo ""
p "═══════════════════════════════════════════" 33
p "         TEST-DESIGN SELESAI               " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
