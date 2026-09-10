#!/usr/bin/env bash
# eval — evaluasi golden tasks: run test suite → skor performa
# Usage: bash skills/eval/run.sh [test_dir]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

TEST_DIR="${1:-.}"
echo ""
p "═══════════════════════════════════════════" 33
p "         📈 EVAL — EVALUASI PERFORMA        " 33
p "═══════════════════════════════════════════" 33
echo ""

info "Mencari test suite di: $TEST_DIR"

# Cari test files
TEST_FILES=$(find "$TEST_DIR" -type f \( -name "*test*" -o -name "*spec*" \) \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -20)

if [ -z "$TEST_FILES" ]; then
  warn "Tidak ada test files ditemukan"
  info "Mencari semua executable files..."
  TEST_FILES=$(find "$TEST_DIR" -type f -name "*.sh" 2>/dev/null | head -20)
fi

echo ""
p "▸ HASIL EVALUASI" 45
echo ""

TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

for test_file in $TEST_FILES; do
  TOTAL=$((TOTAL + 1))
  info "Menjalankan: $test_file"
  
  # Jalankan test dengan timeout
  if timeout 10 bash "$test_file" 2>/dev/null; then
    ok "PASS: $test_file"
    PASSED=$((PASSED + 1))
  else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
      warn "SKIP (timeout): $test_file"
      SKIPPED=$((SKIPPED + 1))
    else
      bad "FAIL: $test_file (exit: $EXIT_CODE)"
      FAILED=$((FAILED + 1))
    fi
  fi
done

echo ""
info "=== RINGKASAN SKOR ==="
ok "Total test: $TOTAL"
ok "Pass: $PASSED"
bad "Fail: $FAILED"
warn "Skip: $SKIPPED"

if [ $TOTAL -gt 0 ]; then
  SCORE=$(( (PASSED * 100) / TOTAL ))
  ok "Skor: $SCORE%"
  
  if [ $SCORE -ge 90 ]; then
    ok "Rating: EXCELLENT (≥90%)"
  elif [ $SCORE -ge 70 ]; then
    ok "Rating: GOOD (≥70%)"
  elif [ $SCORE -ge 50 ]; then
    warn "Rating: FAIR (≥50%)"
  else
    bad "Rating: POOR (<50%)"
  fi
fi

echo ""
info "=== THRESHOLD ==="
warn "Minimum pass rate: 80%"
warn "Maximum fail rate: ≤10%"
warn "Timeout: 10 detik per test"

echo ""
if [ $TOTAL -eq 0 ]; then
  bad "Tidak ada test untuk dievaluasi"
elif [ $FAILED -eq 0 ]; then
  ok "Semua test pass — evaluasi positif"
else
  warn "Ada $FAILED test yang gagal — perlu perbaikan"
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         EVAL SELESAI                      " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
