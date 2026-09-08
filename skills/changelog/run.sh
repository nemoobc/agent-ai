#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  CHANGELOG-RUN — validasi sinkron: VERSION ↔ badge README ↔
#  entry CHANGELOG, + ringkas commit sejak tag terakhir.
#  Jalankan: bash skill/changelog/run.sh [dir]
#  Exit 0 = sinkron, 1 = ada yang melenceng.
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ISSUES=0
bad(){ p "  ✖ $1" 196; ISSUES=$((ISSUES+1)); }

p "▮ CHANGELOG-RUN: sinkron versi" 213
if [ ! -f VERSION ]; then bad "VERSION file hilang"; else
  V=$(tr -d '[:space:]' < VERSION)
  [ -f CHANGELOG.md ] && grep -q "^## \[$V\]" CHANGELOG.md && p "  ✔ CHANGELOG punya entry [$V]" 82 || bad "CHANGELOG tidak punya entry [$V]"
  if [ -f README.md ]; then
    BADGE=$(grep -oE 'VERSION-[0-9.]+' README.md | head -1 | grep -oE '[0-9.]+$')
    [ "$BADGE" = "$V" ] && p "  ✔ badge README = $V" 82 || bad "badge README ($BADGE) ≠ VERSION ($V)"
  fi
  p "  VERSION: $V" 45
fi

p "▮ CHANGELOG-RUN: ringkas commit sejak tag" 213
BASE=$(git describe --tags --abbrev=0 2>/dev/null || echo '')
if [ -n "$BASE" ]; then
  git log --oneline "$BASE"..HEAD 2>/dev/null | head -20 | sed 's/^/    /'
else
  p "  · bukan git repo / belum ada tag — lewati" 245
fi

echo
if [ "$ISSUES" -eq 0 ]; then p "CHANGELOG_RUN: SINKRON ✓" 82; exit 0; fi
p "CHANGELOG_RUN: $ISSUES MASALAH ✗" 196; exit 1