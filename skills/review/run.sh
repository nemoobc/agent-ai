#!/usr/bin/env bash
# review — code review: baca diff → cari masalah
# Usage: bash skills/review/run.sh [file_or_diff]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/review/run.sh <file_atau_diff>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         🔎 REVIEW — CODE REVIEW           " 33
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
p "▸ TEMUAN REVIEW" 45
echo ""

# Logic issues
info "=== LOGIC ISSUES ==="
ISSUES=0
if echo "$CONTENT" | grep -qiE '(if\s*\(\s*true\)|while\s*\(\s*1\)|for\s*\(\s*;;\))'; then
  bad "CRITICAL: Infinite loop detected"
  ISSUES=$((ISSUES + 1))
fi
if echo "$CONTENT" | grep -qiE '(==\s*null|!=\s*null)'; then
  warn "MEDIUM: Use strict equality (===/!==)"
  ISSUES=$((ISSUES + 1))
fi
if echo "$CONTENT" | grep -qiE '(catch\s*\(\s*\w*\s*\)\s*\{\s*\})'; then
  warn "MEDIUM: Empty catch block — error swallowed"
  ISSUES=$((ISSUES + 1))
fi

# Security
echo ""
info "=== SECURITY ==="
if echo "$CONTENT" | grep -qiE '(eval\(|exec\(|system\(|innerHTML)'; then
  bad "CRITICAL: Potential code injection"
  ISSUES=$((ISSUES + 1))
fi
if echo "$CONTENT" | grep -qiE '(password|secret|token|api.key)\s*='; then
  warn "HIGH: Hardcoded secret detected"
  ISSUES=$((ISSUES + 1))
fi
if echo "$CONTENT" | grep -qiE '(SELECT.*FROM.*WHERE.*\+)'; then
  bad "CRITICAL: SQL injection vulnerability"
  ISSUES=$((ISSUES + 1))
fi

# Performance
echo ""
info "=== PERFORMANCE ==="
if echo "$CONTENT" | grep -qiE 'for.*for.*for'; then
  warn "MEDIUM: Nested loops — O(n³) complexity"
  ISSUES=$((ISSUES + 1))
fi
if echo "$CONTENT" | grep -qiE '(SELECT\s+\*\s+FROM)'; then
  warn "LOW: SELECT * — select only needed columns"
  ISSUES=$((ISSUES + 1))
fi

# Readability
echo ""
info "=== READABILITY ==="
LONG_LINES=$(echo "$CONTENT" | awk 'length > 120' | wc -l)
if [ "$LONG_LINES" -gt 0 ]; then
  warn "LOW: $LONG_LINES lines exceed 120 chars"
  ISSUES=$((ISSUES + 1))
fi

echo ""
info "=== RINGKASAN ==="
ok "Total temuan: $ISSUES"
if [ $ISSUES -eq 0 ]; then
  ok "Tidak ada masalah kritis — code review PASS"
else
  warn "Ada $ISSUES temuan — perlu perbaikan sebelum merge"
fi

echo ""
info "Severity levels:"
bad "CRITICAL: Harus fix sebelum merge"
warn "HIGH: Fix segera"
warn "MEDIUM: Fix sebelum release"
info "LOW: Fix bila ada waktu"

echo ""
p "═══════════════════════════════════════════" 33
p "         REVIEW SELESAI                    " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
