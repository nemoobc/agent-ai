#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  PR-RUN — generator deskripsi PR: baca diff, deteksi tipe perubahan,
#  generate JUDUL/RINGKASAN/PERUBAHAN/BUKTI/CHECKLIST.
#  Baca .github/PULL_REQUEST_TEMPLATE.md jika ada.
#  Jalankan: bash skills/pr/run.sh [base_branch]
#  Exit 0 = siap PR, 1 = ada gerbang gagal.
# ═════════════════════════════════════════════════════════════════
set -u

BASE="${1:-main}"

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

echo ""
p "═══════════════════════════════════════════════" 213
p "     🔀 PR — PULL REQUEST DESCRIPTION BUILDER  " 213
p "═══════════════════════════════════════════════" 213
echo ""

# ── Verify git ───────────────────────────────────────────────────
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  bad "Bukan git repo"
  exit 1
fi

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo 'HEAD')
info "Branch saat ini: $CURRENT_BRANCH"
info "Base branch: $BASE"

# ── Get diff ─────────────────────────────────────────────────────
section "BACA DIFF"

DIFF_STAT=""
DIFF_FILES=""
DIFF_CONTENT=""

# Try branch diff first
if git show-ref --verify --quiet "refs/heads/$BASE" 2>/dev/null || \
   git show-ref --verify --quiet "refs/remotes/origin/$BASE" 2>/dev/null; then
  DIFF_STAT=$(git diff "$BASE...HEAD" --stat 2>/dev/null)
  DIFF_FILES=$(git diff "$BASE...HEAD" --name-only 2>/dev/null)
  DIFF_CONTENT=$(git diff "$BASE...HEAD" 2>/dev/null | head -200)
  ok "Diff dari: $BASE...HEAD"
else
  # Fall back to staged changes
  DIFF_STAT=$(git diff --cached --stat 2>/dev/null)
  DIFF_FILES=$(git diff --cached --name-only 2>/dev/null)
  DIFF_CONTENT=$(git diff --cached 2>/dev/null | head -200)
  warn "Branch '$BASE' tidak ditemukan — menggunakan staged changes (--cached)"
fi

if [ -z "$DIFF_FILES" ]; then
  warn "Tidak ada perubahan ditemukan"
  info "Pastikan ada commit di atas $BASE, atau ada staged changes"
  info "Gunakan: git diff main...HEAD atau git diff --cached"
fi

# Count file changes
TOTAL_FILES=$(echo "$DIFF_FILES" | grep -c . 2>/dev/null || echo 0)
ADDED_LINES=$(echo "$DIFF_STAT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' | awk '{s+=$1}END{print s+0}')
REMOVED_LINES=$(echo "$DIFF_STAT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' | awk '{s+=$1}END{print s+0}')

info "Files berubah: $TOTAL_FILES"
info "Baris ditambah: +${ADDED_LINES}"
info "Baris dihapus: -${REMOVED_LINES}"

# ── Deteksi tipe perubahan ───────────────────────────────────────
section "DETEKSI TIPE PERUBAHAN"

PR_TYPE="chore"
PR_SCOPE=""

# Check commit messages for type
COMMITS=$(git log "$BASE...HEAD" --oneline 2>/dev/null || git log --oneline -10 2>/dev/null)

if echo "$COMMITS" | grep -qiE '^[a-f0-9]+ (feat|feature|add):'; then
  PR_TYPE="feat"
elif echo "$COMMITS" | grep -qiE '^[a-f0-9]+ (fix|hotfix|bug):'; then
  PR_TYPE="fix"
elif echo "$COMMITS" | grep -qiE '^[a-f0-9]+ (refactor|refac):'; then
  PR_TYPE="refactor"
elif echo "$COMMITS" | grep -qiE '^[a-f0-9]+ (docs?|doc):'; then
  PR_TYPE="docs"
elif echo "$COMMITS" | grep -qiE '^[a-f0-9]+ (test|spec):'; then
  PR_TYPE="test"
elif echo "$COMMITS" | grep -qiE '^[a-f0-9]+ (perf|performance):'; then
  PR_TYPE="perf"
elif echo "$COMMITS" | grep -qiE '^[a-f0-9]+ (style|format):'; then
  PR_TYPE="style"
else
  # Fallback: detect from files changed
  if echo "$DIFF_FILES" | grep -qE '\.(md|txt|rst)$'; then
    PR_TYPE="docs"
  elif echo "$DIFF_FILES" | grep -qE '\.(test|spec)\.(js|ts|py)$|test_.*\.py$|_test\.go$'; then
    PR_TYPE="test"
  fi
fi

ok "Tipe PR terdeteksi: $PR_TYPE"

# Detect scope from most changed directory
SCOPE_DIR=$(echo "$DIFF_FILES" | awk -F/ '{print $1}' | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
[ -n "$SCOPE_DIR" ] && PR_SCOPE="($SCOPE_DIR)" && info "Scope: $SCOPE_DIR"

# ── Get commits list ─────────────────────────────────────────────
section "COMMIT LIST"
if [ -n "$COMMITS" ]; then
  echo "$COMMITS" | head -10 | while IFS= read -r line; do echo -e "${CYAN}    $line${NC}"; done
fi

# ── Check PR template ────────────────────────────────────────────
section "PR TEMPLATE"
PR_TEMPLATE_CONTENT=""
TEMPLATE_PATH=""

for tp in .github/PULL_REQUEST_TEMPLATE.md .github/pull_request_template.md PULL_REQUEST_TEMPLATE.md; do
  if [ -f "$tp" ]; then
    TEMPLATE_PATH="$tp"
    PR_TEMPLATE_CONTENT=$(cat "$tp" 2>/dev/null)
    ok "PR template ditemukan: $tp"
    break
  fi
done

[ -z "$TEMPLATE_PATH" ] && info "PR template tidak ditemukan — menggunakan template default"

# ── Run tests ────────────────────────────────────────────────────
section "GATE CHECK: TEST"

TEST_STATUS="belum dijalankan"
TEST_RESULT_LINE="belum dijalankan"

if [ -f "Makefile" ] && grep -q 'test-full\|test_full' Makefile 2>/dev/null; then
  info "Menjalankan: make test-full"
  if make test-full 2>&1 | tail -5; then
    ok "make test-full: PASS"
    TEST_STATUS="PASS"
    TEST_RESULT_LINE="PASS (make test-full)"
  else
    bad "make test-full: GAGAL — PR belum bisa disiapkan"
    TEST_STATUS="FAIL"
    TEST_RESULT_LINE="FAIL"
  fi
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  info "Menjalankan: npm test"
  if npm test 2>&1 | tail -5; then
    ok "npm test: PASS"
    TEST_STATUS="PASS"
    TEST_RESULT_LINE="PASS (npm test)"
  else
    bad "npm test: GAGAL"
    TEST_STATUS="FAIL"
    TEST_RESULT_LINE="FAIL"
  fi
elif command -v pytest >/dev/null 2>&1 && [ -f "pytest.ini" -o -f "pyproject.toml" ]; then
  info "Menjalankan: pytest"
  if pytest --tb=no -q 2>&1 | tail -5; then
    ok "pytest: PASS"
    TEST_STATUS="PASS"
    TEST_RESULT_LINE="PASS (pytest)"
  else
    bad "pytest: GAGAL"
    TEST_STATUS="FAIL"
    TEST_RESULT_LINE="FAIL"
  fi
else
  warn "Test runner tidak terdeteksi — jalankan manual"
  TEST_STATUS="unknown"
  TEST_RESULT_LINE="tidak dijalankan — jalankan manual"
fi

# ═══════════════════════════════════════════════════════════════════
# GENERATE PR DESCRIPTION
# ═══════════════════════════════════════════════════════════════════
section "GENERATE PR DESCRIPTION"

# Build file changes list (max 8)
CHANGES_LIST=""
if [ -n "$DIFF_FILES" ]; then
  CHANGES_LIST=$(echo "$DIFF_FILES" | head -8 | while IFS= read -r f; do
    # Determine change type
    if git diff "$BASE...HEAD" --diff-filter=A --name-only 2>/dev/null | grep -qF "$f" || \
       git diff --cached --diff-filter=A --name-only 2>/dev/null | grep -qF "$f"; then
      echo "  + $f (baru)"
    elif git diff "$BASE...HEAD" --diff-filter=D --name-only 2>/dev/null | grep -qF "$f" || \
         git diff --cached --diff-filter=D --name-only 2>/dev/null | grep -qF "$f"; then
      echo "  - $f (dihapus)"
    else
      echo "  ~ $f (diubah)"
    fi
  done)
  [ "$TOTAL_FILES" -gt 8 ] && CHANGES_LIST="$CHANGES_LIST
  ... dan $((TOTAL_FILES - 8)) file lainnya"
fi

# Summary from last commit message
LAST_COMMIT_MSG=$(git log -1 --format="%s" 2>/dev/null || echo "perubahan kode")

echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
p "  PR DESCRIPTION — COPY PASTE KE GITHUB/GITLAB " 45
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
echo ""

cat <<PRDESC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
JUDUL : ${PR_TYPE}${PR_SCOPE}: [isi ringkasan singkat]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RINGKASAN
[1–3 kalimat: apa yang berubah, kenapa, bagaimana]
Contoh otomatis: ${LAST_COMMIT_MSG}

PERUBAHAN
${CHANGES_LIST:-  (tidak ada diff terdeteksi)}

STATISTIK
  Files  : $TOTAL_FILES
  Tambah : +$ADDED_LINES baris
  Hapus  : -$REMOVED_LINES baris
  Branch : $CURRENT_BRANCH → $BASE

COMMIT
$(echo "$COMMITS" | head -5 | sed 's/^/  /')

BUKTI
  Test   : $TEST_RESULT_LINE
  Audit  : [jalankan: bash skills/dependency/run.sh]
  Lint   : [jalankan: npm run lint / make lint]

CHECKLIST
  [$([ "$TEST_STATUS" = "PASS" ] && echo "x" || echo " ")] Test hijau
  [ ] Audit CLEAN (tidak ada P0/P1)
  [ ] Changelog diupdate (jika user-visible)
  [ ] Tidak ada debug/console.log tertinggal
  [ ] Breaking change? → versi baru / deprecation notice
  [ ] Secret tidak ada di diff
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRDESC

# Show PR template if found
if [ -n "$PR_TEMPLATE_CONTENT" ]; then
  echo ""
  p "  ── Template dari $TEMPLATE_PATH ──" 45
  echo "$PR_TEMPLATE_CONTENT" | head -30 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
fi

# ── Final gate check ─────────────────────────────────────────────
echo ""
p "═══════════════════════════════════════════════" 213
p "         PR GATE SUMMARY                       " 213
p "═══════════════════════════════════════════════" 213
echo ""

if [ "$TEST_STATUS" = "FAIL" ]; then
  bad "GERBANG: Test MERAH — PR DILARANG disiapkan sebelum test hijau"
  bad "Fix test dulu, baru siapkan PR"
fi

if [ "$GATES_FAILED" -eq 0 ]; then
  ok "Semua gate PASS (atau dilewati karena tool tidak ada)"
  ok "PR description di atas siap — edit JUDUL dan RINGKASAN sesuai konteks"
  p "PR: SIAP — edit dan paste ke platform git Anda" 82
  exit 0
else
  bad "$GATES_FAILED gate GAGAL — PR belum siap"
  p "PR: GAGAL — $GATES_FAILED gate ✗" 196
  exit 1
fi
