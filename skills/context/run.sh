#!/usr/bin/env bash
# context — cek context budget: berapa file sudah dibaca, ringkasan prompt, status [CTX]
# Usage: bash skills/context/run.sh [root_dir]
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

ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { bad "Direktori tidak ditemukan: $ROOT"; exit 1; }

# Context budget thresholds (estimated file count)
CTX_LOW=10
CTX_MED=25
CTX_HIGH=50

echo ""
p "═══════════════════════════════════════════" 33
p "         📊 CONTEXT — BUDGET CHECKER        " 33
p "═══════════════════════════════════════════" 33
echo ""

# ── Hitung file yang bisa dibaca di root ──────────────────────
TOTAL_FILES=$(find . -maxdepth 3 -type f \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  -not -path './.next/*' \
  -not -path './dist/*' \
  -not -path './build/*' \
  -not -path './__pycache__/*' \
  -not -path './target/*' \
  2>/dev/null | wc -l)

# ── Perkiraan ukuran total (baris) ────────────────────────────
TOTAL_LINES=$(find . -maxdepth 3 -type f \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" \
  -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.sh" \
  -o -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \
  2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)

# ── File-file kritis ──────────────────────────────────────────
CRITICAL_FILES=""
[ -f "package.json" ]    && CRITICAL_FILES="$CRITICAL_FILES package.json"
[ -f "pyproject.toml" ]  && CRITICAL_FILES="$CRITICAL_FILES pyproject.toml"
[ -f "go.mod" ]          && CRITICAL_FILES="$CRITICAL_FILES go.mod"
[ -f "Cargo.toml" ]      && CRITICAL_FILES="$CRITICAL_FILES Cargo.toml"
[ -f "README.md" ]       && CRITICAL_FILES="$CRITICAL_FILES README.md"
[ -f ".opencode/AGENTS.md" ] && CRITICAL_FILES="$CRITICAL_FILES .opencode/AGENTS.md"
[ -f "AGENTS.md" ]       && CRITICAL_FILES="$CRITICAL_FILES AGENTS.md"
[ -f ".opencode/memory/MEMORY.md" ] && CRITICAL_FILES="$CRITICAL_FILES .opencode/memory/MEMORY.md"

echo ""
p "▸ BLOK 1: INVENTORI PROYEK" 45
info "Root          : $(pwd)"
info "Total file    : $TOTAL_FILES"
info "Estimasi baris: ${TOTAL_LINES:-0}"
[ -n "$CRITICAL_FILES" ] && info "File kritis   :$CRITICAL_FILES" || warn "File kritis   : —"

# ── Status CTX Budget ─────────────────────────────────────────
echo ""
p "▸ BLOK 2: STATUS [CTX] BUDGET" 45

if [ "$TOTAL_FILES" -lt "$CTX_LOW" ]; then
  ok "[CTX] 🟢 RENDAH — $TOTAL_FILES file. Aman baca semua."
  CTX_STATUS="RENDAH"
elif [ "$TOTAL_FILES" -lt "$CTX_MED" ]; then
  warn "[CTX] 🟡 SEDANG — $TOTAL_FILES file. Baca selektif."
  CTX_STATUS="SEDANG"
elif [ "$TOTAL_FILES" -lt "$CTX_HIGH" ]; then
  warn "[CTX] 🟠 TINGGI — $TOTAL_FILES file. Prioritas manifest + entry point saja."
  CTX_STATUS="TINGGI"
else
  bad "[CTX] 🔴 KRITIS — $TOTAL_FILES file. Gunakan grep/search, jangan baca semua."
  CTX_STATUS="KRITIS"
fi

# ── Ringkasan prompt compact ──────────────────────────────────
echo ""
p "▸ BLOK 3: COMPACT SUMMARY PROMPT" 45
p "  ┌─────────────────────────────────────────┐" 33
p "  │ CTX STATUS : $CTX_STATUS                " 33
p "  │ FILES      : $TOTAL_FILES               " 33
p "  │ LINES EST  : ${TOTAL_LINES:-0}          " 33
p "  │ ROOT       : $(basename $(pwd))         " 33
p "  └─────────────────────────────────────────┘" 33

# ── Rekomendasi ───────────────────────────────────────────────
echo ""
p "▸ BLOK 4: REKOMENDASI" 45
case "$CTX_STATUS" in
  "RENDAH")
    ok "Strategi: Baca semua file relevan sekarang"
    ok "Urutan  : manifest → entry → src utama"
    ;;
  "SEDANG")
    warn "Strategi: Baca manifest + struktur, lalu lazy-load per kebutuhan"
    warn "Urutan  : manifest → scan → read saat diperlukan"
    ;;
  "TINGGI")
    warn "Strategi: Gunakan scan skill dulu, baca per-file minimal"
    warn "Urutan  : scan → grep pattern → baca target spesifik"
    ;;
  "KRITIS")
    bad "Strategi: grep-only, jangan cat file besar"
    bad "Urutan  : grep → baca hanya yang match"
    ;;
esac
info "Tip: Gunakan 'bash skills/scan/run.sh' untuk peta proyek"

echo ""
p "═══════════════════════════════════════════" 33
p "         CONTEXT SELESAI                   " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
