#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  ENV-GUARD — hygiene env: .env aman, .env.example ada, secret
#  tidak di-track. Jalankan: bash skill/env-guard/run.sh [dir]
#  Exit 0 = bersih, 1 = masalah.
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ISSUES=0
bad(){ p "  ✖ $1" 196; ISSUES=$((ISSUES+1)); }
ok(){ p "  ✔ $1" 82; }

p "▮ ENV-GUARD: hygiene .env" 213

# 1. .gitignore memuat .env
if [ -f .gitignore ] && grep -qE '^\.env($|\.)' .gitignore 2>/dev/null; then
  ok ".gitignore memuat .env"
else
  bad ".gitignore tidak memuat .env"
fi

# 2. .env tidak ter-track
TRACKED_ENV=$(git ls-files 2>/dev/null | grep -E '(^|/)\.env($|\.)' | grep -v '\.env\.example' | head -3)
if [ -n "$TRACKED_ENV" ]; then
  bad ".env ter-track di git: $TRACKED_ENV — git rm --cached + rotasi"
else
  ok "tidak ada .env ter-track"
fi

# 3. .env.example ada
if [ -f .env.example ] || [ -f .env.example.txt ]; then
  ok ".env.example ada"
else
  p "  ⚠ .env.example tidak ada — bikin dari key yang dipakai (nilai kosong)" 214
fi

# 4. secret di file tracked
SECRETS=$(git ls-files 2>/dev/null | xargs -r grep -lInE 'AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{30,}|AIza[0-9A-Za-z_-]{30,}|BEGIN [A-Z ]*PRIVATE KEY' 2>/dev/null | head -3)
if [ -n "$SECRETS" ]; then
  bad "pola secret di file tracked: $(echo "$SECRETS" | tr '\n' ' ')"
else
  ok "tidak ada pola secret di file tracked"
fi

echo
if [ "$ISSUES" -eq 0 ]; then p "ENV_GUARD: BERSIH ✓" 82; exit 0; fi
p "ENV_GUARD: $ISSUES MASALAH ✗" 196; exit 1