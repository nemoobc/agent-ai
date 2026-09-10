#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  CAVEMAN-RUN — toggler/display mode caveman ULTRA.
#  Args: $1=status|on|off
#  Baca/tulis .opencode/memory/mode.txt. Exit 0.
#  Jalankan: bash skills/caveman/run.sh [status|on|off]
# ═════════════════════════════════════════════════════════════════
set -u

ARG="${1:-status}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ echo -e "${GREEN}  ✔ $1${NC}"; }
bad(){ echo -e "${RED}  ✖ $1${NC}"; }
warn(){ echo -e "${YELLOW}  ⚠ $1${NC}"; }
info(){ echo -e "${CYAN}  ℹ $1${NC}"; }
section(){ echo -e "\n${BLUE}▸ $1${NC}"; }

MODE_DIR=".opencode/memory"
MODE_FILE="$MODE_DIR/mode.txt"

echo ""
p "═══════════════════════════════════════════════" 213
p "   🪨 CAVEMAN MODE — TOGGLER                   " 213
p "═══════════════════════════════════════════════" 213
echo ""

# ── Read current mode ─────────────────────────────────────────────
CURRENT_MODE="off"
if [ -f "$MODE_FILE" ]; then
  RAW=$(cat "$MODE_FILE" 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr -d ' \n')
  case "$RAW" in
    on|caveman|ultra|a) CURRENT_MODE="on" ;;
    off|normal|b|c)     CURRENT_MODE="off" ;;
    *)                  CURRENT_MODE="off" ;;
  esac
else
  info "Mode file tidak ditemukan: $MODE_FILE"
  info "Default: off"
fi

# ── Dispatch action ───────────────────────────────────────────────
case "$ARG" in
  on)
    mkdir -p "$MODE_DIR" 2>/dev/null
    echo "on" > "$MODE_FILE"
    CURRENT_MODE="on"
    ok "Mode diubah → ON (caveman ULTRA)"
    ;;
  off)
    mkdir -p "$MODE_DIR" 2>/dev/null
    echo "off" > "$MODE_FILE"
    CURRENT_MODE="off"
    ok "Mode diubah → OFF (normal/polite)"
    ;;
  status)
    info "Membaca state dari: ${MODE_FILE:-tidak ada}"
    ;;
  *)
    warn "Arg tidak dikenal: $ARG"
    info "Pilihan: status | on | off"
    info "Contoh: bash skills/caveman/run.sh on"
    ;;
esac

# ── Display current mode info ─────────────────────────────────────
echo ""
if [ "$CURRENT_MODE" = "on" ]; then
  p "STATUS: 🪨 CAVEMAN MODE ON — ULTRA" 196
  echo ""

  section "MARKER WAJIB"
  echo -e "${RED}  Tampilkan di awal setiap fase:${NC}"
  echo ""
  echo -e "${YELLOW}  [MIKIR]${NC}  — fase analisis / pikir (≤10 baris)"
  echo -e "${GREEN}  [BANGUN]${NC} — fase implementasi / koding"
  echo -e "${CYAN}  [TEST]${NC}   — fase test / verifikasi"
  echo -e "${BLUE}  [AUDIT]${NC}  — fase audit keamanan/kualitas"
  echo -e "${GREEN}  [LAPOR]${NC}  — fase laporan akhir (≤8 baris)"
  echo ""

  section "ATURAN GAYA"
  echo -e "${YELLOW}  Kalimat pendek. Subjek + kata kerja.${NC}"
  echo -e "${YELLOW}  Hasil dulu, alasan belakangan.${NC}"
  echo -e "${YELLOW}  Hasil = bukti (output, exit code, angka).${NC}"
  echo -e "${CYAN}  Budget: MIKIR ≤10 baris | PLAN ≤15 | LAPOR ≤8${NC}"
  echo ""

  section "BLACKLIST KATA LUNAK"
  echo -e "${RED}  DILARANG:${NC}"
  echo -e "${RED}    mungkin | sepertinya | sebaiknya | nanti${NC}"
  echo -e "${RED}    kayaknya | harusnya${NC}"
  echo ""
  echo -e "${GREEN}  GANTI DENGAN:${NC}"
  echo -e "${GREEN}    angka | bukti | command | exit code${NC}"
  echo -e "${CYAN}    Ketidakpastian boleh — WAJIB bawa bukti:${NC}"
  echo -e "${CYAN}    '2 test merah, exit 1, file X:Y'${NC}"
  echo ""

  section "FORMAT LAPOR AKHIR"
  cat <<'LAPORAN'
  ┌────────────────────────────────────┐
  │ STATUS : SELESAI / GAGAL           │
  │ DIBUAT : <ringkas per item, ≤5>    │
  │ TEST   : PASS/FAIL + angka         │
  │ AUDIT  : CLEAN / X temuan—fixed    │
  │ MEMORI : tersimpan / tidak perlu   │
  └────────────────────────────────────┘
LAPORAN

  echo ""
  warn "Ramah tetap. Kasar tidak. Pendek selalu."
  warn "Nggak tanya kalau bisa coba. Nggak bilang 'mungkin nanti'."
  echo ""
  p "CAVEMAN: ON — semua kerja pakai marker wajib" 196

else
  p "STATUS: 😊 NORMAL MODE (polite)" 82
  echo ""

  section "MODE NORMAL"
  echo -e "${GREEN}  Penjelasan lengkap di samping kerja${NC}"
  echo -e "${GREEN}  Marker fase tetap dipakai (best practice):${NC}"
  echo -e "${CYAN}    [MIKIR] + 1-2 kalimat penjelasan${NC}"
  echo -e "${CYAN}    [BANGUN] + deskripsi perubahan${NC}"
  echo -e "${CYAN}    [TEST] + penjelasan hasil${NC}"
  echo -e "${CYAN}    [LAPOR] + ringkasan verbose${NC}"
  echo ""
  info "Pipeline TIDAK berubah. Test wajib. Audit wajib. Memori wajib."
  echo ""

  section "UBAH MODE"
  echo -e "${CYAN}  Aktifkan caveman: bash skills/caveman/run.sh on${NC}"
  echo -e "${CYAN}  Lihat status    : bash skills/caveman/run.sh status${NC}"
  echo ""
  p "CAVEMAN: OFF — mode normal aktif" 82
fi

echo ""
ok "Mode file: ${MODE_FILE}"
ok "Current  : $CURRENT_MODE"
echo ""
exit 0
