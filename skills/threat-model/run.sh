#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  THREAT-MODEL-RUN — generator threat model per surface:
#  ASET/AKTOR/JALUR/DAMPAK/MITIGASI/SISA. Scan pola rentan.
#  Args: $1=surface (auth/payment/upload/api/data)
#  Jalankan: bash skills/threat-model/run.sh <surface>
#  Exit 0.
# ═════════════════════════════════════════════════════════════════
set -u

SURFACE="${1:-api}"

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

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
OUTPUT_DIR=".opencode"
OUTPUT_FILE="$OUTPUT_DIR/threat-model-${DATE}.md"

EXCL="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build"

echo ""
p "═══════════════════════════════════════════════" 213
p "   🛡️  THREAT MODEL — PETA ANCAMAN             " 213
p "═══════════════════════════════════════════════" 213
echo ""
p "SURFACE: $SURFACE | $DATE $TIME" 45
echo ""

# Validate surface
case "$SURFACE" in
  auth|payment|upload|api|data) ok "Surface valid: $SURFACE" ;;
  *)
    warn "Surface '$SURFACE' tidak dikenal"
    info "Pilihan: auth | payment | upload | api | data"
    info "Melanjutkan dengan surface generik..."
    ;;
esac

# ── Define threat data per surface ───────────────────────────────

get_threats() {
  case "$1" in
    auth)
      ASET="Sesi user, token JWT/cookie, password hash, identitas user"
      AKTOR="User tidak login, user lain (nakal), bot/brute-force, insider, eavesdropper"
      JALUR="Login endpoint, reset password, OAuth callback, token refresh, cookie theft"
      THREATS=$(cat <<'EOF'
| P0 | Brute force login    | Rate limiting, lockout, CAPTCHA, MFA       |
| P0 | Token theft (XSS)    | HttpOnly cookie, CSP header, secure flag    |
| P0 | Session fixation     | Regenerate session ID setelah login         |
| P1 | Weak password hash   | bcrypt/argon2 dengan cost ≥12, salt per user|
| P1 | JWT secret exposed   | Env var, rotation, short expiry             |
| P1 | OAuth CSRF           | state parameter + PKCE                     |
| P1 | Password reset abuse | Token 1x pakai, expire 15 menit, rate limit|
| P2 | Username enumeration | Response waktu sama untuk valid/invalid user|
| P2 | Remember me abuse    | Refresh token rotation, revocation list     |
EOF
)
      SISA="MFA opsional (tidak wajib) — user experience tradeoff"
      ;;
    payment)
      ASET="Kartu kredit, data billing, riwayat transaksi, saldo, akun keuangan"
      AKTOR="User nakal, bot, man-in-the-middle, rogue merchant, insider"
      JALUR="Checkout flow, webhook payment provider, refund endpoint, promo/voucher"
      THREATS=$(cat <<'EOF'
| P0 | Card data stored raw | Gunakan tokenisasi (Stripe/Braintree) — jangan simpan sendiri |
| P0 | Replay attack webhook| Webhook signature verify + idempotency key                  |
| P0 | IDOR transaksi       | Verify ownership sebelum akses/refund                       |
| P1 | Race condition refund | Idempotency key, DB lock per transaksi                     |
| P1 | Voucher abuse        | 1x per user, rate limit, server-side validation            |
| P1 | Price tampering      | Harga dari server, bukan dari request body                 |
| P2 | Log data sensitif    | Mask card number di log, PCI DSS compliance                |
| P2 | Test card di produksi| Block test card di prod environment                       |
EOF
)
      SISA="Fraud detection advanced (ML) — di-outsource ke payment provider"
      ;;
    upload)
      ASET="Storage, server filesystem, user data files, CDN bandwidth"
      AKTOR="Attacker (malicious files), regular user (large upload), bot"
      JALUR="File upload endpoint, CDN/storage link, file processing pipeline"
      THREATS=$(cat <<'EOF'
| P0 | Malicious file exec  | Mime type check + magic bytes, rename, no exec permission   |
| P0 | Path traversal       | Sanitize filename (basename only), no ../ allowed          |
| P0 | XXE via XML/SVG      | Disable external entity parsing, sanitize SVG              |
| P1 | Storage exhaustion   | Max file size, quota per user, async processing            |
| P1 | Serving malicious    | Separate subdomain/S3 bucket untuk user uploads            |
| P1 | Zip bomb             | Uncompressed size check, bomb detection                   |
| P2 | File enumeration     | Random filename, private bucket, signed URL                |
| P2 | SSRF via URL upload  | Allowlist domains, block internal IPs (169.254.x.x)        |
EOF
)
      SISA="Virus scanning (ClamAV/cloud) — belum diimplementasi, catat sebagai P1 backlog"
      ;;
    api)
      ASET="Data aplikasi, uptime, rate limit, API key, business logic"
      AKTOR="Pengguna tidak auth, pengguna auth (nakal), bot scraper, partner nakal"
      JALUR="Semua endpoint REST/GraphQL, webhook, public API, API key management"
      THREATS=$(cat <<'EOF'
| P0 | Broken auth          | Auth middleware di semua route, test negatif                |
| P0 | IDOR                 | Verify ownership di setiap read/write resource              |
| P1 | No rate limiting     | Rate limit per IP + per user, khusus auth endpoint         |
| P1 | Mass assignment      | Whitelist fields yang boleh di-update, bukan blacklist      |
| P1 | GraphQL introspection| Disable di prod, depth limit, complexity limit             |
| P1 | Verbose error        | Generic error ke client, detail hanya di log server        |
| P2 | API versioning       | Deprecate v1 dengan notice, jangan break tanpa warning      |
| P2 | CORS misconfiguration| Explicit allowlist, bukan wildcard untuk endpoint sensitif |
EOF
)
      SISA="API abuse detection (ML-based) — future work"
      ;;
    data)
      ASET="PII user (email, nama, nomor), data bisnis, database, analytics"
      AKTOR="Insider, attacker eksternal, user meminta datanya, regulator"
      JALUR="DB connection, backup, export/import, analytics pipeline, third-party SDK"
      THREATS=$(cat <<'EOF'
| P0 | SQL injection        | Parameterized query WAJIB, ORM, no raw concat               |
| P0 | DB credential exposed| Env var, secret manager, rotation, least privilege          |
| P0 | Data breach (export) | Encrypt at rest, audit log akses, encrypt backup           |
| P1 | Overly broad query   | Least privilege DB user, no SELECT * di prod               |
| P1 | PII in logs          | Mask/redact PII sebelum log, GDPR compliance               |
| P1 | Backup unencrypted   | Encrypt backup, test restore, offsite copy                 |
| P2 | Data retention       | Auto-delete sesuai policy, consent management              |
| P2 | Third-party SDK PII  | Audit SDK yang terima PII, DPA agreement                   |
EOF
)
      SISA="Data residency compliance (regional storage) — keputusan arsitektur belum final"
      ;;
    *)
      ASET="Aset aplikasi (definisikan sesuai surface)"
      AKTOR="Anonim, user auth, bot, insider, pihak ketiga"
      JALUR="Endpoint publik, form input, file upload, API key, dependencies"
      THREATS=$(cat <<'EOF'
| P0 | Injeksi              | Parameterized query, sanitasi input                        |
| P0 | Auth bypass          | Auth middleware, test negatif                              |
| P1 | IDOR                 | Ownership check per resource                              |
| P1 | Rate limit hilang    | Implementasi rate limit di endpoint sensitif              |
| P2 | Error verbose        | Generic error ke client, detail di log                    |
EOF
)
      SISA="Belum semua jalur dipetakan — surface generik memerlukan detail manual"
      ;;
  esac
}

get_threats "$SURFACE"

# ── Scan codebase untuk pola rentan ──────────────────────────────
section "SCAN POLA RENTAN DI CODEBASE"

VULN_FINDINGS=""

# No rate limit on auth
NO_RATE_AUTH=$(grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "(app|router)\.(post|put)\s*\(['\"]/(login|auth|register|signup)" . 2>/dev/null \
  | while IFS=: read -r file line content; do
      if ! grep -q 'rateLimit\|rate.limit\|throttle' "$file" 2>/dev/null; then
        echo "$file:$line (no rate limit)"
      fi
    done 2>/dev/null | head -5)

if [ -n "$NO_RATE_AUTH" ]; then
  bad "Auth endpoint tanpa rate limit:"
  echo "$NO_RATE_AUTH" | while IFS= read -r line; do bad "  → $line"; done
  VULN_FINDINGS="${VULN_FINDINGS}NO_RATE_LIMIT\n"
else
  ok "Rate limit pada auth endpoint: OK"
fi

# No auth check
NO_AUTH=$(grep -rn $EXCL \
  --include='*.js' --include='*.ts' \
  -E "router\.(get|post|put|delete)\s*\(" . 2>/dev/null \
  | grep -v '\.test\.\|\.spec\.' \
  | while IFS=: read -r file line content; do
      if ! grep -q 'auth\|verify\|passport\|middleware\|token\|requireLogin' "$file" 2>/dev/null; then
        echo "$file:$line"
      fi
    done 2>/dev/null | wc -l | tr -d ' ')

if [ "$NO_AUTH" -gt 0 ]; then
  warn "$NO_AUTH route file mungkin tanpa auth middleware — cek manual"
else
  ok "Auth middleware check: OK"
fi

# Hardcoded secrets
HARDCODED=$(grep -rn $EXCL \
  --include='*.js' --include='*.ts' --include='*.py' \
  -iE "(secret|password|key)\s*=\s*['\"][^'\"]{6,}['\"]" . 2>/dev/null \
  | grep -vE 'process\.env|os\.environ|example\|test\|fake\|placeholder' \
  | wc -l | tr -d ' ')

if [ "$HARDCODED" -gt 0 ]; then
  bad "$HARDCODED potensi hardcoded secret ditemukan"
  VULN_FINDINGS="${VULN_FINDINGS}HARDCODED_SECRET\n"
else
  ok "Hardcoded secret: tidak terdeteksi"
fi

# ── Buat output dir ──────────────────────────────────────────────
section "GENERATE THREAT MODEL"

mkdir -p "$OUTPUT_DIR" 2>/dev/null
ok "Output: $OUTPUT_FILE"

# Handle duplicate
if [ -f "$OUTPUT_FILE" ]; then
  SUFFIX=$(date +%H%M)
  OUTPUT_FILE="$OUTPUT_DIR/threat-model-${DATE}-${SUFFIX}.md"
  warn "File sudah ada — menyimpan ke: $OUTPUT_FILE"
fi

# ── Tulis threat model document ───────────────────────────────────
cat > "$OUTPUT_FILE" <<THREAT_MODEL
# THREAT MODEL: $(echo "$SURFACE" | tr '[:lower:]' '[:upper:]') — $DATE

> Dibuat otomatis oleh \`skills/threat-model/run.sh $SURFACE\`
> Review dan lengkapi dengan konteks aktual sistem.

---

## SURFACE YANG DIMODELKAN: \`$SURFACE\`

---

## ASET (Yang Dilindungi)

$ASET

---

## AKTOR (Yang Menyerang)

$AKTOR

---

## JALUR SERANGAN

$JALUR

---

## TABEL ANCAMAN

| Dampak | Jalur/Ancaman        | Mitigasi Konkret                                           |
|--------|----------------------|-------------------------------------------------------------|
$THREATS

---

## SISA RISIKO (Diterima)

$SISA

**Disetujui oleh**: _[nama/role — wajib diisi jika P0/P1 ada di SISA]_
**Tanggal review**: $DATE

---

## TEMUAN SCAN OTOMATIS

$(if [ -n "$VULN_FINDINGS" ]; then
  echo "⚠️ **Pola rentan terdeteksi di kode:**"
  echo ""
  printf '%b' "$VULN_FINDINGS" | while IFS= read -r f; do
    [ -n "$f" ] && echo "- $f"
  done
  echo ""
  echo "> Jalankan \`bash skills/red-team/run.sh\` untuk detail lengkap"
else
  echo "✅ Tidak ada pola rentan mencolok terdeteksi (scan heuristik)"
fi)

---

## CHECKLIST SEBELUM DEPLOY

- [ ] Setiap jalur P0 punya mitigasi konkret
- [ ] Setiap jalur P1 punya mitigasi atau masuk SISA dengan persetujuan
- [ ] Dependencies eksternal dipetakan sebagai jalur (API, SDK, CDN)
- [ ] Test negatif untuk setiap jalur P0/P1 ditulis
- [ ] Red-team test dilakukan setelah implementasi
- [ ] Model ini diupdate jika ada perubahan surface

---

## REFERENSI

- Red team: \`bash skills/red-team/run.sh\`
- Dependency audit: \`bash skills/dependency/run.sh\`
- Threat model sebelumnya: \`.opencode/threat-model-*.md\`

---

*Model ditulis SEBELUM koding — ditemukan saat audit = terlambat.*
*Dibuat: $DATE $TIME*
THREAT_MODEL

ok "Threat model disimpan: $OUTPUT_FILE"

# ── Tampilkan ringkasan ke terminal ──────────────────────────────
echo ""
section "RINGKASAN ANCAMAN — $SURFACE"
p "  ── Tabel ancaman ──" 45
echo "$THREATS" | while IFS= read -r line; do
  if echo "$line" | grep -q '| P0'; then
    echo -e "${RED}  $line${NC}"
  elif echo "$line" | grep -q '| P1'; then
    echo -e "${YELLOW}  $line${NC}"
  else
    echo -e "${CYAN}  $line${NC}"
  fi
done

echo ""
p "═══════════════════════════════════════════════" 213
p "         THREAT MODEL SELESAI                  " 213
p "═══════════════════════════════════════════════" 213
echo ""
ok "File: $OUTPUT_FILE"
warn "WAJIB: isi SISA RISIKO dengan persetujuan jika ada P0/P1 di sana"
warn "URUTAN: threat-model SEBELUM koding, red-team SETELAH koding"
echo ""
p "THREAT_MODEL: template siap untuk surface '$SURFACE'" 82
exit 0
