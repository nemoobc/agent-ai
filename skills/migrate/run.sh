#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  MIGRATE-RUN — migration runner: check/snapshot/run/verify/
#  rollback. Tanpa snapshot = DILARANG jalan.
#  Jalankan: bash skills/migrate/run.sh <check|snapshot|run|verify|rollback>
#  Exit 0 = sukses, 1 = gagal/gerbang.
# ═════════════════════════════════════════════════════════════════
set -u

ACTION="${1:-check}"

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
TIME=$(date +%H%M%S)
SNAPSHOT_DIR=".opencode/backups/migrations"
MIGRATIONS_DIR=""

# Detect migrations dir
for d in migrations db/migrations database/migrations prisma/migrations alembic/versions; do
  [ -d "$d" ] && MIGRATIONS_DIR="$d" && break
done

echo ""
p "═══════════════════════════════════════════════" 213
p "     🗄️  MIGRATE — DATABASE MIGRATION RUNNER   " 213
p "═══════════════════════════════════════════════" 213
echo ""
p "ACTION: $ACTION | $DATE $TIME" 45
echo ""

# ── Detect migration tool ────────────────────────────────────────
MIGRATE_TOOL=""
MIGRATE_CMD=""

detect_tool() {
  if [ -f "package.json" ] && grep -q '"prisma"' package.json 2>/dev/null; then
    MIGRATE_TOOL="prisma"
    MIGRATE_CMD="npx prisma migrate"
  elif [ -f "manage.py" ]; then
    MIGRATE_TOOL="django"
    MIGRATE_CMD="python manage.py"
  elif [ -f "alembic.ini" ]; then
    MIGRATE_TOOL="alembic"
    MIGRATE_CMD="alembic"
  elif command -v flyway >/dev/null 2>&1; then
    MIGRATE_TOOL="flyway"
    MIGRATE_CMD="flyway"
  elif [ -f "Makefile" ] && grep -q 'migrate' Makefile 2>/dev/null; then
    MIGRATE_TOOL="make"
    MIGRATE_CMD="make"
  fi
}
detect_tool

# ═══════════════════════════════════════════════════════════════════
# ACTION: check
# ═══════════════════════════════════════════════════════════════════
do_check() {
  section "CHECK — PENDING MIGRATIONS"

  if [ -n "$MIGRATE_TOOL" ]; then
    info "Tool: $MIGRATE_TOOL"
  else
    warn "Migration tool tidak terdeteksi otomatis"
  fi

  # Show migrations directory
  if [ -n "$MIGRATIONS_DIR" ]; then
    ok "Migrations dir: $MIGRATIONS_DIR"
    TOTAL_MIG=$(find "$MIGRATIONS_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
    info "Total migration files: $TOTAL_MIG"
    echo ""
    p "  ── File migrasi (terbaru 10) ──" 45
    find "$MIGRATIONS_DIR" -type f 2>/dev/null | sort -r | head -10 \
      | while IFS= read -r f; do
          FNAME=$(basename "$f")
          FDATE=$(stat -c %y "$f" 2>/dev/null | cut -d' ' -f1)
          echo -e "${CYAN}    $FDATE  $FNAME${NC}"
        done
  else
    warn "Direktori migrations tidak ditemukan"
    info "Cek: migrations/, db/migrations/, prisma/migrations/, alembic/versions/"
  fi

  # Tool-specific status
  case "$MIGRATE_TOOL" in
    prisma)
      info "Menjalankan: npx prisma migrate status"
      npx prisma migrate status 2>&1 | head -30 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
      ;;
    django)
      info "Menjalankan: python manage.py showmigrations"
      python manage.py showmigrations 2>&1 | head -30 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
      ;;
    alembic)
      info "Menjalankan: alembic current"
      alembic current 2>&1 | head -20 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
      info "Menjalankan: alembic history --verbose"
      alembic history --verbose 2>&1 | head -20 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
      ;;
    *)
      warn "Jalankan manual: $MIGRATE_CMD status / show"
      ;;
  esac

  # Check snapshot exists
  if [ -d "$SNAPSHOT_DIR" ] && [ -n "$(ls -A "$SNAPSHOT_DIR" 2>/dev/null)" ]; then
    LATEST=$(ls -t "$SNAPSHOT_DIR" 2>/dev/null | head -1)
    ok "Snapshot tersedia: $LATEST"
  else
    bad "TIDAK ADA SNAPSHOT — jalankan 'snapshot' dulu sebelum 'run'"
  fi

  ok "check selesai"
}

# ═══════════════════════════════════════════════════════════════════
# ACTION: snapshot
# ═══════════════════════════════════════════════════════════════════
do_snapshot() {
  section "SNAPSHOT — BACKUP SEBELUM MIGRASI"

  mkdir -p "$SNAPSHOT_DIR" 2>/dev/null
  SNAP_NAME="snapshot-${DATE}-${TIME}"
  SNAP_PATH="$SNAPSHOT_DIR/$SNAP_NAME"
  mkdir -p "$SNAP_PATH"

  ok "Membuat snapshot: $SNAP_PATH"

  # Snapshot schema files
  SCHEMA_FILES=0
  for schema_f in \
    prisma/schema.prisma \
    db/schema.rb \
    db/schema.sql \
    schema.sql \
    database/schema.sql \
    models.py \
    src/models \
    app/models; do
    if [ -f "$schema_f" ]; then
      cp "$schema_f" "$SNAP_PATH/" 2>/dev/null && ok "Snapshot: $schema_f" && SCHEMA_FILES=$((SCHEMA_FILES+1))
    elif [ -d "$schema_f" ]; then
      cp -r "$schema_f" "$SNAP_PATH/" 2>/dev/null && ok "Snapshot dir: $schema_f" && SCHEMA_FILES=$((SCHEMA_FILES+1))
    fi
  done

  # Snapshot migrations dir
  if [ -n "$MIGRATIONS_DIR" ] && [ -d "$MIGRATIONS_DIR" ]; then
    cp -r "$MIGRATIONS_DIR" "$SNAP_PATH/migrations_backup" 2>/dev/null
    ok "Snapshot migrations: $MIGRATIONS_DIR"
    SCHEMA_FILES=$((SCHEMA_FILES+1))
  fi

  # Git snapshot
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git log --oneline -5 2>/dev/null > "$SNAP_PATH/git-log.txt"
    git status --short 2>/dev/null > "$SNAP_PATH/git-status.txt"
    ok "Snapshot git state ke $SNAP_PATH/git-log.txt"
  fi

  # Record metadata
  cat > "$SNAP_PATH/metadata.txt" <<META
SNAPSHOT: $SNAP_NAME
DATE    : $DATE $TIME
TOOL    : ${MIGRATE_TOOL:-(unknown)}
FILES   : $SCHEMA_FILES items
PURPOSE : Pre-migration backup
META

  if [ "$SCHEMA_FILES" -eq 0 ]; then
    warn "Tidak ada file schema ditemukan untuk di-snapshot"
    warn "Snapshot direktori kosong: $SNAP_PATH"
    warn "Pastikan snapshot dari DB dump juga (pg_dump / mysqldump)"
  else
    ok "$SCHEMA_FILES item disimpan ke snapshot"
  fi

  ok "Snapshot selesai: $SNAP_PATH"
  p "SNAPSHOT: $SNAP_PATH" 82
}

# ═══════════════════════════════════════════════════════════════════
# ACTION: run
# ═══════════════════════════════════════════════════════════════════
do_run() {
  section "RUN — JALANKAN MIGRASI"

  # GERBANG: harus ada snapshot
  if [ ! -d "$SNAPSHOT_DIR" ] || [ -z "$(ls -A "$SNAPSHOT_DIR" 2>/dev/null)" ]; then
    bad "GERBANG: Tidak ada snapshot ditemukan!"
    bad "WAJIB jalankan snapshot dulu: bash skills/migrate/run.sh snapshot"
    bad "DILARANG migrasi tanpa snapshot — data hilang tidak bisa dikembalikan"
    exit 1
  fi

  LATEST_SNAP=$(ls -t "$SNAPSHOT_DIR" 2>/dev/null | head -1)
  ok "Snapshot tersedia: $LATEST_SNAP"

  # Count records before (heuristic)
  section "HITUNG SEBELUM"
  BEFORE_COUNT=0
  if [ -n "$MIGRATIONS_DIR" ]; then
    BEFORE_COUNT=$(find "$MIGRATIONS_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
    info "Migration files sebelum: $BEFORE_COUNT"
  fi

  # Run
  section "EKSEKUSI MIGRASI"
  case "$MIGRATE_TOOL" in
    prisma)
      info "Menjalankan: npx prisma migrate deploy"
      if npx prisma migrate deploy 2>&1; then
        ok "Prisma migrate deploy: SUKSES"
      else
        bad "Prisma migrate deploy: GAGAL"
        warn "Jalankan rollback: bash skills/migrate/run.sh rollback"
        exit 1
      fi
      ;;
    django)
      info "Menjalankan: python manage.py migrate"
      if python manage.py migrate 2>&1; then
        ok "Django migrate: SUKSES"
      else
        bad "Django migrate: GAGAL"
        exit 1
      fi
      ;;
    alembic)
      info "Menjalankan: alembic upgrade head"
      if alembic upgrade head 2>&1; then
        ok "Alembic upgrade head: SUKSES"
      else
        bad "Alembic upgrade head: GAGAL"
        exit 1
      fi
      ;;
    make)
      if grep -q 'migrate:' Makefile 2>/dev/null; then
        info "Menjalankan: make migrate"
        if make migrate 2>&1; then
          ok "make migrate: SUKSES"
        else
          bad "make migrate: GAGAL"
          exit 1
        fi
      else
        warn "Target 'migrate' tidak ada di Makefile"
        warn "Jalankan migration tool secara manual"
      fi
      ;;
    *)
      warn "Tidak ada tool terdeteksi — jalankan migrasi secara manual"
      warn "Setelah selesai, jalankan: bash skills/migrate/run.sh verify"
      ;;
  esac

  ok "run selesai — jalankan verify: bash skills/migrate/run.sh verify"
}

# ═══════════════════════════════════════════════════════════════════
# ACTION: verify
# ═══════════════════════════════════════════════════════════════════
do_verify() {
  section "VERIFY — VERIFIKASI SETELAH MIGRASI"

  ISSUES=0

  # Count migration files after
  if [ -n "$MIGRATIONS_DIR" ] && [ -d "$MIGRATIONS_DIR" ]; then
    AFTER_COUNT=$(find "$MIGRATIONS_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
    info "Migration files sekarang: $AFTER_COUNT"
  fi

  # Check schema consistency
  section "CEK SKEMA"
  case "$MIGRATE_TOOL" in
    prisma)
      info "Menjalankan: npx prisma migrate status"
      STATUS_OUT=$(npx prisma migrate status 2>&1)
      echo "$STATUS_OUT" | head -20 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
      if echo "$STATUS_OUT" | grep -qi 'pending\|failed\|drift'; then
        bad "Status migrasi: ada masalah"
        ISSUES=$((ISSUES+1))
      else
        ok "Prisma migrate status: OK"
      fi
      ;;
    django)
      info "Menjalankan: python manage.py migrate --check"
      if python manage.py migrate --check 2>&1; then
        ok "Django: tidak ada pending migration"
      else
        bad "Django: masih ada pending migration"
        ISSUES=$((ISSUES+1))
      fi
      ;;
    alembic)
      info "Menjalankan: alembic current"
      alembic current 2>&1 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
      ;;
    *)
      warn "Verifikasi manual diperlukan untuk tool: ${MIGRATE_TOOL:-(unknown)}"
      ;;
  esac

  # Run test-full if available
  section "TEST SETELAH MIGRASI"
  if [ -f "Makefile" ] && grep -q 'test-full\|test_full' Makefile 2>/dev/null; then
    info "Menjalankan: make test-full"
    if make test-full 2>&1; then
      ok "make test-full: PASS"
    else
      bad "make test-full: GAGAL — migrasi mungkin bermasalah"
      ISSUES=$((ISSUES+1))
    fi
  elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
    info "Menjalankan: npm test"
    if npm test 2>&1; then
      ok "npm test: PASS"
    else
      bad "npm test: GAGAL"
      ISSUES=$((ISSUES+1))
    fi
  else
    warn "Test runner tidak ditemukan — jalankan manual"
  fi

  if [ "$ISSUES" -eq 0 ]; then
    ok "Verifikasi PASS ✓"
    p "VERIFY: SUKSES ✓" 82
  else
    bad "Verifikasi GAGAL — $ISSUES masalah"
    bad "Pertimbangkan rollback: bash skills/migrate/run.sh rollback"
    p "VERIFY: GAGAL ✗" 196
    exit 1
  fi
}

# ═══════════════════════════════════════════════════════════════════
# ACTION: rollback
# ═══════════════════════════════════════════════════════════════════
do_rollback() {
  section "ROLLBACK — DAFTAR SNAPSHOT TERSEDIA"

  if [ ! -d "$SNAPSHOT_DIR" ]; then
    bad "Tidak ada snapshot dir: $SNAPSHOT_DIR"
    bad "Tidak bisa rollback tanpa snapshot"
    exit 1
  fi

  SNAPS=$(ls -t "$SNAPSHOT_DIR" 2>/dev/null)
  if [ -z "$SNAPS" ]; then
    bad "Tidak ada snapshot tersedia di $SNAPSHOT_DIR"
    exit 1
  fi

  p "  ── Snapshot tersedia ──" 45
  i=1
  echo "$SNAPS" | while IFS= read -r snap; do
    SNAP_META="$SNAPSHOT_DIR/$snap/metadata.txt"
    if [ -f "$SNAP_META" ]; then
      META_DATE=$(grep 'DATE' "$SNAP_META" 2>/dev/null | sed 's/DATE.*: //')
      echo -e "${CYAN}  [$i] $snap${NC} — ${META_DATE}"
    else
      echo -e "${CYAN}  [$i] $snap${NC}"
    fi
    i=$((i+1))
  done

  echo ""
  warn "ROLLBACK MEMERLUKAN TINDAKAN MANUAL:"
  info "1. Pilih snapshot dari daftar di atas"
  info "2. Restore schema dari snapshot: cp <snapshot>/*.prisma prisma/"
  info "3. Jalankan down-migration untuk tool Anda:"

  case "$MIGRATE_TOOL" in
    prisma)  info "   npx prisma migrate reset (HATI-HATI: hapus data!)" ;;
    django)  info "   python manage.py migrate <app> <migration_name>" ;;
    alembic) info "   alembic downgrade <revision>" ;;
    *)       info "   Lihat dokumentasi tool migration Anda" ;;
  esac

  info "4. Verifikasi: bash skills/migrate/run.sh verify"
  echo ""
  warn "HATI-HATI: Rollback bisa menghilangkan data yang sudah masuk sejak migrasi"
  warn "Konfirmasi dengan user/stakeholder sebelum rollback di produksi"

  ok "Daftar rollback selesai"
  p "ROLLBACK: lihat opsi di atas — tindakan manual diperlukan" 214
}

# ═══════════════════════════════════════════════════════════════════
# DISPATCH
# ═══════════════════════════════════════════════════════════════════
case "$ACTION" in
  check)    do_check ;;
  snapshot) do_snapshot ;;
  run)      do_run ;;
  verify)   do_verify ;;
  rollback) do_rollback ;;
  *)
    bad "Action tidak valid: $ACTION"
    info "Pilihan: check | snapshot | run | verify | rollback"
    info "Contoh: bash skills/migrate/run.sh check"
    exit 1
    ;;
esac

echo ""
p "MIGRATE [$ACTION]: selesai" 82
exit 0
