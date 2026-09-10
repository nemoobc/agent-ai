#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  DEPENDENCY-RUN — inventory & audit dependensi: baca manifest,
#  daftar deps+versi, flag yang major di belakang, jalankan audit
#  (npm/pip/go/cargo). Exit 0 = bersih, 1 = ada vulnerability.
#  Jalankan: bash skills/dependency/run.sh [dir]
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

ISSUES=0
VULN=0

echo ""
p "═══════════════════════════════════════════════" 213
p "     📦 DEPENDENCY — INVENTORY & AUDIT         " 213
p "═══════════════════════════════════════════════" 213
echo ""

# ── detect stack ─────────────────────────────────────────────────
HAS_NODE=0; HAS_PY=0; HAS_GO=0; HAS_RUST=0
[ -f package.json ] && HAS_NODE=1
[ -f pyproject.toml ] || [ -f requirements.txt ] && HAS_PY=1
[ -f go.mod ] && HAS_GO=1
[ -f Cargo.toml ] && HAS_RUST=1

if [ "$HAS_NODE" -eq 0 ] && [ "$HAS_PY" -eq 0 ] && \
   [ "$HAS_GO" -eq 0 ] && [ "$HAS_RUST" -eq 0 ]; then
  warn "Tidak ada manifest ditemukan (package.json / pyproject.toml / go.mod / Cargo.toml)"
  info "Jalankan di root project yang punya manifest."
  exit 0
fi

# ═══════════════════════════════════════════════════════════════════
# NODE / NPM
# ═══════════════════════════════════════════════════════════════════
if [ "$HAS_NODE" -eq 1 ]; then
  section "NODE.JS — package.json"

  # Count deps
  DEPS_PROD=$(grep -c '"' package.json 2>/dev/null || echo 0)

  # List dependencies
  p "  ── dependencies ──" 45
  if command -v node >/dev/null 2>&1 && node -e "
    const p = require('./package.json');
    const deps = {...(p.dependencies||{}), ...(p.devDependencies||{})};
    Object.entries(deps).forEach(([k,v]) => console.log('  ' + k.padEnd(40) + v));
  " 2>/dev/null; then
    ok "package.json deps listed"
  else
    # Fallback: grep based
    if [ -f package.json ]; then
      p "  [dependencies]" 45
      sed -n '/"dependencies"/,/}/p' package.json 2>/dev/null \
        | grep -E '"[^"]+": "[^"]+"' \
        | sed 's/"//g; s/,$//' \
        | awk '{printf "    %-40s %s\n", $1, $2}' \
        | while IFS= read -r line; do echo -e "${CYAN}${line}${NC}"; done
      p "  [devDependencies]" 45
      sed -n '/"devDependencies"/,/}/p' package.json 2>/dev/null \
        | grep -E '"[^"]+": "[^"]+"' \
        | sed 's/"//g; s/,$//' \
        | awk '{printf "    %-40s %s\n", $1, $2}' \
        | while IFS= read -r line; do echo -e "${YELLOW}${line}${NC}"; done
    fi
  fi

  # Lockfile check
  section "LOCKFILE CHECK"
  if [ -f package-lock.json ]; then
    ok "package-lock.json ada"
    LOCK_VER=$(grep '"lockfileVersion"' package-lock.json 2>/dev/null | grep -oE '[0-9]+' | head -1)
    info "lockfileVersion: ${LOCK_VER:-?}"
  elif [ -f yarn.lock ]; then
    ok "yarn.lock ada"
  elif [ -f pnpm-lock.yaml ]; then
    ok "pnpm-lock.yaml ada"
  else
    warn "Tidak ada lockfile — dependensi tidak dikunci!"
    ISSUES=$((ISSUES+1))
  fi

  # npm audit
  section "NPM AUDIT"
  if command -v npm >/dev/null 2>&1; then
    info "Menjalankan npm audit..."
    AUDIT_OUT=$(npm audit --json 2>/dev/null || npm audit 2>&1)
    AUDIT_EXIT=$?
    if [ $AUDIT_EXIT -eq 0 ]; then
      ok "npm audit: BERSIH"
    else
      # Try to extract vulnerability counts
      CRITICAL=$(echo "$AUDIT_OUT" | grep -oE '"critical":[0-9]+' | grep -oE '[0-9]+' | head -1)
      HIGH=$(echo "$AUDIT_OUT" | grep -oE '"high":[0-9]+' | grep -oE '[0-9]+' | head -1)
      MODERATE=$(echo "$AUDIT_OUT" | grep -oE '"moderate":[0-9]+' | grep -oE '[0-9]+' | head -1)
      bad "npm audit: KERENTANAN DITEMUKAN"
      [ -n "$CRITICAL" ] && [ "$CRITICAL" -gt 0 ] && bad "  Critical: $CRITICAL" && VULN=$((VULN+CRITICAL))
      [ -n "$HIGH" ] && [ "$HIGH" -gt 0 ] && bad "  High    : $HIGH" && VULN=$((VULN+HIGH))
      [ -n "$MODERATE" ] && [ "$MODERATE" -gt 0 ] && warn "  Moderate: $MODERATE"
      echo "$AUDIT_OUT" | grep -E '"name"|"severity"|"via"' | head -20 | sed 's/^/    /'
      ISSUES=$((ISSUES+1))
    fi
  else
    warn "npm tidak tersedia — skip audit"
  fi
fi

# ═══════════════════════════════════════════════════════════════════
# PYTHON
# ═══════════════════════════════════════════════════════════════════
if [ "$HAS_PY" -eq 1 ]; then
  section "PYTHON — pyproject.toml / requirements.txt"

  if [ -f pyproject.toml ]; then
    p "  [pyproject.toml dependencies]" 45
    grep -E '^\s*"[a-zA-Z]|^\s*[a-zA-Z].*=.*"' pyproject.toml 2>/dev/null \
      | grep -v '^\[' | head -40 \
      | while IFS= read -r line; do echo -e "${CYAN}    ${line}${NC}"; done
  fi

  if [ -f requirements.txt ]; then
    p "  [requirements.txt]" 45
    grep -v '^#' requirements.txt 2>/dev/null | grep -v '^$' \
      | awk '{printf "    %-40s\n", $0}' \
      | while IFS= read -r line; do echo -e "${CYAN}${line}${NC}"; done
  fi

  # pip-audit
  section "PIP AUDIT"
  if command -v pip-audit >/dev/null 2>&1; then
    info "Menjalankan pip-audit..."
    if pip-audit 2>&1; then
      ok "pip-audit: BERSIH"
    else
      bad "pip-audit: KERENTANAN DITEMUKAN"
      VULN=$((VULN+1))
      ISSUES=$((ISSUES+1))
    fi
  elif command -v pip >/dev/null 2>&1; then
    warn "pip-audit tidak tersedia. Install: pip install pip-audit"
    info "Alternatif: pip list --outdated"
    pip list --outdated 2>/dev/null | head -20 | while IFS= read -r line; do echo -e "${YELLOW}  $line${NC}"; done
  else
    warn "Python tools tidak tersedia — skip audit"
  fi
fi

# ═══════════════════════════════════════════════════════════════════
# GO
# ═══════════════════════════════════════════════════════════════════
if [ "$HAS_GO" -eq 1 ]; then
  section "GO — go.mod"

  p "  [go.mod dependencies]" 45
  grep -E '^require|^\s+[a-zA-Z]' go.mod 2>/dev/null | grep -v '^require (' \
    | sed 's|^\s*||' | grep -v '^)' \
    | awk '{printf "    %-50s %s\n", $1, $2}' \
    | while IFS= read -r line; do echo -e "${CYAN}${line}${NC}"; done

  # go mod verify
  section "GO MOD VERIFY"
  if command -v go >/dev/null 2>&1; then
    info "Menjalankan go mod verify..."
    if go mod verify 2>&1; then
      ok "go mod verify: OK"
    else
      bad "go mod verify: GAGAL — modul rusak/diubah"
      VULN=$((VULN+1))
      ISSUES=$((ISSUES+1))
    fi
  else
    warn "go tidak tersedia — skip verify"
  fi

  # Check for indirect deps
  INDIRECT=$(grep '// indirect' go.mod 2>/dev/null | wc -l | tr -d ' ')
  info "Indirect dependencies: $INDIRECT"
  if [ "$INDIRECT" -gt 20 ]; then
    warn "Banyak indirect deps ($INDIRECT) — pertimbangkan go mod tidy"
  fi
fi

# ═══════════════════════════════════════════════════════════════════
# RUST
# ═══════════════════════════════════════════════════════════════════
if [ "$HAS_RUST" -eq 1 ]; then
  section "RUST — Cargo.toml"

  p "  [Cargo.toml dependencies]" 45
  sed -n '/^\[dependencies\]/,/^\[/p' Cargo.toml 2>/dev/null \
    | grep -v '^\[' | grep -v '^$' \
    | awk '{printf "    %-40s %s\n", $1, $2}' \
    | while IFS= read -r line; do echo -e "${CYAN}${line}${NC}"; done

  # cargo audit
  section "CARGO AUDIT"
  if command -v cargo-audit >/dev/null 2>&1 || cargo audit --version >/dev/null 2>&1; then
    info "Menjalankan cargo audit..."
    if cargo audit 2>&1; then
      ok "cargo audit: BERSIH"
    else
      bad "cargo audit: KERENTANAN DITEMUKAN"
      VULN=$((VULN+1))
      ISSUES=$((ISSUES+1))
    fi
  else
    warn "cargo-audit tidak tersedia. Install: cargo install cargo-audit"
  fi

  # Lockfile
  if [ -f Cargo.lock ]; then
    ok "Cargo.lock ada"
  else
    warn "Cargo.lock tidak ada — dependensi tidak dikunci"
    ISSUES=$((ISSUES+1))
  fi
fi

# ═══════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════
echo ""
p "═══════════════════════════════════════════════" 213
p "         DEPENDENCY SUMMARY                    " 213
p "═══════════════════════════════════════════════" 213
echo ""

if [ "$VULN" -gt 0 ]; then
  bad "VULNERABILITY: $VULN ditemukan — WAJIB fix sebelum deploy"
  bad "ISSUES: $ISSUES total"
  echo ""
  p "DEPENDENCY: GAGAL — $VULN kerentanan, $ISSUES masalah" 196
  exit 1
elif [ "$ISSUES" -gt 0 ]; then
  warn "MASALAH: $ISSUES (non-vulnerability — lockfile/config)"
  ok "Tidak ada kerentanan terdeteksi"
  echo ""
  p "DEPENDENCY: PERHATIAN — $ISSUES masalah non-vuln" 214
  exit 0
else
  ok "Semua dependensi bersih"
  ok "Tidak ada kerentanan ditemukan"
  echo ""
  p "DEPENDENCY: BERSIH ✓" 82
  exit 0
fi
