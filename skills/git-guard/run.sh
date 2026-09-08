#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  GIT-GUARD — gerbang commit: scan staged diff.
#  Exit 0 = CLEAN (aman di-commit), 1 = BLOKIR.
#  Jalankan sebelum commit: bash skill/git-guard/run.sh [dir]
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ISSUES=0
fail(){ p "  ✖ $1" 196; ISSUES=$((ISSUES+1)); }

if [ ! -d .git ]; then p "GIT_GUARD: bukan git repo — skip" 214; exit 0; fi

STAGED=$(git diff --cached 2>/dev/null)
if [ -z "$STAGED" ]; then p "GIT_GUARD: tidak ada staged changes — aman" 214; exit 0; fi

p "▮ GIT-GUARD: scan staged diff" 213

# 1. secret
if printf '%s' "$STAGED" | grep -qE 'AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|gho_[A-Za-z0-9]{30,}|ghs_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|ya29\.[0-9A-Za-z_-]{20,}|glpat-[A-Za-z0-9_-]{16,}|dop_v1_[a-f0-9]{32,}|npm_[A-Za-z0-9]{30,}|BEGIN [A-Z ]*PRIVATE KEY'; then
  fail "pola secret di staged diff"
fi

# 2. merge marker
if printf '%s' "$STAGED" | grep -qE '^(<<<<<<<|=======|>>>>>>>)'; then
  fail "merge conflict marker tersisa"
fi

# 3. debug yang DITAMBAHKAN (baris +)
ADDED=$(printf '%s' "$STAGED" | grep -E '^\+' | grep -v '^\+\+\+')
if printf '%s' "$ADDED" | grep -qE 'console\.log\(|print\(|var_dump\(|pdb\.|debugger;'; then
  fail "debug statement ditambahkan (console.log/print/pdb/debugger)"
fi

# 4. diff raksasa
BIG=$(git diff --cached --numstat 2>/dev/null | awk '$1 ~ /^[0-9]+$/ && $1 > 1000 {print $3 " (" $1 " baris baru)"}' | head -1)
if [ -n "$BIG" ]; then
  fail "file besar di commit: $BIG — pecah commit"
fi

echo
if [ "$ISSUES" -eq 0 ]; then p "GIT_GUARD: CLEAN — aman di-commit ✓" 82; exit 0; fi
p "GIT_GUARD: BLOKIR — perbaiki dulu, jangan paksa commit" 196; exit 1