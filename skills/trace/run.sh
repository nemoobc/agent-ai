#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  TRACE — validasi rantai bukti (HUKUM 11): setiap KLAIM wajib
#  punya BUKTI fisik. Baca laporan dari stdin atau $1=claim text.
#  Exit 0 = semua klaim punya bukti. Exit 1 = ada klaim tanpa bukti.
# ═════════════════════════════════════════════════════════════════
set -u

p()  { printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok() { p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }
sep(){ p "═══════════════════════════════════════════" 33; }

CLAIM_ARG="${1:-}"

echo ""
sep
p "        🔍 TRACE — RANTAI BUKTI (HUKUM 11)       " 33
sep
echo ""

# ── Baca input ──────────────────────────────────────────────────
if [ -n "$CLAIM_ARG" ]; then
  # Argumen posisi: bisa path file atau teks klaim langsung
  if [ -f "$CLAIM_ARG" ]; then
    INPUT=$(cat "$CLAIM_ARG")
    info "Membaca file: $CLAIM_ARG"
  else
    INPUT="$CLAIM_ARG"
    info "Memvalidasi klaim langsung: ${CLAIM_ARG:0:60}"
  fi
elif [ ! -t 0 ]; then
  INPUT=$(cat)
  info "Membaca laporan dari stdin"
else
  bad "Tidak ada input. Kirim laporan via stdin atau berikan klaim sebagai \$1"
  echo ""
  p "CONTOH PENGGUNAAN:" 214
  p "  echo 'KLAIM: auth berjalan' | bash skills/trace/run.sh" 245
  p "  bash skills/trace/run.sh laporan_draft.md" 245
  p "  bash skills/trace/run.sh 'semua test lulus'" 245
  echo ""
  exit 1
fi

if [ -z "$INPUT" ]; then
  bad "Input kosong — tidak ada yang divalidasi"
  exit 1
fi

echo ""
p "▸ LANGKAH 1: EKSTRAK KLAIM" 45
echo ""

# ── Ekstrak pasangan KLAIM + BUKTI dari teks terstruktur ─────────
# Format yang dikenali:
#   KLAIM: "<teks>"
#   BUKTI : <teks>
# Juga deteksi klaim bebas (baris berisi kata "klaim" atau pola laporan)

KLAIM_COUNT=0
BUKTI_COUNT=0
MISSING=0
REPORT_LINES=""

# Parse blok KLAIM/BUKTI terstruktur
while IFS= read -r line; do
  # Cek baris KLAIM:
  if echo "$line" | grep -qiE '^[[:space:]]*(KLAIM|CLAIM)[[:space:]]*:'; then
    KLAIM_COUNT=$((KLAIM_COUNT + 1))
    CURRENT_KLAIM=$(echo "$line" | sed 's/^[[:space:]]*[Kk][Ll][Aa][Ii][Mm][[:space:]]*:[[:space:]]*//')
    CURRENT_ID="K${KLAIM_COUNT}"
    HAS_BUKTI=0
  fi

  # Cek baris BUKTI: (tepat setelah KLAIM)
  if echo "$line" | grep -qiE '^[[:space:]]*(BUKTI|EVIDENCE|PROOF)[[:space:]]*:'; then
    BUKTI_VAL=$(echo "$line" | sed 's/^[[:space:]]*[[:alpha:]]*[[:space:]]*:[[:space:]]*//')
    if [ -n "$BUKTI_VAL" ] && [ "$BUKTI_VAL" != "-" ] && [ "$BUKTI_VAL" != "?" ]; then
      HAS_BUKTI=1
      BUKTI_COUNT=$((BUKTI_COUNT + 1))
    fi
  fi

  # Cek baris BENTUK: (sebagai tambahan penanda blok)
  if echo "$line" | grep -qiE '^[[:space:]]*(BENTUK|TYPE)[[:space:]]*:'; then
    BENTUK_VAL=$(echo "$line" | sed 's/^[[:space:]]*[[:alpha:]]*[[:space:]]*:[[:space:]]*//')
  fi

done <<< "$INPUT"

echo ""

# ── Analisis ulang dengan pengelompokan blok ─────────────────────
# Proses blok: KLAIM..BUKTI sebagai satu unit
BLOCK_KLAIM=""
BLOCK_BUKTI=""
BLOCK_BENTUK=""
BLOCK_SELAIN=""
IN_BLOCK=0
BLOCK_NUM=0
MISSING=0
CLEAN=0

while IFS= read -r line; do
  if echo "$line" | grep -qiE '^[[:space:]]*(KLAIM|CLAIM)[[:space:]]*:'; then
    # Simpan blok sebelumnya bila ada
    if [ "$IN_BLOCK" -eq 1 ]; then
      BLOCK_NUM=$((BLOCK_NUM + 1))
      if [ -z "$BLOCK_BUKTI" ] || [ "$BLOCK_BUKTI" = "-" ] || [ "$BLOCK_BUKTI" = "?" ]; then
        bad "[$BLOCK_NUM] KLAIM: $BLOCK_KLAIM"
        bad "    BUKTI : ✗ TIDAK ADA — klaim ini TIDAK VALID (HUKUM 11)"
        MISSING=$((MISSING + 1))
      else
        ok "[$BLOCK_NUM] KLAIM: $BLOCK_KLAIM"
        ok "    BUKTI : $BLOCK_BUKTI"
        [ -n "$BLOCK_BENTUK" ] && info "    BENTUK: $BLOCK_BENTUK"
        [ -n "$BLOCK_SELAIN" ] && warn "    SELAIN: $BLOCK_SELAIN"
        CLEAN=$((CLEAN + 1))
      fi
      echo ""
    fi
    BLOCK_KLAIM=$(echo "$line" | sed 's/^[[:space:]]*[Kk][Ll][Aa][Ii][Mm][[:space:]]*:[[:space:]]*//' | tr -d '"')
    BLOCK_BUKTI=""
    BLOCK_BENTUK=""
    BLOCK_SELAIN=""
    IN_BLOCK=1
  elif echo "$line" | grep -qiE '^[[:space:]]*(BUKTI|EVIDENCE)[[:space:]]*:' && [ "$IN_BLOCK" -eq 1 ]; then
    BLOCK_BUKTI=$(echo "$line" | sed 's/^[[:space:]]*[[:alpha:]]*[[:space:]]*:[[:space:]]*//')
  elif echo "$line" | grep -qiE '^[[:space:]]*(BENTUK|TYPE)[[:space:]]*:' && [ "$IN_BLOCK" -eq 1 ]; then
    BLOCK_BENTUK=$(echo "$line" | sed 's/^[[:space:]]*[[:alpha:]]*[[:space:]]*:[[:space:]]*//')
  elif echo "$line" | grep -qiE '^[[:space:]]*(SELAIN|BESIDES)[[:space:]]*:' && [ "$IN_BLOCK" -eq 1 ]; then
    BLOCK_SELAIN=$(echo "$line" | sed 's/^[[:space:]]*[[:alpha:]]*[[:space:]]*:[[:space:]]*//')
  fi
done <<< "$INPUT"

# Tutup blok terakhir
if [ "$IN_BLOCK" -eq 1 ]; then
  BLOCK_NUM=$((BLOCK_NUM + 1))
  if [ -z "$BLOCK_BUKTI" ] || [ "$BLOCK_BUKTI" = "-" ] || [ "$BLOCK_BUKTI" = "?" ]; then
    bad "[$BLOCK_NUM] KLAIM: $BLOCK_KLAIM"
    bad "    BUKTI : ✗ TIDAK ADA — klaim ini TIDAK VALID (HUKUM 11)"
    MISSING=$((MISSING + 1))
  else
    ok "[$BLOCK_NUM] KLAIM: $BLOCK_KLAIM"
    ok "    BUKTI : $BLOCK_BUKTI"
    [ -n "$BLOCK_BENTUK" ] && info "    BENTUK: $BLOCK_BENTUK"
    [ -n "$BLOCK_SELAIN" ] && warn "    SELAIN: $BLOCK_SELAIN"
    CLEAN=$((CLEAN + 1))
  fi
  echo ""
fi

# ── Jika tidak ada blok terstruktur, coba deteksi klaim bebas ────
TOTAL=$((CLEAN + MISSING))
if [ "$TOTAL" -eq 0 ]; then
  p "▸ DETEKSI: tidak ada blok KLAIM terstruktur — analisis teks bebas" 45
  echo ""

  # Deteksi kalimat dengan pola klaim: "berhasil", "lulus", "selesai", "aman", "clean"
  CLAIM_LINES=$(echo "$INPUT" | grep -niE '(berhasil|lulus|selesai|aman|clean|pass|sukses|beres|jalan|berfungsi|completed|working)' | head -20)

  if [ -n "$CLAIM_LINES" ]; then
    warn "Ditemukan kalimat yang terlihat seperti klaim — perlu validasi manual:"
    echo ""
    while IFS= read -r cline; do
      bad "  KLAIM BEBAS: $cline"
      bad "    BUKTI : ✗ — format tidak terstruktur, tidak bisa diverifikasi otomatis"
      MISSING=$((MISSING + 1))
      TOTAL=$((TOTAL + 1))
    done <<< "$CLAIM_LINES"
    echo ""
    warn "Gunakan format terstruktur:"
    p "  KLAIM: \"<pernyataan>\"" 245
    p "  BENTUK: [TEST|AUDIT|ANGKA|OUTPUT|FILE]" 245
    p "  BUKTI : <exit code / file:baris / angka> → <perintah>" 245
    p "  SELAIN: <apa yang tidak dibuktikan>" 245
  else
    info "Tidak ada klaim yang terdeteksi dalam input"
    info "Kirim laporan dengan format KLAIM:/BUKTI: untuk validasi penuh"
    TOTAL=0
  fi
  echo ""
fi

# ── Ringkasan ────────────────────────────────────────────────────
echo ""
sep
p "               RANTAI BUKTI — RINGKASAN              " 33
sep
echo ""
info "Total klaim     : $TOTAL"
ok   "Klaim dengan bukti : $CLEAN"
if [ "$MISSING" -gt 0 ]; then
  bad "Klaim tanpa bukti  : $MISSING  ← PELANGGARAN HUKUM 11"
else
  ok  "Klaim tanpa bukti  : 0"
fi
echo ""

if [ "$TOTAL" -eq 0 ]; then
  warn "TRACE_RESULT: TIDAK ADA KLAIM — tidak ada yang divalidasi"
  exit 0
elif [ "$MISSING" -gt 0 ]; then
  bad "TRACE_RESULT: GAGAL — $MISSING klaim tanpa rantai bukti ✗"
  echo ""
  bad "Tindakan: hapus klaim tersebut atau buktikan dulu sebelum lapor SELESAI"
  echo ""
  exit 1
else
  ok  "TRACE_RESULT: VALID — semua $CLEAN klaim punya rantai bukti ✓"
  echo ""
  exit 0
fi
