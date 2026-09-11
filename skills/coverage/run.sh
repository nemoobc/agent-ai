#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  COVERAGE-RUN — peta gap test heuristik: fungsi source vs file test.
#  Jalankan: bash skill/coverage/run.sh [dir]
#  Exit 0 selalu (informasi); output = daftar gap.
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
EXCL='-not -path */.git/* -not -path */node_modules/* -not -path */backups/*'

# 1. source files & fungsi/class
SRC=$(find . -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.rb' -o -name '*.php' -o -name '*.java' \) $EXCL 2>/dev/null | grep -vE '\.(test|spec)\.' | grep -v 'test_')
if [ -z "$SRC" ]; then p "COVERAGE_RUN: tidak ada source ditemukan" 214; exit 0; fi

# 2. test files
TFILES=$(find . -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*.py' -o -name '*_test.go' -o -name '*_test.rb' -o -name '*_test.rs' \) $EXCL 2>/dev/null)
TESTBLOB=$(cat $TFILES 2>/dev/null)

# 3. ekstrak nama fungsi/class (per bahasa, heuristik)
p "▮ COVERAGE-RUN: gap test (heuristik — bukan alat coverage)" 213
TOTAL=0; GAP=0
while IFS=: read -r FILE NAME; do
  [ -z "$NAME" ] && continue
  # filter nama trivial (1-2 huruf / generic)
  case "$NAME" in a|b|i|j|k|get|set|run|main|init|new|ok) continue;; esac
  [ ${#NAME} -lt 3 ] && continue
  TOTAL=$((TOTAL+1))
  if ! printf '%s' "$TESTBLOB" | grep -qF "$NAME"; then
    p "  · $NAME — $FILE (tanpa reference di test)" 214
    GAP=$((GAP+1))
  fi
done < <( { \
  grep -rnoE '^\s*(function|export (async )?function|const [A-Za-z_][A-Za-z0-9_]*\s*=\s*(async\s*)?\(?[^=]*=>)' $SRC 2>/dev/null | sed -E 's/^\s*function\s+//; s/export (async )?function\s+//; s/const\s+([A-Za-z_][A-Za-z0-9_]*).*/\1/; s/^\s*//';
  grep -rnoE '^\s*(def|async def) [A-Za-z_][A-Za-z0-9_]*' $SRC 2>/dev/null | sed -E 's/.*(def) //; s/:$//; s/^.* //';
  grep -rnoE '^\s*func [A-Za-z_][A-Za-z0-9_]*' $SRC 2>/dev/null | sed -E 's/.*func //; s/\(.*//';
  grep -rnoE '^\s*(pub )?fn [A-Za-z_][A-Za-z0-9_]*' $SRC 2>/dev/null | sed -E 's/.*fn //; s/\(.*//';
  grep -rnoE '^\s*(public |private |protected )?(static )?(async )?[A-Za-z_][A-Za-z0-9_]*\([^)]*\)\s*\{?' $SRC 2>/dev/null | sed -E 's/^[^:]*:[0-9]+://; s/\(.*//; s/^\s*//' | grep -vE '^(if|for|while|switch|return|catch|new|function|def|func|fn)$';
  grep -rnoE '^\s*class [A-Za-z_][A-Za-z0-9_]*' $SRC 2>/dev/null | sed -E 's/.*class //; s/\(.*//';
} 2>/dev/null | sed -E 's/^([^:]+):([0-9]+):/\1:/' | awk -F: '{print $1 ":" $NF}' | sort -u )

p "  TOTAL: $TOTAL fungsi/class • GAP: $GAP tanpa reference test" 45
p "COVERAGE_RUN: peta di atas → skill coverage (konfirmasi manual untuk yang kritis)" 45
exit 0