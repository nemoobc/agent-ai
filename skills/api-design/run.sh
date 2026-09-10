#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  API-DESIGN-RUN — scaffolder kontrak API: METHOD+path, skema
#  request/response, error codes, contoh curl. Tanpa args: scan
#  route yang ada. Output markdown ke stdout.
#  Jalankan: bash skills/api-design/run.sh [METHOD] [/path] [desc]
#  Exit 0 selalu (informasi).
# ═════════════════════════════════════════════════════════════════
set -u

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

METHOD="${1:-}"
ENDPOINT="${2:-}"
DESC="${3:-}"
DATE=$(date +%Y-%m-%d)

echo ""
p "═══════════════════════════════════════════════" 213
p "       📐 API-DESIGN — KONTRAK DULU            " 213
p "═══════════════════════════════════════════════" 213
echo ""

# ── MODE: scan existing routes if no args ────────────────────────
if [ -z "$METHOD" ]; then
  section "SCAN EXISTING ROUTES"
  info "Tidak ada args — memindai route yang sudah ada di project..."
  echo ""

  FOUND=0

  # Express/Fastify/Koa (JS/TS)
  if find . -type f \( -name '*.js' -o -name '*.ts' \) \
       -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | head -1 | grep -q .; then
    p "  ── Node.js / Express routes ──" 45
    grep -rn --include='*.js' --include='*.ts' \
      -E "\.(get|post|put|patch|delete|options)\s*\(['\"]/" \
      --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null \
      | grep -v 'node_modules' \
      | sed "s|^\./||" \
      | awk -F: '{printf "  %-50s %s:%s\n", $3, $1, $2}' \
      | head -40 \
      | while IFS= read -r line; do echo -e "${CYAN}${line}${NC}"; done
    FOUND=1
  fi

  # Python FastAPI/Flask
  if find . -type f -name '*.py' -not -path '*/.git/*' 2>/dev/null | head -1 | grep -q .; then
    p "  ── Python (FastAPI/Flask) routes ──" 45
    grep -rn --include='*.py' \
      -E "@(app|router)\.(get|post|put|patch|delete)\s*\(['\"]/" \
      --exclude-dir=.git . 2>/dev/null \
      | sed "s|^\./||" \
      | awk -F: '{printf "  %-50s %s:%s\n", $3, $1, $2}' \
      | head -40 \
      | while IFS= read -r line; do echo -e "${CYAN}${line}${NC}"; done
    FOUND=1
  fi

  # Go (gin/chi/mux)
  if find . -type f -name '*.go' -not -path '*/.git/*' 2>/dev/null | head -1 | grep -q .; then
    p "  ── Go (gin/chi/mux) routes ──" 45
    grep -rn --include='*.go' \
      -E "\.(GET|POST|PUT|PATCH|DELETE|Handle)\s*\(['\"]/" \
      --exclude-dir=.git . 2>/dev/null \
      | sed "s|^\./||" \
      | awk -F: '{printf "  %-50s %s:%s\n", $3, $1, $2}' \
      | head -40 \
      | while IFS= read -r line; do echo -e "${CYAN}${line}${NC}"; done
    FOUND=1
  fi

  if [ "$FOUND" -eq 0 ]; then
    warn "Tidak ada route ditemukan. Coba: bash skills/api-design/run.sh GET /users 'Get all users'"
  fi

  echo ""
  info "Gunakan: bash skills/api-design/run.sh <METHOD> <path> <description>"
  info "Contoh : bash skills/api-design/run.sh POST /api/v1/users 'Create a new user'"
  echo ""
  p "API_DESIGN: scan selesai — desain kontrak dengan args di atas" 45
  exit 0
fi

# ── MODE: generate contract ──────────────────────────────────────
METHOD_UPPER=$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')
ENDPOINT="${ENDPOINT:-/api/v1/resource}"
DESC="${DESC:-No description provided}"

# Detect versioning from path
VERSION=$(echo "$ENDPOINT" | grep -oE 'v[0-9]+' | head -1)
[ -z "$VERSION" ] && VERSION="v1"

# Detect resource name from path
RESOURCE=$(echo "$ENDPOINT" | sed 's|.*/||' | sed 's|[{}:?].*||' | tr '-' '_')
[ -z "$RESOURCE" ] && RESOURCE="resource"

section "GENERATING API CONTRACT"
ok "Method   : $METHOD_UPPER"
ok "Path     : $ENDPOINT"
ok "Desc     : $DESC"
ok "Resource : $RESOURCE"
ok "Version  : $VERSION"
echo ""

# Generate request schema based on method
REQ_SCHEMA=""
if [[ "$METHOD_UPPER" =~ ^(POST|PUT|PATCH)$ ]]; then
  REQ_SCHEMA=$(cat <<EOF
\`\`\`json
{
  "field_1": "string (required) — describe field",
  "field_2": 0,
  "field_3": true
}
\`\`\`
EOF
)
else
  REQ_SCHEMA="\`\`\`\nQuery params:\n  ?limit=20    — max items per page (default: 20)\n  ?offset=0   — pagination offset\n  ?filter=    — optional filter key\n\`\`\`"
fi

# Generate curl example
if [[ "$METHOD_UPPER" =~ ^(POST|PUT|PATCH)$ ]]; then
  CURL_EXAMPLE="curl -X $METHOD_UPPER https://api.example.com$ENDPOINT \\
  -H 'Content-Type: application/json' \\
  -H 'Authorization: Bearer <token>' \\
  -d '{\"field_1\": \"value\", \"field_2\": 0}'"
elif [ "$METHOD_UPPER" = "DELETE" ]; then
  CURL_EXAMPLE="curl -X DELETE https://api.example.com$ENDPOINT \\
  -H 'Authorization: Bearer <token>'"
else
  CURL_EXAMPLE="curl -X GET 'https://api.example.com$ENDPOINT?limit=20&offset=0' \\
  -H 'Authorization: Bearer <token>'"
fi

# Output the contract as markdown
cat <<MARKDOWN

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  API CONTRACT — Generated $DATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## $METHOD_UPPER $ENDPOINT

**Deskripsi**: $DESC

---

### Request

**Headers** (required):
\`\`\`
Authorization: Bearer <token>
Content-Type: application/json
Accept: application/json
\`\`\`

**Schema**:
$REQ_SCHEMA

---

### Response — 200/201 OK

\`\`\`json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "meta": {
    "total": 100,
    "limit": 20,
    "offset": 0
  }
}
\`\`\`

---

### Error Codes

| Code | Kondisi                          | Response Body                                         |
|------|----------------------------------|-------------------------------------------------------|
| 400  | Validasi gagal / bad request     | \`{"success":false,"error":"VALIDATION_ERROR","msg":"..."}\` |
| 401  | Token tidak ada / expired        | \`{"success":false,"error":"UNAUTHORIZED","msg":"..."}\`     |
| 403  | Akses ditolak (bukan pemilik)    | \`{"success":false,"error":"FORBIDDEN","msg":"..."}\`        |
| 404  | Resource tidak ditemukan         | \`{"success":false,"error":"NOT_FOUND","msg":"..."}\`        |
| 409  | Konflik (duplikat)               | \`{"success":false,"error":"CONFLICT","msg":"..."}\`         |
| 422  | Data tidak bisa diproses         | \`{"success":false,"error":"UNPROCESSABLE","msg":"..."}\`    |
| 429  | Rate limit terlampaui            | \`{"success":false,"error":"TOO_MANY_REQUESTS","msg":"..."}\`|
| 500  | Internal server error            | \`{"success":false,"error":"INTERNAL_ERROR","msg":"..."}\`   |

---

### Contoh curl

\`\`\`bash
$CURL_EXAMPLE
\`\`\`

---

### Catatan Desain

- [ ] Breaking change? → perlu versi baru (/v$((${VERSION#v}+1))/) atau deprecation notice
- [ ] Rate limit: ___ req/menit per user
- [ ] Auth scope yang dibutuhkan: ___
- [ ] Apakah idempotent? (untuk PUT/DELETE)
- [ ] Apakah perlu pagination? (untuk GET list)
- [ ] Apakah ada webhook/event yang dipicu?

---
*Kontrak ini WAJIB disepakati sebelum implementasi.*
*Perubahan breaking = versi baru + deprecation notice.*

MARKDOWN

echo ""
p "═══════════════════════════════════════════════" 213
p " API_DESIGN: kontrak di atas → review → koding " 213
p "═══════════════════════════════════════════════" 213
echo ""
exit 0
