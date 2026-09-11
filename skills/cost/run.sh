#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  COST — estimasi biaya sebelum aksi berbiaya (HUKUM 5).
#  Args: $1=service_name  $2=unit_count  $3=unit_type
#  Membaca cost config dari repo bila ada.
#  Output: laporan BEST/WAJAR/TERBURUK + PUTUSAN.
#  Exit 0 selalu (keputusan di tangan user).
# ═════════════════════════════════════════════════════════════════
set -u

p()   { printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok()  { p "  ✔ $1" 82; }
bad() { p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }
sep() { p "═══════════════════════════════════════════" 33; }

SERVICE="${1:-}"
UNITS="${2:-}"
UNIT_TYPE="${3:-}"

echo ""
sep
p "    💰 COST — ESTIMASI BIAYA SEBELUM AKSI (HUKUM 5)   " 33
sep
echo ""

# ── Cari cost config di repo ──────────────────────────────────────
REPO_ROOT="."
CONFIG_FILES=""
FOUND_CONFIG=""

# Cari file konfigurasi harga yang umum di repo
for candidate in \
  ".opencode/cost.md" \
  ".opencode/cost.txt" \
  ".opencode/pricing.md" \
  "docs/cost.md" \
  "docs/pricing.md" \
  "COST.md" \
  "PRICING.md" \
  "cost.yaml" \
  "cost.yml" \
  "pricing.yaml" \
  "pricing.yml" \
  ".env.example" \
  "README.md"
do
  if [ -f "$REPO_ROOT/$candidate" ]; then
    CONFIG_FILES="$CONFIG_FILES $candidate"
  fi
done

p "▸ LANGKAH 1: SUMBER ANGKA DI REPO" 45
echo ""
if [ -n "$CONFIG_FILES" ]; then
  for cf in $CONFIG_FILES; do
    info "Ditemukan: $cf"
    # Cari baris yang mengandung harga / price / cost / rate
    PRICE_LINES=$(grep -niE '(price|cost|harga|biaya|rate|per_|tarif|\$|usd|idr|rp\b)' "$REPO_ROOT/$cf" 2>/dev/null | head -5)
    if [ -n "$PRICE_LINES" ]; then
      FOUND_CONFIG="$cf"
      p "    Referensi harga di $cf:" 111
      echo "$PRICE_LINES" | while IFS= read -r line; do
        p "    $line" 245
      done
    fi
  done
  echo ""
else
  warn "Tidak ada file cost/pricing di repo — angka dari referensi publik"
  info "Buat .opencode/cost.md untuk menyimpan harga spesifik project"
  echo ""
fi

# ── Validasi argumen ─────────────────────────────────────────────
if [ -z "$SERVICE" ]; then
  p "▸ MODE: TEMPLATE KOSONG (tidak ada argumen)" 45
  echo ""
  warn "Gunakan: bash skills/cost/run.sh <service> <jumlah> <unit>"
  p "" 0
  p "  Contoh:" 111
  p "    bash skills/cost/run.sh openai-gpt4 1000 requests" 245
  p "    bash skills/cost/run.sh aws-lambda 10000 invocations" 245
  p "    bash skills/cost/run.sh s3-storage 50 GB-month" 245
  p "    bash skills/cost/run.sh anthropic-claude 500 1k-tokens" 245
  echo ""
  p "▸ TEMPLATE LAPORAN COST" 45
  echo ""
  p "  ┌──────────────────────────────────────────────────────────────┐" 240
  p "  │ COST   : <nama aksi/service>                                 │" 240
  p "  │ SUMBER : <file repo / docs>  BUKTI: <angka dari sumber>      │" 240
  p "  │ VOLUME : <jumlah call/token/storage/compute>                 │" 240
  p "  │ SKALA  : terbaik X / wajar Y / terburuk Z (unit/Rp/USD)     │" 240
  p "  │ ALTERN : <pakai yang sudah ada> / <alternatif termurah>      │" 240
  p "  │ PUTUSAN: BUTUH KONFIRMASI USER — <1 kalimat dengan angka>    │" 240
  p "  └──────────────────────────────────────────────────────────────┘" 240
  echo ""
  sep
  p "  COST_RESULT: template ditampilkan — isi argumen untuk estimasi penuh" 33
  sep
  echo ""
  exit 0
fi

# ── Harga referensi bawaan (diperbarui secara berkala) ────────────
# Format: service:best_per_unit:typical_per_unit:worst_per_unit:currency:notes
declare -A PRICE_BEST PRICE_TYPICAL PRICE_WORST PRICE_UNIT PRICE_NOTE

PRICE_BEST["openai-gpt4"]="0.01"
PRICE_TYPICAL["openai-gpt4"]="0.03"
PRICE_WORST["openai-gpt4"]="0.06"
PRICE_UNIT["openai-gpt4"]="USD per 1K tokens"
PRICE_NOTE["openai-gpt4"]="GPT-4 input/output; periksa platform.openai.com"

PRICE_BEST["openai-gpt35"]="0.0005"
PRICE_TYPICAL["openai-gpt35"]="0.0015"
PRICE_WORST["openai-gpt35"]="0.002"
PRICE_UNIT["openai-gpt35"]="USD per 1K tokens"
PRICE_NOTE["openai-gpt35"]="GPT-3.5-turbo; periksa platform.openai.com"

PRICE_BEST["anthropic-claude"]="0.008"
PRICE_TYPICAL["anthropic-claude"]="0.024"
PRICE_WORST["anthropic-claude"]="0.048"
PRICE_UNIT["anthropic-claude"]="USD per 1K tokens"
PRICE_NOTE["anthropic-claude"]="Claude 3; periksa console.anthropic.com"

PRICE_BEST["aws-lambda"]="0.0000002"
PRICE_TYPICAL["aws-lambda"]="0.000002"
PRICE_WORST["aws-lambda"]="0.00002"
PRICE_UNIT["aws-lambda"]="USD per invocation"
PRICE_NOTE["aws-lambda"]="Free tier: 1M req/bln; periksa aws.amazon.com/lambda/pricing"

PRICE_BEST["s3-storage"]="0.021"
PRICE_TYPICAL["s3-storage"]="0.023"
PRICE_WORST["s3-storage"]="0.025"
PRICE_UNIT["s3-storage"]="USD per GB-month"
PRICE_NOTE["s3-storage"]="S3 Standard; region us-east-1; periksa aws.amazon.com/s3/pricing"

PRICE_BEST["cloudflare-workers"]="0.0000005"
PRICE_TYPICAL["cloudflare-workers"]="0.0000003"
PRICE_WORST["cloudflare-workers"]="0.0000005"
PRICE_UNIT["cloudflare-workers"]="USD per request"
PRICE_NOTE["cloudflare-workers"]="Free tier: 100K req/hari; periksa cloudflare.com/workers"

PRICE_BEST["vercel"]="0"
PRICE_TYPICAL["vercel"]="0"
PRICE_WORST["vercel"]="20"
PRICE_UNIT["vercel"]="USD per bulan"
PRICE_NOTE["vercel"]="Hobby: gratis; Pro: $20/bln; periksa vercel.com/pricing"

SERVICE_KEY=$(echo "$SERVICE" | tr '[:upper:]' '[:lower:]')
UNITS_NUM="${UNITS:-1}"
UNIT_TYPE_DISPLAY="${UNIT_TYPE:-unit}"
if ! printf '%s' "$UNITS_NUM" | grep -qE '^[0-9]+([.][0-9]+)?$'; then
  warn "Volume harus angka positif sederhana: $UNITS_NUM"
  exit 1
fi

# ── Tampilkan laporan estimasi ────────────────────────────────────
p "▸ LANGKAH 2: VOLUME DAN SKALA" 45
echo ""
info "Service  : $SERVICE"
info "Volume   : $UNITS_NUM $UNIT_TYPE_DISPLAY"
echo ""

# Cek apakah service dikenal
if [ -n "${PRICE_BEST[$SERVICE_KEY]+x}" ]; then
  BEST="${PRICE_BEST[$SERVICE_KEY]}"
  TYP="${PRICE_TYPICAL[$SERVICE_KEY]}"
  WORST="${PRICE_WORST[$SERVICE_KEY]}"
  UNIT_LABEL="${PRICE_UNIT[$SERVICE_KEY]}"
  NOTE="${PRICE_NOTE[$SERVICE_KEY]}"
  SOURCE="referensi bawaan"

  # Hitung total (hanya untuk angka integer/float sederhana)
  TOTAL_BEST=$(awk -v price="$BEST" -v units="$UNITS_NUM" 'BEGIN{printf "%.4f", price * units}' 2>/dev/null || echo "~")
  TOTAL_TYP=$(awk -v price="$TYP" -v units="$UNITS_NUM" 'BEGIN{printf "%.4f", price * units}' 2>/dev/null || echo "~")
  TOTAL_WORST=$(awk -v price="$WORST" -v units="$UNITS_NUM" 'BEGIN{printf "%.4f", price * units}' 2>/dev/null || echo "~")

  p "▸ LANGKAH 3: ESTIMASI BIAYA" 45
  echo ""
  p "  ┌──────────────────────────────────────────────────────────────┐" 240
  p "  │ COST   : $SERVICE ($UNITS_NUM $UNIT_TYPE_DISPLAY)" 33
  p "  │ SUMBER : $SOURCE   BUKTI: $UNIT_LABEL" 111
  p "  │ VOLUME : $UNITS_NUM $UNIT_TYPE_DISPLAY" 111
  p "  │ SKALA  :" 214
  ok "│    BEST     : $BEST/unit × $UNITS_NUM = \$${TOTAL_BEST} USD"
  warn "│    WAJAR    : $TYP/unit × $UNITS_NUM = \$${TOTAL_TYP} USD"
  bad "│    TERBURUK : $WORST/unit × $UNITS_NUM = \$${TOTAL_WORST} USD"
  p "  │ CATATAN: $NOTE" 245
  p "  └──────────────────────────────────────────────────────────────┘" 240
  echo ""

  p "▸ LANGKAH 4: ALTERNATIF" 45
  echo ""
  case "$SERVICE_KEY" in
    openai-gpt4)
      info "Alternatif lebih hemat: GPT-3.5-turbo (~10× lebih murah)"
      info "Alternatif lokal: ollama/llama (gratis, butuh GPU)"
      ;;
    anthropic-claude)
      info "Alternatif: Claude Haiku (lebih murah), GPT-3.5, Mistral lokal"
      ;;
    aws-lambda)
      info "Alternatif: Cek apakah free tier mencukupi (1M req/bln gratis)"
      info "Alternatif: Container/EC2 bila > 1M req/hari"
      ;;
    s3-storage)
      info "Alternatif: S3 Glacier (lebih murah untuk arsip)"
      info "Alternatif: Cloudflare R2 (~$0.015/GB, tanpa egress fee)"
      ;;
    *)
      info "Cek dokumentasi official untuk alternatif tier lebih hemat"
      ;;
  esac
  echo ""

else
  # Service tidak dikenal — tampilkan template kosong
  warn "Service '$SERVICE' tidak ada di daftar referensi bawaan"
  info "Sumber harga: cari di dokumentasi official service tersebut"
  echo ""
  p "▸ TEMPLATE ESTIMASI (isi manual)" 45
  echo ""
  p "  ┌──────────────────────────────────────────────────────────────┐" 240
  p "  │ COST   : $SERVICE" 33
  p "  │ SUMBER : <cari di docs/$SERVICE atau README>  BUKTI: <angka>│" 111
  p "  │ VOLUME : $UNITS_NUM $UNIT_TYPE_DISPLAY" 111
  p "  │ SKALA  :" 214
  p "  │    BEST     : ? per unit × $UNITS_NUM = ? total" 82
  p "  │    WAJAR    : ? per unit × $UNITS_NUM = ? total" 214
  p "  │    TERBURUK : ? per unit × $UNITS_NUM = ? total" 196
  p "  │ ALTERN : <cek resource yang sudah ada di repo dulu>          │" 245
  p "  └──────────────────────────────────────────────────────────────┘" 240
  echo ""
  warn "ANGKA BELUM DIISI — cari sumber dulu sebelum melaporkan estimasi"
  echo ""
fi

# ── Putusan akhir ─────────────────────────────────────────────────
sep
if [ -n "${PRICE_BEST[$SERVICE_KEY]+x}" ]; then
  bad "  PUTUSAN: BUTUH KONFIRMASI USER"
  bad "  → Estimasi wajar \$${TOTAL_TYP} untuk $UNITS_NUM $UNIT_TYPE_DISPLAY $SERVICE"
  bad "  → HUKUM 5: tanpa konfirmasi user = TIDAK JALAN"
else
  bad "  PUTUSAN: BUTUH KONFIRMASI USER"
  bad "  → Isi angka estimasi dari sumber official dulu, laporkan ke user"
  bad "  → HUKUM 5: tanpa konfirmasi user = TIDAK JALAN"
fi
sep
echo ""
exit 0
