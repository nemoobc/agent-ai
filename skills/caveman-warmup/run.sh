#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  CAVEMAN-WARMUP-RUN — session warmup greeter: PROFIL RINGKAS
#  A/B/C, baca profile dari memory, tampilkan konteks sesi lalu.
#  Jalankan: bash skills/caveman-warmup/run.sh
#  Exit 0.
# ═════════════════════════════════════════════════════════════════
set -u

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

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
MEMORY_DIR=".opencode/memory"
MODE_FILE="$MEMORY_DIR/mode.txt"
SESSION_LOG=".opencode/session-log.md"
PROFILE_FILE="$MEMORY_DIR/profile.txt"

echo ""
p "═══════════════════════════════════════════════" 213
p "   🌅 CAVEMAN-WARMUP — SELAMAT DATANG KEMBALI  " 213
p "═══════════════════════════════════════════════" 213
echo ""
p "Sesi: $DATE $TIME" 45
echo ""

# ── Baca profil saat ini ──────────────────────────────────────────
CURRENT_PROFILE="A"
CURRENT_MODE="on"

if [ -f "$PROFILE_FILE" ]; then
  RAW_PROFILE=$(cat "$PROFILE_FILE" 2>/dev/null | tr '[:lower:]' '[:upper:]' | tr -d ' \n')
  case "$RAW_PROFILE" in
    A) CURRENT_PROFILE="A"; CURRENT_MODE="on" ;;
    B) CURRENT_PROFILE="B"; CURRENT_MODE="off" ;;
    C) CURRENT_PROFILE="C"; CURRENT_MODE="off" ;;
    *) CURRENT_PROFILE="A"; CURRENT_MODE="on" ;;
  esac
  info "Profil tersimpan ditemukan: $CURRENT_PROFILE"
elif [ -f "$MODE_FILE" ]; then
  MODE_RAW=$(cat "$MODE_FILE" 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr -d ' \n')
  case "$MODE_RAW" in
    on|caveman|ultra|a) CURRENT_PROFILE="A"; CURRENT_MODE="on" ;;
    b|normal) CURRENT_PROFILE="B"; CURRENT_MODE="off" ;;
    c|santai) CURRENT_PROFILE="C"; CURRENT_MODE="off" ;;
    *) CURRENT_PROFILE="A" ;;
  esac
  info "Mode ditemukan di mode.txt: $MODE_RAW → Profil $CURRENT_PROFILE"
else
  info "Tidak ada profil tersimpan — default A"
fi

# ── Tampilkan konteks sesi lalu ───────────────────────────────────
section "KONTEKS SESI TERAKHIR"

SESSION_SHOWN=0

# Baca session log
if [ -f "$SESSION_LOG" ]; then
  SESSION_SHOWN=1
  info "Session log ditemukan: $SESSION_LOG"
  echo ""
  p "  ── Ringkasan sesi lalu ──" 45
  # Show last ~20 lines of session log
  tail -20 "$SESSION_LOG" 2>/dev/null | while IFS= read -r line; do
    echo -e "${CYAN}  $line${NC}"
  done
fi

# Baca handoff jika ada
if [ -f ".opencode/handoff.md" ]; then
  SESSION_SHOWN=1
  echo ""
  p "  ── Handoff tersimpan ──" 45
  head -30 ".opencode/handoff.md" 2>/dev/null | while IFS= read -r line; do
    echo -e "${CYAN}  $line${NC}"
  done
fi

# Baca git log singkat
if git rev-parse --git-dir >/dev/null 2>&1; then
  SESSION_SHOWN=1
  echo ""
  p "  ── Git: 5 commit terakhir ──" 45
  git log --oneline -5 2>/dev/null | while IFS= read -r line; do
    echo -e "${CYAN}    $line${NC}"
  done

  BRANCH=$(git branch --show-current 2>/dev/null || echo 'detached')
  STATUS_CLEAN=$(git status --short 2>/dev/null | grep -c . || echo 0)
  if [ "$STATUS_CLEAN" -gt 0 ]; then
    warn "Ada $STATUS_CLEAN file tidak di-commit"
  else
    ok "Working tree bersih"
  fi
fi

# Baca memory files ringkas
if [ -d "$MEMORY_DIR" ]; then
  TODO_FILE=$(ls "$MEMORY_DIR"/todo*.md "$MEMORY_DIR"/todo*.txt 2>/dev/null | head -1)
  if [ -n "$TODO_FILE" ] && [ -f "$TODO_FILE" ]; then
    SESSION_SHOWN=1
    echo ""
    p "  ── Todo/Sisa kerja ──" 45
    grep -E '^\s*[-*]\s*\[ \]' "$TODO_FILE" 2>/dev/null | head -5 \
      | while IFS= read -r line; do echo -e "${YELLOW}  $line${NC}"; done
  fi
fi

if [ "$SESSION_SHOWN" -eq 0 ]; then
  info "Tidak ada konteks sesi lalu ditemukan"
  info "Lokasi yang dicek: $SESSION_LOG, .opencode/handoff.md, git log"
fi

# ── PROFIL RINGKAS ────────────────────────────────────────────────
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 213
p "  PROFIL RINGKAS (pilih 1):                   " 213
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 213
echo ""

if [ "$CURRENT_PROFILE" = "A" ]; then
  echo -e "${GREEN}► A) NYALA   — kerja cepat, laporan caveman ULTRA (AKTIF)${NC}"
  echo -e "${CYAN}  B) Normal  — penjelasan lengkap di samping kerja${NC}"
  echo -e "${CYAN}  C) Santai  — bicara biasa, kerja tetap rapi${NC}"
elif [ "$CURRENT_PROFILE" = "B" ]; then
  echo -e "${CYAN}  A) NYALA   — kerja cepat, laporan caveman ULTRA${NC}"
  echo -e "${GREEN}► B) Normal  — penjelasan lengkap di samping kerja (AKTIF)${NC}"
  echo -e "${CYAN}  C) Santai  — bicara biasa, kerja tetap rapi${NC}"
else
  echo -e "${CYAN}  A) NYALA   — kerja cepat, laporan caveman ULTRA${NC}"
  echo -e "${CYAN}  B) Normal  — penjelasan lengkap di samping kerja${NC}"
  echo -e "${GREEN}► C) Santai  — bicara biasa, kerja tetap rapi (AKTIF)${NC}"
fi

echo ""
warn "Tanpa jawaban → otomatis A dalam 30 detik"
echo ""

# ── Mode saat ini ─────────────────────────────────────────────────
section "MODE SEKARANG: PROFIL $CURRENT_PROFILE"

case "$CURRENT_PROFILE" in
  A)
    p "  🪨 CAVEMAN ULTRA — AKTIF" 196
    echo ""
    echo -e "${YELLOW}  Marker wajib setiap fase:${NC}"
    echo -e "${YELLOW}    [MIKIR] ≤10 baris${NC}"
    echo -e "${GREEN}    [BANGUN] N file diubah${NC}"
    echo -e "${CYAN}    [TEST] N/N PASS${NC}"
    echo -e "${BLUE}    [AUDIT] CLEAN${NC}"
    echo -e "${GREEN}    [LAPOR] ≤8 baris${NC}"
    echo ""
    echo -e "${RED}  Blacklist: mungkin | sepertinya | sebaiknya | kayaknya | harusnya | nanti${NC}"
    ;;
  B)
    p "  😊 NORMAL — AKTIF" 82
    echo ""
    info "Marker fase tetap dipakai + penjelasan 1-2 kalimat"
    info "Pipeline penuh tetap jalan (test, audit, memori)"
    ;;
  C)
    p "  ☕ SANTAI — AKTIF" 45
    echo ""
    info "Bicara biasa, kerja tetap rapi"
    info "Marker fase opsional, tapi kerja tidak downgrade"
    info "Test wajib. Audit wajib. Memori wajib."
    ;;
esac

# ── Catatan penting ───────────────────────────────────────────────
section "CATATAN"
echo -e "${CYAN}  • Kerja TIDAK berubah di mode mana pun${NC}"
echo -e "${CYAN}  • Yang berubah: gaya narasi saja${NC}"
echo -e "${CYAN}  • User kasih tugas → langsung A (mode apapun)${NC}"
echo -e "${CYAN}  • 'gas' / 'gaspol' / 'full' → langsung A${NC}"
echo -e "${CYAN}  • 'santai dulu' / 'pelan' → C/B sampai tugas berikut${NC}"
echo ""

# ── Ubah profil jika diinginkan ───────────────────────────────────
section "GANTI PROFIL"
echo -e "${CYAN}  Aktifkan A: bash skills/caveman/run.sh on${NC}"
echo -e "${CYAN}  Aktifkan B: bash skills/caveman/run.sh off && echo B > $PROFILE_FILE${NC}"
echo -e "${CYAN}  Aktifkan C: bash skills/caveman/run.sh off && echo C > $PROFILE_FILE${NC}"
echo ""

# ── Save default jika belum ada ───────────────────────────────────
if [ ! -f "$PROFILE_FILE" ]; then
  mkdir -p "$MEMORY_DIR" 2>/dev/null
  echo "A" > "$PROFILE_FILE"
  info "Profil default A disimpan ke $PROFILE_FILE"
fi

# ── Update session log ────────────────────────────────────────────
mkdir -p "$(dirname "$SESSION_LOG")" 2>/dev/null
cat >> "$SESSION_LOG" <<SESSION_ENTRY

---
## Sesi $DATE $TIME
- Profil: $CURRENT_PROFILE
- Mode  : $CURRENT_MODE
SESSION_ENTRY

echo ""
p "═══════════════════════════════════════════════" 213
p "         WARMUP SELESAI — SIAP BEKERJA!        " 213
p "═══════════════════════════════════════════════" 213
echo ""
ok "Profil aktif: $CURRENT_PROFILE"
ok "Mode       : $CURRENT_MODE"
info "Kasih tugas atau pilih profil — saya siap."
echo ""
exit 0
