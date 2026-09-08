#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  METRICS — angka kesehatan project: ukuran, terbesar, test, TODO.
#  Jalankan: bash skill/metrics/run.sh [dir]
#  Exit 0. Output siap dipakai skill metrics (angka → putusan).
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

EXCL='-not -path */.git/* -not -path */node_modules/*'
# file kode (ekstensi umum)
SRC_FILES=$(find . -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.rb' -o -name '*.php' -o -name '*.sh' \) $EXCL 2>/dev/null | wc -l | tr -d ' ')
ALL_FILES=$(find . -type f $EXCL 2>/dev/null | wc -l | tr -d ' ')
SRC_LINES=$(find . -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.rb' -o -name '*.php' -o -name '*.sh' \) $EXCL -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')

# file terbesar (10 teratas)
LARGE=$(find . -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.rb' -o -name '*.php' -o -name '*.sh' \) $EXCL -exec wc -l {} + 2>/dev/null | sort -rn | head -4)

# test & ratio
TEST_FILES=$(find . -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*.py' -o -name '*_test.go' -o -name '*_test.rb' -o -name '*_test.rs' \) $EXCL 2>/dev/null | wc -l | tr -d ' ')

# TODO/FIXME/HACK
TODO=$(grep -rInE '(TODO|FIXME|HACK)[[:space:]]*[:：]' --exclude-dir=.git --exclude-dir=node_modules . 2>/dev/null | wc -l | tr -d ' ')

# git
BRANCH="—"; DIRTY="?"
if [ -d .git ]; then BRANCH=$(git branch --show-current 2>/dev/null || echo '?'); DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' '); fi

p "▮ METRICS: $BRANCH" 213
p "  UKURAN   : $ALL_FILES file total • $SRC_FILES file kode • $SRC_LINES baris" 45
p "  TEST     : $TEST_FILES file test (rasio 1 test : $([ "${SRC_FILES:-0}" -gt 0 ] && echo $((SRC_FILES / (TEST_FILES + 1))) || echo 0) file kode)" 45
p "  UTANG    : $TODO TODO/FIXME • git kotor $DIRTY file" 45
p "  TERBESAR :" 45
printf '%s\n' "$LARGE" | sed 's/^/    /' | head -3
p "METRICS_RESULT: angka di atas → PUTUSAN di tangan DEV (skill metrics)" 45
exit 0