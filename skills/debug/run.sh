#!/usr/bin/env bash
# debug — debug methodology: reproduksi → isolasi → bukti → fix
# Usage: bash skills/debug/run.sh [error_file_or_string]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/debug/run.sh <file_error_atau_string>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         🔍 DEBUG — METHODOLOGY            " 33
p "═══════════════════════════════════════════" 33
echo ""

# Baca input
if [ -f "$INPUT" ]; then
  CONTENT=$(cat "$INPUT" 2>/dev/null)
  info "Membaca error log: $INPUT"
else
  CONTENT="$INPUT"
  info "Input string langsung"
fi

if [ -z "$CONTENT" ]; then
  bad "Input kosong"
  exit 1
fi

echo ""
p "▸ FASE 1: REPRODUKSI" 45
ok "Langkah 1.1: Catat error message persis"
ok "Langkah 1.2: Catat input yang menyebabkan error"
ok "Langkah 1.3: Catat environment (OS, version, config)"
ok "Langkah 1.4: Buat minimal reproducible example"

echo ""
p "▸ FASE 2: ISOLASI" 45
ok "Langkah 2.1: Binary search — komponen mana?"
ok "Langkah 2.2: Simplify — hapus kode tidak relevan"
ok "Langkah 2.3: Comment out — cari baris penyebab"
ok "Langkah 2.4: Log intermediate values"

echo ""
p "▸ FASE 3: BUKTI" 45
ok "Langkah 3.1: Hypothesis — dugaan penyebab"
ok "Langkah 3.2: Test hypothesis — buktikan dengan log/assert"
ok "Langkah 3.3: Root cause — konfirmasi akar masalah"

echo ""
p "▸ FASE 4: FIX" 45
ok "Langkah 4.1: Implement fix minimal"
ok "Langkah 4.2: Verify fix — test passes"
ok "Langkah 4.3: Regression test — tidak pecah yang lain"
ok "Langkah 4.4: Document — catat di CHANGELOG/commit"

echo ""
info "=== ERROR PATTERN DETECTION ==="
if echo "$CONTENT" | grep -qiE '(TypeError|undefined is not)'; then
  warn "Pattern: Null/undefined access — cek optional chaining"
elif echo "$CONTENT" | grep -qiE '(SyntaxError|unexpected token)'; then
  warn "Pattern: Syntax error — cek bracket, comma, quotes"
elif echo "$CONTENT" | grep -qiE '(ReferenceError|is not defined)'; then
  warn "Pattern: Scope issue — cek import/declaration"
elif echo "$CONTENT" | grep -qiE '(ENOENT|no such file)'; then
  warn "Pattern: File not found — cek path, casing"
elif echo "$CONTENT" | grep -qiE '(EACCES|permission denied)'; then
  warn "Pattern: Permission issue — cek chmod/ownership"
elif echo "$CONTENT" | grep -qiE '(ECONNREFUSED|connection refused)'; then
  warn "Pattern: Network issue — cek port, service"
elif echo "$CONTENT" | grep -qiE '(timeout|timed out)'; then
  warn "Pattern: Timeout — cek network, performance"
else
  info "Pattern: Tidak dikenali — perlu analisis manual"
fi

echo ""
ok "Debug methodology selesai — gunakan FASE 1-4 secara sistematis"

echo ""
p "═══════════════════════════════════════════" 33
p "         DEBUG SELESAI                     " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
