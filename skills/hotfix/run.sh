#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  HOTFIX-RUN — workflow hotfix: checklist STOP/REPRO/FIX/BUKTI/
#  GUARD/VERIFY/POSTMORTEM, cek staged changes, git-guard, test.
#  Jalankan: bash skills/hotfix/run.sh "<issue_description>"
#  Exit 0 = hotfix siap, 1 = ada gerbang gagal.
# ═════════════════════════════════════════════════════════════════
set -u

ISSUE="${1:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ echo -e "${GREEN}  ✔ $1${NC}"; }
bad(){ echo -e "${RED}  ✖ $1${NC}"; GATES_FAILED=$((GATES_FAILED+1)); }
warn(){ echo -e "${YELLOW}  ⚠ $1${NC}"; }
info(){ echo -e "${CYAN}  ℹ $1${NC}"; }
section(){ echo -e "\n${BLUE}▸ $1${NC}"; }

GATES_FAILED=0
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

echo ""
p "═══════════════════════════════════════════════" 196
p "   🚨 HOTFIX — PRODUKSI DARURAT WORKFLOW       " 196
p "═══════════════════════════════════════════════" 196
echo ""

if [ -z "$ISSUE" ]; then
  warn "Tidak ada deskripsi issue. Gunakan: bash skills/hotfix/run.sh '<issue>'"
  warn "Contoh: bash skills/hotfix/run.sh 'Login gagal semua user sejak deploy 14:30'"
  echo ""
fi

p "ISSUE: ${ISSUE:-(tidak dideskripsikan)}" 214
p "WAKTU: $DATE $TIME" 214
echo ""

# ═══════════════════════════════════════════════════════════════════
# CHECKLIST HOTFIX
# ═══════════════════════════════════════════════════════════════════
section "FASE 1: STOP BLEEDING 🛑"
echo -e "${YELLOW}  [ ] Matikan/freeze fitur yang rusak (feature flag / rollback)${NC}"
echo -e "${YELLOW}  [ ] Pastikan DATA SELAMAT dulu sebelum fix apapun${NC}"
echo -e "${YELLOW}  [ ] Notifikasi team/stakeholder: 'sedang investigasi'${NC}"
echo -e "${CYAN}  ℹ  Rollback cepat lebih baik dari fix lambat di produksi${NC}"

section "FASE 2: REPRODUKSI 🔍"
echo -e "${YELLOW}  [ ] Catat exact error message${NC}"
echo -e "${YELLOW}  [ ] Catat input yang menyebabkan error${NC}"
echo -e "${YELLOW}  [ ] Buat minimal reproducible case${NC}"
echo -e "${YELLOW}  [ ] Konfirmasi: bug ter-reproduksi di lokal/staging${NC}"
echo -e "${RED}  ✖ DILARANG: fix tanpa reproduksi = tebak${NC}"

section "FASE 3: FIX SEMPIT 🔧"
echo -e "${YELLOW}  [ ] Identifikasi SATU akar masalah${NC}"
echo -e "${YELLOW}  [ ] Buat perubahan MINIMAL (idealnya 1 file)${NC}"
echo -e "${RED}  ✖ DILARANG: refactor sekalian, fitur baru, perubahan lain${NC}"
echo -e "${YELLOW}  [ ] Tulis test yang GAGAL dulu, baru fix${NC}"

section "FASE 4: BUKTI ✅"
echo -e "${YELLOW}  [ ] Test yang GAGAL sebelum fix → HIJAU setelah fix${NC}"
echo -e "${YELLOW}  [ ] Jalankan test-full${NC}"
echo -e "${YELLOW}  [ ] Capture output sebagai bukti${NC}"

section "FASE 5: GIT-GUARD 🔒"
echo -e "${YELLOW}  [ ] Periksa tidak ada secret/marker debug di kode${NC}"
echo -e "${YELLOW}  [ ] Periksa tidak ada console.log/print debug tertinggal${NC}"
echo -e "${YELLOW}  [ ] git diff --stat (konfirmasi perubahan sempit)${NC}"

section "FASE 6: VERIFY ✔"
echo -e "${YELLOW}  [ ] /verify penuh (HUKUM 9)${NC}"
echo -e "${YELLOW}  [ ] Test di staging sebelum produksi${NC}"
echo -e "${YELLOW}  [ ] Konfirmasi symptom sudah hilang${NC}"

section "FASE 7: POSTMORTEM 📝"
echo -e "${YELLOW}  [ ] Jalankan: bash skills/postmortem/run.sh '<judul>'${NC}"
echo -e "${YELLOW}  [ ] Catat di lessons.md: mengapa lolos, pencegahan${NC}"
echo -e "${RED}  ✖ HOTFIX TANPA POSTMORTEM = kecelakaan yang akan terulang${NC}"

# ═══════════════════════════════════════════════════════════════════
# AUTOMATED CHECKS
# ═══════════════════════════════════════════════════════════════════
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
p "  AUTOMATED CHECKS                             " 45
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45

# Check git status
section "GIT STATUS"
if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo 'detached')
  ok "Branch: $BRANCH"

  STAGED=$(git diff --cached --name-only 2>/dev/null)
  UNSTAGED=$(git diff --name-only 2>/dev/null)
  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)

  if [ -n "$STAGED" ]; then
    info "Staged files (siap commit):"
    echo "$STAGED" | while IFS= read -r f; do echo -e "${GREEN}    + $f${NC}"; done

    STAGED_COUNT=$(echo "$STAGED" | wc -l | tr -d ' ')
    if [ "$STAGED_COUNT" -gt 5 ]; then
      warn "Ada $STAGED_COUNT staged files — hotfix idealnya 1-3 file"
    else
      ok "$STAGED_COUNT staged file — ukuran wajar untuk hotfix"
    fi
  else
    warn "Tidak ada staged changes — apakah fix sudah dibuat?"
  fi

  if [ -n "$UNSTAGED" ]; then
    warn "Unstaged changes:"
    echo "$UNSTAGED" | while IFS= read -r f; do echo -e "${YELLOW}    ~ $f${NC}"; done
  fi

  # Check recent commits for the hotfix
  info "5 commit terakhir:"
  git log --oneline -5 2>/dev/null | while IFS= read -r line; do echo -e "${CYAN}    $line${NC}"; done

else
  warn "Bukan git repo — skip git checks"
fi

# Check for debug markers in staged files
section "GUARD CHECK"
if git rev-parse --git-dir >/dev/null 2>&1 && [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
  DEBUG_MARKERS=$(git diff --cached 2>/dev/null | grep '^+' | grep -vE '^\+\+\+' \
    | grep -iE '(console\.log|debugger|TODO.*hotfix|FIXME|HACK|print\(|var_dump|dd\(|binding\.pry|byebug)' \
    | head -10)

  if [ -n "$DEBUG_MARKERS" ]; then
    bad "Debug markers ditemukan di staged changes:"
    echo "$DEBUG_MARKERS" | while IFS= read -r line; do echo -e "${RED}    $line${NC}"; done
  else
    ok "Tidak ada debug markers di staged changes"
  fi

  # Check for hardcoded secrets
  SECRET_PATTERNS=$(git diff --cached 2>/dev/null | grep '^+' | grep -vE '^\+\+\+' \
    | grep -iE '(password\s*=\s*["\x27][^"\x27]{4,}|secret\s*=\s*["\x27][^"\x27]{4,}|api.?key\s*=\s*["\x27][^"\x27]{4,})' \
    | head -5)

  if [ -n "$SECRET_PATTERNS" ]; then
    bad "POTENSI SECRET di staged changes — cek manual!"
    echo "$SECRET_PATTERNS" | while IFS= read -r line; do echo -e "${RED}    $line${NC}"; done
  else
    ok "Tidak ada pola secret di staged changes"
  fi
else
  info "Tidak ada staged files — skip guard check"
fi

# Check for external git-guard script
section "GIT-GUARD EXTERNAL"
if [ -f "scripts/git-guard.sh" ]; then
  info "Menjalankan scripts/git-guard.sh..."
  if bash scripts/git-guard.sh 2>&1; then
    ok "git-guard: PASS"
  else
    bad "git-guard: GAGAL — ada masalah"
  fi
elif [ -f ".opencode/git-guard.sh" ]; then
  info "Menjalankan .opencode/git-guard.sh..."
  if bash .opencode/git-guard.sh 2>&1; then
    ok "git-guard: PASS"
  else
    bad "git-guard: GAGAL"
  fi
else
  warn "git-guard script tidak ditemukan — skip"
  info "Expected di: scripts/git-guard.sh atau .opencode/git-guard.sh"
fi

# Run test-full
section "TEST-FULL"
TEST_PASSED=0
if [ -f "Makefile" ] && grep -q "test-full\|test_full" Makefile 2>/dev/null; then
  info "Menjalankan: make test-full"
  if make test-full 2>&1; then
    ok "make test-full: PASS"
    TEST_PASSED=1
  else
    bad "make test-full: GAGAL — hotfix belum selesai"
  fi
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  info "Menjalankan: npm test"
  if npm test 2>&1; then
    ok "npm test: PASS"
    TEST_PASSED=1
  else
    bad "npm test: GAGAL — hotfix belum selesai"
  fi
elif [ -f "Makefile" ] && grep -q "^test:" Makefile 2>/dev/null; then
  info "Menjalankan: make test"
  if make test 2>&1; then
    ok "make test: PASS"
    TEST_PASSED=1
  else
    bad "make test: GAGAL"
  fi
else
  warn "Test runner tidak ditemukan — jalankan manual"
  warn "Pilihan: make test-full / npm test / pytest / go test ./..."
fi

# ═══════════════════════════════════════════════════════════════════
# HOTFIX REPORT OUTPUT
# ═══════════════════════════════════════════════════════════════════
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 213
p "  HOTFIX REPORT FORMAT                         " 213
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 213
echo ""

cat <<'TEMPLATE'
─────────────────────────────────────────────────
HOTFIX  : <gejala> → <akar masalah> → <fix minimal>
WAKTU   : <kapan insiden> → <kapan ketahuan> → <kapan fix>
BUKTI   : test X MERAH sebelum → HIJAU setelah (N/N), audit CLEAN
FILE    : <file:baris yang berubah — minimal>
DAMPAK  : <berapa user/request terdampak>
POSTMORTEM: lessons.md entry + aksi pencegahan
─────────────────────────────────────────────────
TEMPLATE

echo ""
p "═══════════════════════════════════════════════" 213
p "         HOTFIX CHECKLIST SUMMARY              " 213
p "═══════════════════════════════════════════════" 213
echo ""

if [ "$GATES_FAILED" -eq 0 ]; then
  ok "Semua automated checks PASS"
  ok "Lanjutkan dengan manual checklist di atas"
  p "HOTFIX: automated checks BERSIH ✓" 82
  exit 0
else
  bad "$GATES_FAILED automated gate(s) GAGAL"
  bad "Fix semua issue di atas sebelum deploy hotfix"
  p "HOTFIX: $GATES_FAILED GATE GAGAL ✗" 196
  exit 1
fi
