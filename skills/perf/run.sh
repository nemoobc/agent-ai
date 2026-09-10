#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  PERF-RUN — scanner anti-pattern performa: N+1, import besar,
#  blocking IO, missing pagination, heavy render. Juga benchmark
#  via Makefile bench jika ada. Output file:baris per temuan.
#  Jalankan: bash skills/perf/run.sh [dir]
#  Exit 0 selalu (informasi).
# ═════════════════════════════════════════════════════════════════
set -u

ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "ERROR: dir $ROOT tidak ada"; exit 1; }

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

TOTAL_FINDINGS=0
EXCL="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=backups"

hit(){
  echo -e "${YELLOW}    $1${NC}"
  TOTAL_FINDINGS=$((TOTAL_FINDINGS+1))
}

echo ""
p "═══════════════════════════════════════════════" 213
p "   ⚡ PERF — HOTSPOT SCANNER PERFORMA          " 213
p "═══════════════════════════════════════════════" 213
echo ""
info "Scanning: $ROOT"
echo ""

# ── Detect source files ──────────────────────────────────────────
SRC_EXTENSIONS="-name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.py' -o -name '*.go' -o -name '*.rb' -o -name '*.php'"
SRC_FILES=$(find . -type f \
  \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' \
  -o -name '*.py' -o -name '*.go' -o -name '*.rb' -o -name '*.php' \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' \
  -not -path '*/dist/*' -not -path '*/build/*' \
  -not -path '*/.next/*' -not -path '*/backups/*' \
  2>/dev/null)

FILE_COUNT=$(echo "$SRC_FILES" | grep -c . 2>/dev/null || echo 0)
info "Source files ditemukan: $FILE_COUNT"

# ═══════════════════════════════════════════════════════════════════
# 1. N+1 QUERY (query dalam loop)
# ═══════════════════════════════════════════════════════════════════
section "1. N+1 QUERY — QUERY DALAM LOOP"

N1_COUNT=0

# Pattern: await/async query inside for/while loop
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.jsx' --include='*.tsx' \
  -E '(for|while|forEach|map|filter)\s*[\(\{]' . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  > /tmp/perf_loops.txt 2>/dev/null

# Check if query patterns appear near loop lines
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.jsx' --include='*.tsx' \
  -E 'await\s+[a-zA-Z]+\.(find|findOne|findMany|query|execute|select|fetch|get)\(' . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | while IFS=: read -r file line content; do
      # Check if line is within ~3 lines of a loop
      if sed -n "$((line-3)),$((line+1))p" "$file" 2>/dev/null \
           | grep -qE '(for\s*\(|while\s*\(|\.forEach|\.map\()'; then
        echo "$file:$line: $content"
      fi
    done 2>/dev/null | head -10 \
  | while IFS= read -r line; do
      hit "[N+1] $line"
      N1_COUNT=$((N1_COUNT+1))
    done

# Python N+1
grep -rn $EXCL \
  --include='*.py' \
  -E '(for .+ in |while )' . 2>/dev/null \
  | grep -v '\.test\.' \
  > /tmp/perf_py_loops.txt 2>/dev/null

grep -rn $EXCL \
  --include='*.py' \
  -E '\.(filter|get|all|query|execute)\(|session\.query|cursor\.execute' . 2>/dev/null \
  | grep -v 'test_' \
  | head -5 \
  | while IFS= read -r line; do
      LINENUM=$(echo "$line" | cut -d: -f2)
      FILE=$(echo "$line" | cut -d: -f1)
      if [ -f "$FILE" ]; then
        CONTEXT=$(sed -n "$((LINENUM-3)),$((LINENUM-1))p" "$FILE" 2>/dev/null)
        if echo "$CONTEXT" | grep -qE '^\s*for |^\s*while '; then
          hit "[N+1-py] $line"
        fi
      fi
    done 2>/dev/null

# SELECT * pattern
SELECTSTAR=$(grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' --include='*.go' \
  -E "SELECT \*|'SELECT \*|\`SELECT \*" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_' | head -10)

if [ -n "$SELECTSTAR" ]; then
  p "  ── SELECT * patterns ──" 45
  echo "$SELECTSTAR" | while IFS= read -r line; do hit "[SELECT*] $line"; done
fi

[ "$TOTAL_FINDINGS" -eq 0 ] && ok "Tidak ada N+1 terdeteksi (heuristik)" || true

# ═══════════════════════════════════════════════════════════════════
# 2. LARGE IMPORTS / BUNDLE BLOAT
# ═══════════════════════════════════════════════════════════════════
section "2. LARGE IMPORTS / BUNDLE BLOAT"

PRE_FINDINGS=$TOTAL_FINDINGS

# import * (wildcard imports)
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.jsx' --include='*.tsx' \
  -E "import \* as |require\(['\"])" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' | head -10 \
  | while IFS= read -r line; do hit "[IMPORT-WILDCARD] $line"; done

# Heavy known packages imported without tree shaking
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.jsx' --include='*.tsx' \
  -E "import (lodash|moment|rxjs|antd|@mui/material)['\"]" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' | head -10 \
  | while IFS= read -r line; do hit "[HEAVY-IMPORT] $line"; done

# Python: import full module instead of specific
grep -rn $EXCL \
  --include='*.py' \
  -E "^import (numpy|pandas|tensorflow|torch|scipy)$" . 2>/dev/null \
  | grep -v 'test_' | head -10 \
  | while IFS= read -r line; do hit "[HEAVY-IMPORT-PY] $line"; done

[ "$TOTAL_FINDINGS" -eq "$PRE_FINDINGS" ] && ok "Tidak ada wildcard import besar terdeteksi" || true

# ═══════════════════════════════════════════════════════════════════
# 3. BLOCKING IO DI HOT PATH
# ═══════════════════════════════════════════════════════════════════
section "3. BLOCKING IO DI HOT PATH"

PRE_FINDINGS=$TOTAL_FINDINGS

# Node.js sync IO in non-setup code
grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "(readFileSync|writeFileSync|existsSync|mkdirSync|readdirSync|statSync|execSync)" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|config\|setup\|seed\|script' | head -10 \
  | while IFS= read -r line; do hit "[SYNC-IO] $line"; done

# Python: blocking sleep / sync HTTP in async context
grep -rn $EXCL \
  --include='*.py' \
  -E "time\.sleep|requests\.(get|post|put|delete)\(" . 2>/dev/null \
  | grep -v 'test_' | head -10 \
  | while IFS= read -r line; do
      FILE=$(echo "$line" | cut -d: -f1)
      if grep -q 'async def\|asyncio' "$FILE" 2>/dev/null; then
        hit "[BLOCKING-ASYNC-PY] $line"
      else
        info "[IO-PY] $line (tidak async — mungkin OK)"
      fi
    done

# Go: blocking in goroutine without timeout
grep -rn $EXCL \
  --include='*.go' \
  -E "http\.(Get|Post)\(|ioutil\.ReadFile" . 2>/dev/null \
  | grep -v '_test\.go' | head -10 \
  | while IFS= read -r line; do hit "[BLOCKING-GO] $line"; done

[ "$TOTAL_FINDINGS" -eq "$PRE_FINDINGS" ] && ok "Tidak ada blocking IO terdeteksi" || true

# ═══════════════════════════════════════════════════════════════════
# 4. MISSING PAGINATION
# ═══════════════════════════════════════════════════════════════════
section "4. MISSING PAGINATION"

PRE_FINDINGS=$TOTAL_FINDINGS

# findAll/findMany without limit
grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "\.(findAll|findMany|find)\(\s*\{[^}]*\}\s*\)|\.(findAll|findMany)\(\s*\)" . 2>/dev/null \
  | grep -v 'limit\|take\|skip\|offset\|\.test\.\|\.spec\.' | head -10 \
  | while IFS= read -r line; do hit "[NO-PAGINATION] $line"; done

# Django QuerySet without limit
grep -rn $EXCL \
  --include='*.py' \
  -E "\.objects\.all\(\)|\.objects\.filter\([^)]*\)\s*$" . 2>/dev/null \
  | grep -v '\[:.*\]\|\.count()\|test_' | head -10 \
  | while IFS= read -r line; do hit "[NO-PAGINATION-DJANGO] $line"; done

# Go: no LIMIT in SQL string
grep -rn $EXCL \
  --include='*.go' \
  -E '"SELECT .* FROM [^"]*"' . 2>/dev/null \
  | grep -iv 'LIMIT\|_test\.go' | head -10 \
  | while IFS= read -r line; do hit "[NO-LIMIT-SQL-GO] $line"; done

[ "$TOTAL_FINDINGS" -eq "$PRE_FINDINGS" ] && ok "Tidak ada missing pagination terdeteksi" || true

# ═══════════════════════════════════════════════════════════════════
# 5. HEAVY RENDER / COMPUTATION DI RENDER PATH
# ═══════════════════════════════════════════════════════════════════
section "5. HEAVY RENDER / HOT PATH COMPUTATION"

PRE_FINDINGS=$TOTAL_FINDINGS

# Sort/filter/map inside render function
grep -rn $EXCL \
  --include='*.jsx' --include='*.tsx' \
  -E "\.(sort|filter|reduce|map)\(" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | while IFS= read -r line; do
      FILE=$(echo "$line" | cut -d: -f1)
      LINENUM=$(echo "$line" | cut -d: -f2)
      CONTEXT=$(sed -n "$((LINENUM-10)),$((LINENUM))p" "$FILE" 2>/dev/null)
      if echo "$CONTEXT" | grep -qE 'return \(|function.*Render|const.*=.*\(.*\)\s*=>\s*\('; then
        hit "[HEAVY-RENDER] $line"
      fi
    done 2>/dev/null | head -10

# Missing useMemo/useCallback for expensive ops
grep -rn $EXCL \
  --include='*.jsx' --include='*.tsx' \
  -E "\.(sort|filter|reduce)\(.*\.(map|filter|sort)\(" . 2>/dev/null \
  | grep -v 'useMemo\|useCallback\|\.test\.\|\.spec\.' | head -10 \
  | while IFS= read -r line; do hit "[MISSING-MEMO] $line"; done

[ "$TOTAL_FINDINGS" -eq "$PRE_FINDINGS" ] && ok "Tidak ada heavy render terdeteksi" || true

# ═══════════════════════════════════════════════════════════════════
# 6. BENCHMARK (Makefile bench)
# ═══════════════════════════════════════════════════════════════════
section "6. BENCHMARK"

if [ -f Makefile ]; then
  if grep -qE '^bench\b|^benchmark\b' Makefile 2>/dev/null; then
    info "Makefile bench target ditemukan — menjalankan..."
    BENCH_START=$(date +%s%N 2>/dev/null || date +%s)
    if make bench 2>&1 | head -30 | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done; then
      BENCH_END=$(date +%s%N 2>/dev/null || date +%s)
      ok "make bench: SELESAI"
    else
      warn "make bench: ada error — cek output di atas"
    fi
  else
    info "Tidak ada target 'bench' / 'benchmark' di Makefile"
  fi
else
  info "Tidak ada Makefile — skip benchmark"
fi

# Go benchmark
if [ -f go.mod ] && command -v go >/dev/null 2>&1; then
  BENCH_FILES=$(find . -name '*_test.go' -not -path '*/vendor/*' 2>/dev/null \
    | xargs grep -l 'func Benchmark' 2>/dev/null | head -3)
  if [ -n "$BENCH_FILES" ]; then
    info "Go benchmark files ditemukan:"
    echo "$BENCH_FILES" | while IFS= read -r f; do echo -e "${CYAN}    $f${NC}"; done
    info "Jalankan: go test -bench=. ./..."
  fi
fi

# ═══════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════
echo ""
p "═══════════════════════════════════════════════" 213
p "         PERF SUMMARY                          " 213
p "═══════════════════════════════════════════════" 213
echo ""
info "Source files diperiksa: $FILE_COUNT"
info "Total temuan: $TOTAL_FINDINGS"
echo ""

if [ "$TOTAL_FINDINGS" -eq 0 ]; then
  ok "Tidak ada anti-pattern performa terdeteksi (heuristik)"
  p "PERF: BERSIH ✓" 82
else
  warn "$TOTAL_FINDINGS temuan potensial — tanda sebagai tebakan, ukur sebelum fix"
  warn "Prioritas: hot path + data besar. Ukur dengan profiler/time sebelum fix."
  p "PERF: $TOTAL_FINDINGS TEMUAN — review manual diperlukan" 214
fi

echo ""
info "Format laporan:"
cat <<'LAPORAN'
  PERF   : <hotspot>
  DIBUAT : X temuan, Y difix
  TEST   : PASS (N/N)
  AUDIT  : CLEAN
  DAMPAK : <sebelum → after, angka atau estimasi jujur>
LAPORAN
echo ""
exit 0
