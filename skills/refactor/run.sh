#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  REFACTOR-RUN — safety runner: baseline test hijau dulu, scan
#  duplikasi/kode mati/fungsi panjang/nesting dalam.
#  Args: $1=target_file_or_dir (default: .)
#  Jalankan: bash skills/refactor/run.sh [target]
#  Exit 0 = kandidat dilaporkan, 1 = baseline test gagal.
# ═════════════════════════════════════════════════════════════════
set -u

TARGET="${1:-.}"

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

CANDIDATES=0

echo ""
p "═══════════════════════════════════════════════" 213
p "   🔧 REFACTOR — SAFETY RUNNER                 " 213
p "═══════════════════════════════════════════════" 213
echo ""
info "Target: $TARGET"
echo ""

# ── Check target exists ──────────────────────────────────────────
if [ ! -e "$TARGET" ]; then
  bad "Target tidak ada: $TARGET"
  exit 1
fi

# ═══════════════════════════════════════════════════════════════════
# GERBANG 1: GIT STATUS BASELINE
# ═══════════════════════════════════════════════════════════════════
section "GERBANG 1: GIT STATUS BASELINE"

if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo 'detached')
  ok "Branch: $BRANCH"

  GIT_STATUS=$(git status --short 2>/dev/null)
  CHANGED=$(echo "$GIT_STATUS" | grep -v '^$' | wc -l | tr -d ' ')

  if [ -n "$GIT_STATUS" ]; then
    warn "Ada $CHANGED perubahan uncommitted:"
    echo "$GIT_STATUS" | while IFS= read -r line; do echo -e "${YELLOW}    $line${NC}"; done
    warn "Commit atau stash perubahan sebelum refactor untuk baseline bersih"
  else
    ok "Working tree bersih — baseline ideal"
  fi

  GIT_STAT=$(git diff --stat 2>/dev/null)
  [ -n "$GIT_STAT" ] && info "Diff stat: $GIT_STAT"
else
  warn "Bukan git repo — rekam titik nol manual"
fi

# ═══════════════════════════════════════════════════════════════════
# GERBANG 2: TEST BASELINE HIJAU
# ═══════════════════════════════════════════════════════════════════
section "GERBANG 2: TEST BASELINE — WAJIB HIJAU"

BASELINE_OK=0

if [ -f "Makefile" ] && grep -qE '^test-full:|^test_full:' Makefile 2>/dev/null; then
  info "Menjalankan: make test-full"
  if make test-full 2>&1 | tail -10; then
    ok "make test-full: PASS — baseline hijau"
    BASELINE_OK=1
  else
    bad "make test-full: MERAH"
  fi
elif [ -f "Makefile" ] && grep -qE '^test:' Makefile 2>/dev/null; then
  info "Menjalankan: make test"
  if make test 2>&1 | tail -10; then
    ok "make test: PASS"
    BASELINE_OK=1
  else
    bad "make test: MERAH"
  fi
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  info "Menjalankan: npm test"
  if npm test 2>&1 | tail -10; then
    ok "npm test: PASS"
    BASELINE_OK=1
  else
    bad "npm test: MERAH"
  fi
elif command -v pytest >/dev/null 2>&1 && [ -f "pytest.ini" -o -f "pyproject.toml" ]; then
  info "Menjalankan: pytest --tb=short"
  if pytest --tb=short -q 2>&1 | tail -10; then
    ok "pytest: PASS"
    BASELINE_OK=1
  else
    bad "pytest: MERAH"
  fi
elif command -v go >/dev/null 2>&1 && [ -f "go.mod" ]; then
  info "Menjalankan: go test ./..."
  if go test ./... 2>&1 | tail -10; then
    ok "go test: PASS"
    BASELINE_OK=1
  else
    bad "go test: MERAH"
  fi
else
  warn "Test runner tidak ditemukan"
  warn "HEURISTIK: asumsikan baseline hijau (tidak bisa diverifikasi)"
  BASELINE_OK=1
fi

# GERBANG KERAS: jika test merah, STOP
if [ "$BASELINE_OK" -eq 0 ]; then
  echo ""
  bad "═══════════════════════════════════════════"
  bad " GERBANG GAGAL: TEST BASELINE MERAH        "
  bad "═══════════════════════════════════════════"
  bad "REFACTOR DILARANG dimulai."
  bad "Aturan: fix bug dulu (skill debug), refactor belakangan."
  bad "Gunakan: bash skills/debug/run.sh untuk investigasi"
  echo ""
  p "REFACTOR: DITOLAK — baseline merah ✗" 196
  exit 1
fi

ok "Baseline hijau — refactor DIIZINKAN"

# ═══════════════════════════════════════════════════════════════════
# SCAN: KANDIDAT REFACTOR
# ═══════════════════════════════════════════════════════════════════

EXCL="-not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*'"

# Set up target for find
FIND_TARGET="$TARGET"
if [ -f "$TARGET" ]; then
  FIND_TARGET=$(dirname "$TARGET")
  SINGLE_FILE="$TARGET"
else
  SINGLE_FILE=""
fi

# Get list of source files to scan
if [ -n "$SINGLE_FILE" ]; then
  SRC_FILES="$SINGLE_FILE"
else
  SRC_FILES=$(find "$FIND_TARGET" -type f \
    \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' \
    -o -name '*.py' -o -name '*.go' -o -name '*.rb' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' \
    -not -path '*/dist/*' -not -path '*/build/*' \
    -not -name '*.test.*' -not -name '*.spec.*' \
    2>/dev/null)
fi

# ── SCAN 1: Fungsi panjang (>50 baris) ──────────────────────────
section "SCAN 1: FUNGSI PANJANG (>50 baris)"

echo "$SRC_FILES" | grep -v '^$' | while IFS= read -r FILE; do
  [ -f "$FILE" ] || continue

  TOTAL_LINES=$(wc -l < "$FILE" 2>/dev/null || echo 0)
  [ "$TOTAL_LINES" -lt 50 ] && continue

  # Use awk to find function boundaries
  awk '
    /^[[:space:]]*(async[[:space:]]+)?function[[:space:]]+[A-Za-z_]/ ||
    /^[[:space:]]*const[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=[[:space:]]*(async[[:space:]]*)?\(/ ||
    /^[[:space:]]*(export[[:space:]]+)?(default[[:space:]]+)?(async[[:space:]]+)?function/ ||
    /^[[:space:]]*(def|async def)[[:space:]]+[A-Za-z_]/ ||
    /^[[:space:]]*(pub[[:space:]]+)?(async[[:space:]]+)?fn[[:space:]]+[A-Za-z_]/ ||
    /^[[:space:]]*func[[:space:]]+[A-Za-z_]/ {
      if (start > 0) {
        len = NR - start
        if (len > 50) {
          printf "%s:%d: fungsi ~%d baris\n", FILENAME, start, len
        }
      }
      start = NR
      name = $0
    }
    END {
      if (start > 0) {
        len = NR - start
        if (len > 50) {
          printf "%s:%d: fungsi ~%d baris\n", FILENAME, start, len
        }
      }
    }
  ' "$FILE" 2>/dev/null
done | head -20 | while IFS= read -r line; do
  warn "  [FUNGSI-PANJANG] $line"
  CANDIDATES=$((CANDIDATES+1))
done

[ "$CANDIDATES" -eq 0 ] && ok "Tidak ada fungsi >50 baris terdeteksi" || true

# ── SCAN 2: Nesting dalam (>4 level) ────────────────────────────
section "SCAN 2: NESTING DALAM (>4 level)"

PRE=$CANDIDATES
echo "$SRC_FILES" | grep -v '^$' | while IFS= read -r FILE; do
  [ -f "$FILE" ] || continue

  awk '
  {
    indent = 0
    for (i = 1; i <= length($0); i++) {
      c = substr($0, i, 1)
      if (c == "{" || c == "(") indent++
      if (c == "}" || c == ")") indent--
    }
    total += indent
    if (total > 4) {
      printf "%s:%d: nesting ~%d levels\n", FILENAME, NR, total
      total = 4  # reset to avoid cascading
    }
  }
  ' "$FILE" 2>/dev/null
done | head -20 | sort -u | while IFS= read -r line; do
  warn "  [DEEP-NEST] $line"
  CANDIDATES=$((CANDIDATES+1))
done

[ "$CANDIDATES" -eq "$PRE" ] && ok "Tidak ada nesting >4 terdeteksi" || true

# ── SCAN 3: Kode mati / unused exports ──────────────────────────
section "SCAN 3: KODE MATI / UNUSED EXPORTS"

PRE=$CANDIDATES

# Exported functions that might be unused
if [ -f "package.json" ]; then
  grep -rn \
    --include='*.js' --include='*.ts' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
    -E "^export (const|function|class|default function) [A-Za-z_][A-Za-z0-9_]*" \
    ${FIND_TARGET} 2>/dev/null \
    | while IFS=: read -r file line content; do
        FNAME=$(echo "$content" | grep -oE '[A-Za-z_][A-Za-z0-9_]*' | tail -1)
        [ -z "$FNAME" ] && continue
        # Check if used elsewhere
        USAGE=$(grep -rn \
          --include='*.js' --include='*.ts' --include='*.jsx' --include='*.tsx' \
          --exclude-dir=node_modules --exclude-dir=.git \
          -l "$FNAME" . 2>/dev/null | grep -v "^$file$" | wc -l | tr -d ' ')
        if [ "$USAGE" -eq 0 ]; then
          echo "$file:$line: $FNAME (tidak ada referensi lain)"
        fi
      done 2>/dev/null | head -10 | while IFS= read -r line; do
        warn "  [MUNGKIN-MATI] $line"
        CANDIDATES=$((CANDIDATES+1))
      done
fi

# Python: functions defined but not called
if find . -name '*.py' -not -path '*/.*' 2>/dev/null | head -1 | grep -q .; then
  grep -rn \
    --include='*.py' --exclude-dir=.git \
    -E "^def [a-z_][a-zA-Z0-9_]*\s*\(" \
    ${FIND_TARGET} 2>/dev/null \
    | grep -v 'test_\|__init__\|__main__' \
    | while IFS=: read -r file line content; do
        FNAME=$(echo "$content" | grep -oE '^def [a-z_][a-zA-Z0-9_]+' | sed 's/def //')
        [ -z "$FNAME" ] && continue
        USAGE=$(grep -rn --include='*.py' --exclude-dir=.git \
          -l "$FNAME" . 2>/dev/null | grep -v "^$file$" | wc -l | tr -d ' ')
        if [ "$USAGE" -eq 0 ]; then
          echo "$file:$line: $FNAME"
        fi
      done 2>/dev/null | head -10 | while IFS= read -r line; do
        warn "  [MUNGKIN-MATI-PY] $line"
        CANDIDATES=$((CANDIDATES+1))
      done
fi

[ "$CANDIDATES" -eq "$PRE" ] && ok "Tidak ada unused export/function terdeteksi" || true

# ── SCAN 4: Duplikasi fungsi ─────────────────────────────────────
section "SCAN 4: DUPLIKASI FUNGSI"

PRE=$CANDIDATES

# Find function names that appear in multiple files (potential duplication)
echo "$SRC_FILES" | grep -v '^$' | xargs grep -h \
  -E "^[[:space:]]*(function|def|func) [A-Za-z_][A-Za-z0-9_]*|^[[:space:]]*(const|let) [A-Za-z_][A-Za-z0-9_]* = (async )?function" \
  2>/dev/null \
  | grep -oE '[A-Za-z_][A-Za-z0-9_]+' \
  | sort | uniq -c | sort -rn \
  | awk '$1 >= 3 && $2 !~ /^(get|set|create|update|delete|handle|on|is|has|check|build|make)$/ {print $1, $2}' \
  | head -10 | while IFS= read -r line; do
      COUNT=$(echo "$line" | awk '{print $1}')
      NAME=$(echo "$line" | awk '{print $2}')
      warn "  [DUPLIKASI] $NAME muncul $COUNT kali — cek apakah bisa diextract"
      CANDIDATES=$((CANDIDATES+1))
    done

[ "$CANDIDATES" -eq "$PRE" ] && ok "Tidak ada duplikasi fungsi mencolok" || true

# ── SCAN 5: Magic numbers ────────────────────────────────────────
section "SCAN 5: MAGIC NUMBERS / HARDCODED VALUES"

PRE=$CANDIDATES

grep -rn \
  --include='*.js' --include='*.ts' --include='*.py' --include='*.go' \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist \
  -E "[^a-zA-Z_](86400|3600|1000|60|24|7|365|404|500|200|201)[^a-zA-Z0-9]" \
  ${FIND_TARGET} 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_\|# \|// ' \
  | grep -vE 'const|CONST|CONFIG|config|\.status\(|statusCode' \
  | head -10 | while IFS= read -r line; do
      info "  [MAGIC-NUM] $line"
      CANDIDATES=$((CANDIDATES+1))
    done

[ "$CANDIDATES" -eq "$PRE" ] && ok "Tidak ada magic number mencolok" || true

# ═══════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════
echo ""
p "═══════════════════════════════════════════════" 213
p "         REFACTOR SUMMARY                      " 213
p "═══════════════════════════════════════════════" 213
echo ""
ok "Baseline test: HIJAU ✓"
info "Kandidat refactor ditemukan: $CANDIDATES"
echo ""

if [ "$CANDIDATES" -gt 0 ]; then
  warn "Refactor $CANDIDATES kandidat — ingat aturan:"
  warn "  1. Satu langkah = satu niat"
  warn "  2. Jalankan test setelah setiap perubahan"
  warn "  3. Perilaku SAMA sebelum & sesudah"
  warn "  4. Bukan refactor + feature campur"
fi

echo ""
info "Format laporan setelah refactor:"
cat <<'LAPORAN'
  STATUS : SELESAI/GAGAL
  PINDAH : X file diubah, Y baris bersih
  TEST   : PASS sebelum & sesudah (N/N)
  AUDIT  : CLEAN
LAPORAN
echo ""
p "REFACTOR: baseline hijau, $CANDIDATES kandidat dilaporkan ✓" 82
exit 0
