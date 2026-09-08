#!/usr/bin/env bash
# AUTO AUDIT FULL — deps + typecheck + lint + secret-scan + higiene
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
ISSUES=0
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
found(){ p "  ✖ $1" 196; ISSUES=$((ISSUES+1)); }
clean(){ p "  ✔ $1" 82; }

p "▮ AUDIT: dependensi" 213
if [ -f package.json ] && command -v npm >/dev/null 2>&1; then
  # sehat = "found 0 vulnerabilities"; flag hanya bila jumlah vuln >= 1
  AUD=$(npm audit --omit=dev 2>/dev/null || true)
  if echo "$AUD" | grep -qE '[1-9][0-9]* vulnerabilities'; then
    found "npm audit: kerentanan dependensi"
  elif [ -n "$AUD" ]; then
    clean "npm audit"
  else
    clean "npm audit (tidak bisa jalan — offline/tanpa lockfile)"
  fi
fi
if command -v pip-audit >/dev/null 2>&1 && [ -f requirements.txt ]; then
  pip-audit -r requirements.txt --quiet 2>/dev/null || found "pip-audit: kerentanan python"
fi

p "▮ AUDIT: typecheck" 213
if [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
  node_modules/.bin/tsc --noEmit 2>/dev/null || found "tsc: error type"
fi

p "▮ AUDIT: lint" 213
[ -x node_modules/.bin/eslint ] && { node_modules/.bin/eslint . 2>/dev/null || found "eslint: pelanggaran lint"; }
command -v ruff >/dev/null 2>&1 && compgen -G '*.py' >/dev/null 2>&1 && { ruff check . 2>/dev/null || found "ruff: pelanggaran lint"; }
[ -f go.mod ] && command -v go >/dev/null 2>&1 && { go vet ./... 2>/dev/null || found "go vet: temuan"; }
if command -v shellcheck >/dev/null 2>&1; then
  SHFAIL=0
  for s in *.sh scripts/*.sh; do
    [ -f "$s" ] || continue
    shellcheck -S warning "$s" >/dev/null 2>&1 || SHFAIL=1
  done
  [ "$SHFAIL" -eq 1 ] && found "shellcheck: masalah di script shell"
fi

p "▮ AUDIT: rahasia bocor" 213
SECRETS=$(grep -rIniE --exclude-dir=node_modules --exclude-dir=.git \
  -e 'AKIA[0-9A-Z]{16}' -e 'sk-[A-Za-z0-9]{20,}' -e 'sk-ant-[A-Za-z0-9_-]{20,}' \
  -e 'ghp_[A-Za-z0-9]{30,}' -e 'gho_[A-Za-z0-9]{30,}' -e 'ghs_[A-Za-z0-9]{30,}' \
  -e 'github_pat_[A-Za-z0-9_]{20,}' -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
  -e 'AIza[0-9A-Za-z_-]{30,}' -e 'ya29\.[0-9A-Za-z_-]{20,}' \
  -e 'glpat-[A-Za-z0-9_-]{16,}' -e 'dop_v1_[a-f0-9]{32,}' \
  -e 'npm_[A-Za-z0-9]{30,}' -e 'BEGIN [A-Z ]*PRIVATE KEY' \
  -e 'password[[:space:]]*=[[:space:]]*["'"'][^"'"']{4,}["'"']' . 2>/dev/null | head -8)
if [ -n "$SECRETS" ]; then found "pola secret terdeteksi:"; echo "$SECRETS" | sed 's/^/      /';
else clean "tidak ada pola secret"; fi
# opsional: scan sejarah git bila gitleaks terpasang
if command -v gitleaks >/dev/null 2>&1 && [ -d .git ]; then
  gitleaks detect --no-banner --quiet 2>/dev/null && clean "gitleaks (sejarah git)" || found "gitleaks: secret di sejarah git"
fi

p "▮ AUDIT: higiene" 213
TD=$(grep -rIn --exclude-dir=node_modules --exclude-dir=.git -E '(TODO|FIXME|HACK)[[:space:]]*[:：]' . 2>/dev/null | wc -l | tr -d ' ')
if [ "${TD:-0}" -gt 0 ]; then p "  ⚠ $TD TODO/FIXME belum tuntas" 214; else clean "tanpa TODO/FIXME"; fi

echo
if [ "$ISSUES" -eq 0 ]; then p "AUDIT_RESULT: CLEAN ✓" 82; exit 0; fi
p "AUDIT_RESULT: $ISSUES TEMUAN ✗" 196; exit 1
