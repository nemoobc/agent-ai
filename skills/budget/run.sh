#!/usr/bin/env bash
# budget — tampilkan status budget per fase: BOOT/GODOK/BANGUN/TEST/AUDIT/CADANGAN
# Usage: bash skills/budget/run.sh [phase]
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

PHASE="${1:-ALL}"
PHASE_UPPER=$(echo "$PHASE" | tr '[:lower:]' '[:upper:]')

echo ""
p "═══════════════════════════════════════════" 33
p "         💰 BUDGET — PHASE TRACKER         " 33
p "═══════════════════════════════════════════" 33
echo ""

# ── Definisi budget per fase ──────────────────────────────────
# Format: FASE|ALOKASI_TOKEN_ESTIMASI|DESKRIPSI|WARNA
PHASES=(
  "BOOT|500|Inisialisasi, baca manifest & memory|82"
  "GODOK|1500|Analisis mendalam: scan, think, spec|111"
  "BANGUN|4000|Implementasi kode utama|45"
  "TEST|1000|Tulis & jalankan test|214"
  "AUDIT|800|Review, clean, security check|196"
  "CADANGAN|200|Buffer darurat & recovery|213"
)

TOTAL_BUDGET=8000

show_phase(){
  local fase="$1"
  local alloc="$2"
  local desc="$3"
  local color="$4"
  local pct=$(( alloc * 100 / TOTAL_BUDGET ))

  # Bar visual (max 20 chars)
  local bar_filled=$(( pct / 5 ))
  local bar_empty=$(( 20 - bar_filled ))
  local bar=""
  local i=0
  while [ $i -lt $bar_filled ]; do bar="${bar}█"; i=$((i+1)); done
  while [ $i -lt 20 ]; do bar="${bar}░"; i=$((i+1)); done

  p "  [BUDGET] $fase" "$color"
  p "  ├─ Alokasi   : ~$alloc token ($pct% dari total)" "$color"
  p "  ├─ Bar       : [$bar] $pct%" "$color"
  p "  └─ Tujuan    : $desc" "$color"
  echo ""
}

# ── Tampilkan satu fase atau semua ───────────────────────────
FOUND=0

for phase_def in "${PHASES[@]}"; do
  IFS='|' read -r fname falloc fdesc fcolor <<< "$phase_def"
  if [ "$PHASE_UPPER" = "ALL" ] || [ "$PHASE_UPPER" = "$fname" ]; then
    show_phase "$fname" "$falloc" "$fdesc" "$fcolor"
    FOUND=1
  fi
done

if [ "$FOUND" -eq 0 ]; then
  bad "Fase tidak dikenal: '$PHASE'"
  echo ""
  warn "Fase yang tersedia: BOOT | GODOK | BANGUN | TEST | AUDIT | CADANGAN | ALL"
  echo ""
  exit 1
fi

# ── Summary total ─────────────────────────────────────────────
if [ "$PHASE_UPPER" = "ALL" ]; then
  p "▸ TOTAL BUDGET" 33
  info "Total estimasi : $TOTAL_BUDGET token/session"
  info "Urutan fase    : BOOT → GODOK → BANGUN → TEST → AUDIT → CADANGAN"
  echo ""
  p "  ┌─────────────────────────────────────────┐" 213
  p "  │ [BUDGET] BOOT     ██░░░░░░░░░░░░░░░░░░  6% │" 82
  p "  │ [BUDGET] GODOK    ████░░░░░░░░░░░░░░░░ 19% │" 111
  p "  │ [BUDGET] BANGUN   ██████████░░░░░░░░░░ 50% │" 45
  p "  │ [BUDGET] TEST     ████░░░░░░░░░░░░░░░░ 12% │" 214
  p "  │ [BUDGET] AUDIT    ██░░░░░░░░░░░░░░░░░░ 10% │" 196
  p "  │ [BUDGET] CADANGAN █░░░░░░░░░░░░░░░░░░░  3% │" 213
  p "  └─────────────────────────────────────────┘" 213
fi

echo ""
ok "Budget check selesai. Gunakan info ini untuk alokasi context yang efisien."
info "Tip: Gunakan 'bash skills/context/run.sh' untuk cek file budget"

echo ""
p "═══════════════════════════════════════════" 33
p "         BUDGET SELESAI                    " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
