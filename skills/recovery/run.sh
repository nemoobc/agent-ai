#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  RECOVERY-RUN — workflow pemulihan bencana: inventory/restore/
#  verify/status. Backup = tiket pulang.
#  Jalankan: bash skills/recovery/run.sh <inventory|restore|verify|status>
#  Exit 0 = sukses, 1 = gagal/gerbang.
# ═════════════════════════════════════════════════════════════════
set -u

ACTION="${1:-status}"

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
BACKUP_DIR=".opencode/backups"
STATE_FILE=".opencode/recovery-state.txt"

echo ""
p "═══════════════════════════════════════════════" 196
p "   🔁 RECOVERY — WORKFLOW PEMULIHAN BENCANA    " 196
p "═══════════════════════════════════════════════" 196
echo ""
p "ACTION: $ACTION | $DATE $TIME" 45
echo ""

# ═══════════════════════════════════════════════════════════════════
# ACTION: status
# ═══════════════════════════════════════════════════════════════════
do_status() {
  section "STATUS RECOVERY"

  # Check state file
  if [ -f "$STATE_FILE" ]; then
    ok "State file ditemukan: $STATE_FILE"
    cat "$STATE_FILE" | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
  else
    info "Tidak ada state recovery aktif"
  fi

  # Check backup dir
  section "BACKUP TERSEDIA"
  if [ -d "$BACKUP_DIR" ]; then
    TOTAL_BACKUPS=$(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    ok "Backup dir: $BACKUP_DIR ($TOTAL_BACKUPS backup)"
    find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r | head -5 \
      | while IFS= read -r d; do
          NAME=$(basename "$d")
          SIZE=$(du -sh "$d" 2>/dev/null | cut -f1)
          BDATE=$(stat -c %y "$d" 2>/dev/null | cut -d' ' -f1)
          echo -e "${CYAN}    $BDATE  ${NAME}  (${SIZE})${NC}"
        done
  else
    bad "Backup dir tidak ditemukan: $BACKUP_DIR"
    warn "RISIKO TINGGI: tidak ada backup tersedia"
  fi

  # Check git status
  section "GIT STATUS"
  if git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo 'detached')
    ok "Branch: $BRANCH"
    GIT_STATUS=$(git status --short 2>/dev/null)
    if [ -n "$GIT_STATUS" ]; then
      warn "Perubahan uncommitted:"
      echo "$GIT_STATUS" | while IFS= read -r line; do echo -e "${YELLOW}    $line${NC}"; done
    else
      ok "Working tree bersih"
    fi
  fi

  # Check for critical files
  section "CEK FILE KRITIS"
  for f in package.json pyproject.toml go.mod Cargo.toml .env.example README.md; do
    [ -f "$f" ] && ok "$f ada" || info "$f tidak ada"
  done
}

# ═══════════════════════════════════════════════════════════════════
# ACTION: inventory
# ═══════════════════════════════════════════════════════════════════
do_inventory() {
  section "INVENTORY — DAFTAR SEMUA BACKUP"

  if [ ! -d "$BACKUP_DIR" ]; then
    bad "Backup dir tidak ada: $BACKUP_DIR"
    warn "Tidak ada backup untuk di-inventory"
    info "Buat backup dengan: skill backup atau snapshot"
    exit 1
  fi

  BACKUPS=$(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r)

  if [ -z "$BACKUPS" ]; then
    bad "Tidak ada backup di $BACKUP_DIR"
    exit 1
  fi

  p "  ── Daftar backup (terbaru dulu) ──" 45
  i=1
  echo "$BACKUPS" | while IFS= read -r d; do
    NAME=$(basename "$d")
    SIZE=$(du -sh "$d" 2>/dev/null | cut -f1)
    BDATE=$(stat -c %y "$d" 2>/dev/null | cut -d' ' -f1)
    FILE_COUNT=$(find "$d" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo ""
    echo -e "${BLUE}  [$i] $NAME${NC}"
    echo -e "${CYAN}      Date : $BDATE${NC}"
    echo -e "${CYAN}      Size : $SIZE${NC}"
    echo -e "${CYAN}      Files: $FILE_COUNT${NC}"

    # Read metadata if exists
    if [ -f "$d/metadata.txt" ]; then
      echo -e "${CYAN}      Meta :${NC}"
      cat "$d/metadata.txt" | while IFS= read -r line; do echo -e "${CYAN}             $line${NC}"; done
    fi

    # List top-level contents
    echo -e "${CYAN}      Content:${NC}"
    ls -1 "$d" 2>/dev/null | head -5 | while IFS= read -r f; do echo -e "${CYAN}        - $f${NC}"; done
    i=$((i+1))
  done

  echo ""
  ok "Inventory selesai"

  # Also check git stash
  section "GIT STASH"
  if git rev-parse --git-dir >/dev/null 2>&1; then
    STASH=$(git stash list 2>/dev/null)
    if [ -n "$STASH" ]; then
      info "Git stash entries:"
      echo "$STASH" | while IFS= read -r line; do echo -e "${CYAN}    $line${NC}"; done
    else
      info "Tidak ada git stash"
    fi

    info "Recent tags (bisa jadi restore point):"
    git tag --sort=-version:refname 2>/dev/null | head -5 \
      | while IFS= read -r tag; do echo -e "${CYAN}    $tag${NC}"; done
  fi
}

# ═══════════════════════════════════════════════════════════════════
# ACTION: restore
# ═══════════════════════════════════════════════════════════════════
do_restore() {
  section "RESTORE — PEMULIHAN DARI BACKUP"

  # Check backup exists
  if [ ! -d "$BACKUP_DIR" ]; then
    bad "Tidak ada backup dir: $BACKUP_DIR"
    bad "TIDAK BISA RESTORE — tidak ada backup"
    bad "Lapor ke user: 'tidak ada backup, butuh keputusan alternatif'"
    exit 1
  fi

  LATEST=$(ls -t "$BACKUP_DIR" 2>/dev/null | head -1)
  if [ -z "$LATEST" ]; then
    bad "Tidak ada backup di $BACKUP_DIR"
    exit 1
  fi

  RESTORE_PATH="$BACKUP_DIR/$LATEST"
  info "Backup terpilih (terbaru): $RESTORE_PATH"

  # DRY RUN DULU
  section "DRY RUN (tidak ada perubahan)"
  warn "=== DRY RUN — tidak ada file yang diubah ==="

  find "$RESTORE_PATH" -type f 2>/dev/null | head -20 \
    | while IFS= read -r f; do
        RELATIVE=$(echo "$f" | sed "s|$RESTORE_PATH/||")
        echo -e "${CYAN}    [DRY] restore: $f → $RELATIVE${NC}"
      done

  FILE_COUNT=$(find "$RESTORE_PATH" -type f 2>/dev/null | wc -l | tr -d ' ')
  info "Total file yang akan di-restore: $FILE_COUNT"

  echo ""
  warn "Dry run selesai."
  warn "Untuk restore aktual, edit script ini dan hapus flag DRY_RUN"
  warn "ATAU jalankan restore manual:"
  echo ""
  echo -e "${YELLOW}    # Restore manual:${NC}"
  echo -e "${YELLOW}    cp -r $RESTORE_PATH/. ./ ${NC}"
  echo ""
  warn "HATI-HATI: Restore akan menimpa file yang ada!"
  warn "Buat backup kondisi sekarang dulu jika belum ada"

  # Update state
  mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null
  cat > "$STATE_FILE" <<STATE
RECOVERY_STATE : DRY_RUN_SELESAI
DATE           : $DATE $TIME
BACKUP_USED    : $LATEST
STATUS         : Menunggu konfirmasi restore aktual
NEXT_STEP      : Jalankan restore manual atau verify setelah restore
STATE
  ok "State disimpan ke $STATE_FILE"
}

# ═══════════════════════════════════════════════════════════════════
# ACTION: verify
# ═══════════════════════════════════════════════════════════════════
do_verify() {
  section "VERIFY — VERIFIKASI SETELAH RECOVERY"

  ISSUES=0

  # Count files
  section "HITUNG FILE"
  TOTAL_SRC=$(find . -type f \
    \( -name '*.js' -o -name '*.ts' -o -name '*.py' -o -name '*.go' -o -name '*.rs' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/backups/*' \
    2>/dev/null | wc -l | tr -d ' ')
  info "Source files total: $TOTAL_SRC"

  # Check critical files exist
  section "CEK FILE KRITIS"
  for f in package.json pyproject.toml go.mod Cargo.toml; do
    if [ -f "$f" ]; then
      ok "$f ada"
    fi
  done

  # Run test-full
  section "TEST SETELAH RECOVERY"
  if [ -f "Makefile" ] && grep -q 'test-full\|test_full' Makefile 2>/dev/null; then
    info "Menjalankan: make test-full"
    if make test-full 2>&1 | tail -10; then
      ok "make test-full: PASS"
    else
      bad "make test-full: GAGAL — recovery belum selesai"
      ISSUES=$((ISSUES+1))
    fi
  elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
    info "Menjalankan: npm test"
    if npm test 2>&1 | tail -5; then
      ok "npm test: PASS"
    else
      bad "npm test: GAGAL"
      ISSUES=$((ISSUES+1))
    fi
  else
    warn "Test runner tidak ditemukan"
    warn "Jalankan manual: make test-full / npm test / pytest / go test ./..."
  fi

  # Spot check: ensure no corruption
  section "SPOT CHECK"
  CORRUPT=0
  while IFS= read -r f; do
        if python3 -c 'import json, sys; json.load(open(sys.argv[1]))' "$f" 2>/dev/null || \
           node -e 'require(process.argv[1])' "$f" 2>/dev/null; then
          ok "JSON valid: $f"
        else
          bad "JSON invalid/rusak: $f"
          CORRUPT=$((CORRUPT+1))
        fi
  done < <(find . -type f -name '*.json' -not -path '*/node_modules/*' -not -path '*/.git/*' \
    2>/dev/null | head -5)

  # Update state
  if [ "$ISSUES" -eq 0 ]; then
    cat > "$STATE_FILE" <<STATE
RECOVERY_STATE : SELESAI
DATE           : $DATE $TIME
TEST           : PASS
FILES          : $TOTAL_SRC source files
STATUS         : Recovery berhasil — sistem normal
STATE
    ok "State update: SELESAI"
  else
    cat > "$STATE_FILE" <<STATE
RECOVERY_STATE : PARTIAL
DATE           : $DATE $TIME
TEST           : FAIL ($ISSUES masalah)
FILES          : $TOTAL_SRC source files
STATUS         : Recovery belum selesai — ada $ISSUES masalah
STATE
  fi

  if [ "$ISSUES" -eq 0 ]; then
    ok "Verify PASS — recovery berhasil"
    p "VERIFY: SUKSES ✓" 82
    warn "LANGKAH SELANJUTNYA: jalankan postmortem"
    warn "  bash skills/postmortem/run.sh 'Recovery: <judul insiden>'"
  else
    bad "Verify GAGAL — $ISSUES masalah"
    bad "Sistem belum pulih sepenuhnya"
    p "VERIFY: GAGAL ✗" 196
    exit 1
  fi
}

# ═══════════════════════════════════════════════════════════════════
# DISPATCH
# ═══════════════════════════════════════════════════════════════════
case "$ACTION" in
  status)    do_status ;;
  inventory) do_inventory ;;
  restore)   do_restore ;;
  verify)    do_verify ;;
  *)
    bad "Action tidak valid: $ACTION"
    info "Pilihan: status | inventory | restore | verify"
    info "Contoh: bash skills/recovery/run.sh inventory"
    exit 1
    ;;
esac

echo ""
p "RECOVERY [$ACTION]: selesai" 82
exit 0
