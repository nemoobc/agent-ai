#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  RED-TEAM-RUN — scanner keamanan: SQL injection, missing input
#  validation, hardcoded secrets, missing auth, IDOR. Laporan per
#  file:baris dengan severity P0/P1/P2.
#  Jalankan: bash skills/red-team/run.sh [dir]
#  Exit 0 = bersih, 1 = ada P0/P1.
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

P0_COUNT=0
P1_COUNT=0
P2_COUNT=0

hit_p0(){ echo -e "${RED}  [P0-KRITIS] $1${NC}"; P0_COUNT=$((P0_COUNT+1)); }
hit_p1(){ echo -e "${RED}  [P1-TINGGI] $1${NC}"; P1_COUNT=$((P1_COUNT+1)); }
hit_p2(){ echo -e "${YELLOW}  [P2-SEDANG] $1${NC}"; P2_COUNT=$((P2_COUNT+1)); }

EXCL="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=backups --exclude-dir=vendor"

echo ""
p "═══════════════════════════════════════════════" 196
p "   🔴 RED TEAM — ATTACK SURFACE SCANNER        " 196
p "═══════════════════════════════════════════════" 196
echo ""
info "Scanning: $ROOT"
info "Severity: P0=Kritis, P1=Tinggi, P2=Sedang"
echo ""

# ═══════════════════════════════════════════════════════════════════
# 1. SQL INJECTION
# ═══════════════════════════════════════════════════════════════════
section "1. SQL INJECTION — P0"

# Raw string concatenation in SQL
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' --include='*.php' \
  --include='*.go' --include='*.rb' --include='*.java' \
  -E "\"SELECT|'SELECT|`SELECT" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_' \
  | grep -iE '\$\{|\+ |f".*\{|\.|\.format\(' \
  | grep -v '?.?|%s|%d|\$[0-9]|\?[0-9]' \
  | head -10 \
  | while IFS= read -r line; do hit_p0 "SQL CONCAT: $line"; done

# ORM raw query with user input
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' \
  -E "\.(query|raw|execute)\s*\(\s*['\"`].*\$\{|\.(query|raw)\s*\([^,)]*\+" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_' | head -10 \
  | while IFS= read -r line; do hit_p0 "RAW-QUERY: $line"; done

# Parameterized check hint
grep -rn $EXCL \
  --include='*.py' \
  -E 'cursor\.execute\s*\(\s*(f["\x27]|["\x27][^\x27"]*%[^s])' . 2>/dev/null \
  | grep -v 'test_' | head -10 \
  | while IFS= read -r line; do hit_p0 "SQL-INJECT-PY: $line"; done

[ "$P0_COUNT" -eq 0 ] && ok "SQL injection: tidak terdeteksi (heuristik)" || true

# ═══════════════════════════════════════════════════════════════════
# 2. MISSING INPUT VALIDATION
# ═══════════════════════════════════════════════════════════════════
section "2. MISSING INPUT VALIDATION — P1"

# Request body/params used directly without validation
grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "req\.(body|params|query)\.[a-zA-Z]+" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | grep -vE 'validate|sanitize|joi|yup|zod|Joi\.|schema\.|parseInt\|parseFloat\|Number\(' \
  | head -15 \
  | while IFS= read -r line; do hit_p1 "UNVALIDATED-INPUT: $line"; done

# Python Flask/FastAPI input without validation
grep -rn $EXCL \
  --include='*.py' \
  -E "request\.(args|form|json)\.(get|)\[" . 2>/dev/null \
  | grep -vE 'validate|sanitize|pydantic|schema|int\(|float\(|str\(' \
  | grep -v 'test_' | head -10 \
  | while IFS= read -r line; do hit_p1 "UNVALIDATED-INPUT-PY: $line"; done

# Missing type coercion on numeric params
grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "req\.params\.[a-zA-Z]+" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | grep -vE 'parseInt\|Number\(|parseFloat' | head -10 \
  | while IFS= read -r line; do hit_p2 "PARAM-NO-CAST: $line"; done

[ "$P1_COUNT" -eq 0 ] && ok "Missing validation: tidak terdeteksi" || true

# ═══════════════════════════════════════════════════════════════════
# 3. HARDCODED SECRETS
# ═══════════════════════════════════════════════════════════════════
section "3. HARDCODED SECRETS — P0"

# Hardcoded passwords/keys
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' --include='*.go' \
  --include='*.rb' --include='*.php' --include='*.java' \
  -iE "(password|passwd|secret|api_key|apikey|private_key|auth_token)\s*=\s*['\"][^'\"]{6,}['\"]" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_\|example\|sample\|placeholder\|your_\|<\|TODO' \
  | grep -vE "process\.env\.|os\.environ\|config\[|getenv\|os\.getenv" \
  | head -10 \
  | while IFS= read -r line; do hit_p0 "HARDCODED-SECRET: $line"; done

# .env committed
if git rev-parse --git-dir >/dev/null 2>&1; then
  ENV_COMMITTED=$(git ls-files | grep -E '^\.env$|^\.env\.[^e]' 2>/dev/null)
  if [ -n "$ENV_COMMITTED" ]; then
    hit_p0 ".env FILE DI GIT: $(echo "$ENV_COMMITTED" | tr '\n' ' ')"
  fi
fi

# Bearer token hardcoded in code
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' \
  -E "Bearer [a-zA-Z0-9._-]{20,}|Authorization.*Bearer.*[a-zA-Z0-9]{20,}" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_\|example' | head -5 \
  | while IFS= read -r line; do hit_p0 "HARDCODED-TOKEN: $line"; done

# AWS keys pattern
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' --include='*.go' \
  -E "AKIA[0-9A-Z]{16}|aws_access_key_id\s*=\s*['\"][^'\"]" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|example' | head -5 \
  | while IFS= read -r line; do hit_p0 "AWS-KEY-EXPOSED: $line"; done

[ "$P0_COUNT" -eq 0 ] && ok "Hardcoded secrets: tidak terdeteksi" || true

# ═══════════════════════════════════════════════════════════════════
# 4. MISSING AUTH CHECKS
# ═══════════════════════════════════════════════════════════════════
section "4. MISSING AUTH CHECKS — P0/P1"

# Route handlers without auth middleware (Express)
grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "router\.(get|post|put|delete|patch)\s*\(['\"]" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | while IFS=: read -r file line content; do
      # Check if file has auth middleware imported
      if ! grep -q 'authenticate\|isAuth\|requireAuth\|verifyToken\|passport\|auth\|middleware.*auth' \
           "$file" 2>/dev/null; then
        echo "$file:$line: $content"
      fi
    done 2>/dev/null | head -10 \
  | while IFS= read -r line; do hit_p1 "ROUTE-NO-AUTH-FILE: $line"; done

# API endpoint functions without auth decorator (Python FastAPI)
grep -rn $EXCL \
  --include='*.py' \
  -E "@(app|router)\.(get|post|put|delete|patch)\s*\(['\"]" . 2>/dev/null \
  | grep -v 'test_\|public\|health\|ping\|/docs\|/openapi' \
  | while IFS=: read -r file line content; do
      # Check if auth dependency exists in nearby lines
      CONTEXT=$(sed -n "${line},$((line+5))p" "$file" 2>/dev/null)
      if ! echo "$CONTEXT" | grep -qE 'Depends|get_current_user|oauth2|security|token'; then
        echo "$file:$line: $content"
      fi
    done 2>/dev/null | head -10 \
  | while IFS= read -r line; do hit_p1 "FASTAPI-NO-AUTH: $line"; done

# Admin/internal routes accessible without role check
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' \
  -E '(admin|internal|superuser|root)["\x27/]' . 2>/dev/null \
  | grep -vE '\.test\.\|\.spec\.\|test_\|// |#|readme\|doc\|ADMIN_ROLE' \
  | grep -iE 'route|endpoint|@(app|router)\.|router\.(get|post)' | head -10 \
  | while IFS= read -r line; do hit_p1 "ADMIN-ROUTE-CHECK: $line"; done

[ "$P0_COUNT" -eq 0 ] && [ "$P1_COUNT" -eq 0 ] && ok "Auth checks: tidak terdeteksi masalah" || true

# ═══════════════════════════════════════════════════════════════════
# 5. IDOR (INSECURE DIRECT OBJECT REFERENCE)
# ═══════════════════════════════════════════════════════════════════
section "5. IDOR — P1"

# Find by ID without ownership check
grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "\.(findById|findOne)\s*\(\s*req\.(params|body|query)\." . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | while IFS=: read -r file line content; do
      # Check if surrounding context has user/owner check
      CONTEXT=$(sed -n "$((line-5)),$((line+10))p" "$file" 2>/dev/null)
      if ! echo "$CONTEXT" | grep -qE 'userId|ownerId|createdBy|req\.user|current_user|owner|\.user_id'; then
        echo "$file:$line: $content"
      fi
    done 2>/dev/null | head -10 \
  | while IFS= read -r line; do hit_p1 "IDOR-JS: $line"; done

# Django: get_object_or_404 without user filter
grep -rn $EXCL \
  --include='*.py' \
  -E "get_object_or_404\s*\([^,)]+,\s*(pk|id)\s*=" . 2>/dev/null \
  | grep -v 'test_' \
  | while IFS=: read -r file line content; do
      CONTEXT=$(sed -n "$((line-3)),$((line+5))p" "$file" 2>/dev/null)
      if ! echo "$CONTEXT" | grep -qE 'user=|owner=|created_by=|request\.user'; then
        echo "$file:$line: $content"
      fi
    done 2>/dev/null | head -10 \
  | while IFS= read -r line; do hit_p1 "IDOR-DJANGO: $line"; done

[ "$P1_COUNT" -eq 0 ] && ok "IDOR: tidak terdeteksi" || true

# ═══════════════════════════════════════════════════════════════════
# 6. ADDITIONAL CHECKS
# ═══════════════════════════════════════════════════════════════════
section "6. CEK TAMBAHAN"

# Missing rate limit
grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "app\.(use|post)\s*\(['\"]/(login|auth|register|signup|password)" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | while IFS=: read -r file line content; do
      if ! grep -q 'rateLimit\|rate.limit\|throttle\|limiter' "$file" 2>/dev/null; then
        echo "$file:$line: $content"
      fi
    done 2>/dev/null | head -5 \
  | while IFS= read -r line; do hit_p1 "NO-RATE-LIMIT: $line"; done

# Path traversal
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' \
  -E "readFile\s*\(\s*.*req\.|open\s*\(\s*.*request\." . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_' \
  | grep -vE 'path\.join|os\.path\.join|normalize' | head -5 \
  | while IFS= read -r line; do hit_p0 "PATH-TRAVERSAL: $line"; done

# XSS: innerHTML / dangerouslySetInnerHTML
grep -rn $EXCL \
  --include='*.js' --include='*.jsx' --include='*.ts' --include='*.tsx' \
  -E "innerHTML\s*=|dangerouslySetInnerHTML" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' | head -10 \
  | while IFS= read -r line; do hit_p1 "XSS-RISK: $line"; done

# Open redirect
grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' \
  -E "res\.redirect\s*\(\s*req\.(query|body|params)\." . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.\|test_' | head -5 \
  | while IFS= read -r line; do hit_p1 "OPEN-REDIRECT: $line"; done

# ═══════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════
echo ""
p "═══════════════════════════════════════════════" 196
p "         RED TEAM SUMMARY                      " 196
p "═══════════════════════════════════════════════" 196
echo ""

TOTAL=$((P0_COUNT + P1_COUNT + P2_COUNT))

info "Temuan P0 (Kritis): $P0_COUNT"
info "Temuan P1 (Tinggi): $P1_COUNT"
info "Temuan P2 (Sedang): $P2_COUNT"
info "Total temuan     : $TOTAL"
echo ""

if [ "$P0_COUNT" -gt 0 ]; then
  bad "P0 KRITIS DITEMUKAN — HENTIKAN DEPLOY SEGERA"
  bad "$P0_COUNT temuan P0 wajib difix sebelum merge/deploy"
fi

if [ "$P1_COUNT" -gt 0 ]; then
  bad "P1 TINGGI DITEMUKAN — wajib difix sebelum ke produksi"
  bad "$P1_COUNT temuan P1"
fi

if [ "$P2_COUNT" -gt 0 ]; then
  warn "$P2_COUNT temuan P2 (sedang) — jadwalkan perbaikan"
fi

echo ""
if [ "$((P0_COUNT + P1_COUNT))" -gt 0 ]; then
  bad "RED_TEAM: GAGAL — $((P0_COUNT + P1_COUNT)) temuan P0/P1 ✗"
  echo ""
  info "Selanjutnya:"
  info "  1. Fix semua P0 SEGERA"
  info "  2. Fix P1 sebelum deploy"
  info "  3. Re-run scan: bash skills/red-team/run.sh"
  info "  4. Tambah test negatif untuk setiap temuan"
  exit 1
elif [ "$P2_COUNT" -gt 0 ]; then
  warn "RED_TEAM: PERHATIAN — $P2_COUNT temuan P2"
  p "RED_TEAM: P2 SAJA — review dan jadwalkan" 214
  exit 0
else
  ok "Tidak ada temuan P0/P1/P2 (heuristik grep — bukan pengganti audit penuh)"
  p "RED_TEAM: BERSIH ✓" 82
  exit 0
fi
