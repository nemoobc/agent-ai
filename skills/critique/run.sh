#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  CRITIQUE — serangan adversarial 5 tembakan ke hasil kerja.
#  Args: $1=file (opsional, default stdin)
#  Tembakan: SPESIFIKASI → LOGIKA → BUKTI → SKENARIO → GAP
#  Output: temuan per tembakan + SEVERITY + VERDICT: CLEAN / VETO(n)
#  Exit 0 bila CLEAN, exit 1 bila VETO.
# ═════════════════════════════════════════════════════════════════
set -u

p()    { printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok()   { p "  ✔ $1" 82; }
bad()  { p "  ✖ $1" 196; }
warn() { p "  ⚠ $1" 214; }
info() { p "  ℹ $1" 111; }
sep()  { p "═══════════════════════════════════════════" 33; }

sev_critical(){ printf '\033[38;5;196m  [CRITICAL] %s\033[0m\n' "$1"; }
sev_high()    { printf '\033[38;5;214m  [HIGH    ] %s\033[0m\n' "$1"; }
sev_medium()  { printf '\033[38;5;226m  [MEDIUM  ] %s\033[0m\n' "$1"; }
sev_low()     { printf '\033[38;5;111m  [LOW     ] %s\033[0m\n' "$1"; }

INPUT_FILE="${1:-}"
TOTAL_VETO=0

echo ""
sep
p "   ⚔  CRITIQUE — SERANGAN ADVERSARIAL 5 TEMBAKAN     " 33
sep
echo ""

# ── Baca input ───────────────────────────────────────────────────
if [ -n "$INPUT_FILE" ]; then
  if [ -f "$INPUT_FILE" ]; then
    INPUT=$(cat "$INPUT_FILE")
    info "File: $INPUT_FILE ($(echo "$INPUT" | wc -l) baris, $(echo "$INPUT" | wc -w) kata)"
  else
    bad "File tidak ditemukan: $INPUT_FILE"
    exit 1
  fi
elif [ ! -t 0 ]; then
  INPUT=$(cat)
  info "Input dari stdin ($(echo "$INPUT" | wc -l) baris, $(echo "$INPUT" | wc -w) kata)"
else
  bad "Tidak ada input. Kirim via stdin atau berikan path file sebagai \$1"
  echo ""
  p "Contoh:" 214
  p "  cat plan.md | bash skills/critique/run.sh" 245
  p "  bash skills/critique/run.sh hasil_kerja.md" 245
  echo ""
  exit 1
fi

if [ -z "$INPUT" ]; then
  bad "Input kosong"
  exit 1
fi

echo ""
p "▸ FASE 0: KUMPUL KLAIM YANG AKAN DISERANG" 45
echo ""

# Ekstrak klaim dari input
KLAIM_LINES=$(echo "$INPUT" | grep -niE '(KLAIM|SELESAI|PASS|CLEAN|VALID|AMAN|BERHASIL|lulus|sukses|completed|working|done)' | head -20)
KLAIM_COUNT=$(echo "$KLAIM_LINES" | grep -c . 2>/dev/null || echo 0)

if [ -n "$KLAIM_LINES" ]; then
  info "$KLAIM_COUNT klaim/pernyataan terdeteksi:"
  echo "$KLAIM_LINES" | head -10 | while IFS= read -r line; do
    p "    $line" 245
  done
else
  warn "Tidak ada klaim eksplisit terdeteksi — critique dijalankan pada konten penuh"
fi

# Deteksi klaim bukti
HAS_BUKTI=$(echo "$INPUT" | grep -ciE '(BUKTI|exit code|test|\.sh|\.py|\.ts|\.js|[0-9]+\/[0-9]+)' || echo 0)
TOTAL_LINES=$(echo "$INPUT" | wc -l)

echo ""

# ══════════════════════════════════════════════════════════════════
# TEMBAKAN 1: SPESIFIKASI
# ══════════════════════════════════════════════════════════════════
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
p "  TEMBAKAN 1 / 5 — SPESIFIKASI" 45
p "  Apakah spesifikasi jelas, lengkap, tidak ambigu?" 111
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
echo ""

VETO_1=0

# Cek apakah ada definisi scope
HAS_SCOPE=$(echo "$INPUT" | grep -ciE '(scope|tujuan|goal|requirement|spec|kriteria|definisi)' || echo 0)
if [ "$HAS_SCOPE" -eq 0 ]; then
  sev_high "Tidak ada definisi scope/tujuan eksplisit dalam dokumen"
  VETO_1=$((VETO_1 + 1))
else
  ok "Scope/tujuan terdeteksi"
fi

# Cek apakah ada acceptance criteria
HAS_AC=$(echo "$INPUT" | grep -ciE '(kriteria|acceptance|done when|selesai bila|gerbang|gate)' || echo 0)
if [ "$HAS_AC" -eq 0 ]; then
  sev_medium "Tidak ada kriteria selesai (acceptance criteria) yang terukur"
  VETO_1=$((VETO_1 + 1))
else
  ok "Kriteria selesai terdeteksi"
fi

# Cek kata ambigu
AMBIG=$(echo "$INPUT" | grep -niE '\b(mungkin|kayaknya|sepertinya|kelihatannya|probably|maybe|might|could be|should work|seharusnya jalan)\b' | head -5)
if [ -n "$AMBIG" ]; then
  sev_high "Ditemukan kata ambigu/tidak pasti — klaim tidak boleh pake kata ini:"
  echo "$AMBIG" | while IFS= read -r line; do warn "    $line"; done
  VETO_1=$((VETO_1 + 1))
else
  ok "Tidak ada kata ambigu terdeteksi"
fi

TOTAL_VETO=$((TOTAL_VETO + VETO_1))
echo ""
if [ "$VETO_1" -gt 0 ]; then
  bad "TEMBAKAN 1 RESULT: $VETO_1 temuan SPESIFIKASI"
else
  ok "TEMBAKAN 1 RESULT: BERSIH"
fi

# ══════════════════════════════════════════════════════════════════
# TEMBAKAN 2: LOGIKA
# ══════════════════════════════════════════════════════════════════
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
p "  TEMBAKAN 2 / 5 — LOGIKA" 45
p "  Apakah alur logika konsisten, tanpa asumsi tersembunyi?" 111
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
echo ""

VETO_2=0

# Cek kontradiksi (baris berisi "tidak" berdekatan dengan klaim positif)
CONTRADICT=$(echo "$INPUT" | grep -niE '(tidak (bisa|berjalan|jalan|valid)|gagal|fail|error)' | head -5)
POSITIVE=$(echo "$INPUT" | grep -niE '(berhasil|sukses|clean|pass|valid|selesai)' | head -5)
if [ -n "$CONTRADICT" ] && [ -n "$POSITIVE" ]; then
  sev_medium "Ada campuran klaim gagal dan berhasil — periksa konsistensi:"
  echo "$CONTRADICT" | head -3 | while IFS= read -r line; do bad "    GAGAL: $line"; done
  echo "$POSITIVE"   | head -3 | while IFS= read -r line; do ok  "    PASS : $line"; done
  VETO_2=$((VETO_2 + 1))
fi

# Cek apakah ada langkah yang bergantung tapi tidak berurutan
HAS_DEPEND=$(echo "$INPUT" | grep -ciE '(sebelum|setelah|dahulu|terlebih|prerequisite|depends|bergantung)' || echo 0)
if [ "$HAS_DEPEND" -eq 0 ] && [ "$TOTAL_LINES" -gt 20 ]; then
  sev_low "Tidak ada urutan dependensi eksplisit di dokumen panjang ($TOTAL_LINES baris)"
  VETO_2=$((VETO_2 + 1))
else
  [ "$HAS_DEPEND" -gt 0 ] && ok "Urutan dependensi terdeteksi"
fi

# Cek asumsi tersembunyi
ASSUME=$(echo "$INPUT" | grep -niE '(diasumsikan|asumsi|assume|assumed|sudah ada|already exists|will be|akan tersedia)' | head -5)
if [ -n "$ASSUME" ]; then
  sev_medium "Asumsi tersembunyi ditemukan — wajib diverifikasi:"
  echo "$ASSUME" | while IFS= read -r line; do warn "    $line"; done
  VETO_2=$((VETO_2 + 1))
fi

TOTAL_VETO=$((TOTAL_VETO + VETO_2))
echo ""
if [ "$VETO_2" -gt 0 ]; then
  bad "TEMBAKAN 2 RESULT: $VETO_2 temuan LOGIKA"
else
  ok "TEMBAKAN 2 RESULT: BERSIH"
fi

# ══════════════════════════════════════════════════════════════════
# TEMBAKAN 3: BUKTI
# ══════════════════════════════════════════════════════════════════
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
p "  TEMBAKAN 3 / 5 — BUKTI" 45
p "  Apakah setiap klaim punya bukti fisik (exit code / file:baris)?" 111
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
echo ""

VETO_3=0

# Cek rasio klaim vs bukti
if [ "$KLAIM_COUNT" -gt 0 ] && [ "$HAS_BUKTI" -eq 0 ]; then
  sev_critical "$KLAIM_COUNT klaim ditemukan tapi TIDAK ADA bukti fisik — HUKUM 11 dilanggar"
  VETO_3=$((VETO_3 + 1))
elif [ "$HAS_BUKTI" -eq 0 ]; then
  sev_medium "Tidak ada referensi bukti fisik (exit code, file:baris, output test)"
  VETO_3=$((VETO_3 + 1))
else
  ok "Referensi bukti fisik ditemukan ($HAS_BUKTI)"
fi

# Cek apakah ada test pass/fail dengan angka
HAS_TEST_NUM=$(echo "$INPUT" | grep -cE '[0-9]+[[:space:]]*/[[:space:]]*[0-9]+[[:space:]]*(pass|PASS|lulus)' || echo 0)
if [ "$HAS_TEST_NUM" -eq 0 ]; then
  sev_medium "Tidak ada angka test N/N PASS yang terukur"
  VETO_3=$((VETO_3 + 1))
else
  ok "Angka test terukur ditemukan: $HAS_TEST_NUM referensi"
fi

# Cek SELAIN (apa yang tidak dibuktikan)
HAS_SELAIN=$(echo "$INPUT" | grep -ciE '(SELAIN|tidak dibuktikan|not tested|not verified|belum diuji)' || echo 0)
if [ "$HAS_SELAIN" -eq 0 ]; then
  sev_low "Tidak ada bagian SELAIN — apa yang tidak dibuktikan tidak dinyatakan (HUKUM 11)"
  VETO_3=$((VETO_3 + 1))
else
  ok "Bagian SELAIN/tidak-dibuktikan ditemukan"
fi

TOTAL_VETO=$((TOTAL_VETO + VETO_3))
echo ""
if [ "$VETO_3" -gt 0 ]; then
  bad "TEMBAKAN 3 RESULT: $VETO_3 temuan BUKTI"
else
  ok "TEMBAKAN 3 RESULT: BERSIH"
fi

# ══════════════════════════════════════════════════════════════════
# TEMBAKAN 4: SKENARIO TAK-TERUJI
# ══════════════════════════════════════════════════════════════════
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
p "  TEMBAKAN 4 / 5 — SKENARIO TAK-TERUJI" 45
p "  Minimal 3 skenario rusak yang belum dites + prediksi akibatnya" 111
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
echo ""

VETO_4=0

# Cek apakah edge case dibahas
HAS_EDGE=$(echo "$INPUT" | grep -ciE '(edge case|corner case|batas|boundary|kosong|empty|null|nil|overflow|timeout|race condition|concurrent)' || echo 0)
if [ "$HAS_EDGE" -eq 0 ]; then
  sev_high "Tidak ada edge case / skenario rusak yang dibahas"
  echo ""
  warn "Skenario yang WAJIB dites tapi belum ada buktinya:"
  sev_high "  SKENARIO-1: Input kosong/null — akibat: crash atau silent fail?"
  sev_high "  SKENARIO-2: Network timeout / service tidak tersedia — akibat: hang atau error proper?"
  sev_high "  SKENARIO-3: Concurrent request / race condition — akibat: data korup atau deadlock?"
  sev_medium "  SKENARIO-4: Input terlalu besar / overflow — akibat: memory error atau truncate?"
  sev_medium "  SKENARIO-5: Permission denied / file tidak ada — akibat: panic atau graceful error?"
  VETO_4=$((VETO_4 + 1))
else
  ok "Edge case / skenario rusak dibahas ($HAS_EDGE referensi)"
  # Tetap saran 3 skenario spesifik
  warn "Verifikasi skenario ini punya test aktual:"
  sev_medium "  SKENARIO-1: Input kosong/null ditest? Bukti: ?"
  sev_medium "  SKENARIO-2: Network failure ditest? Bukti: ?"
  sev_medium "  SKENARIO-3: Concurrent access ditest? Bukti: ?"
fi

# Cek rollback / recovery
HAS_ROLLBACK=$(echo "$INPUT" | grep -ciE '(rollback|revert|recovery|undo|pulih|kembali|restore)' || echo 0)
if [ "$HAS_ROLLBACK" -eq 0 ]; then
  sev_medium "Tidak ada rencana rollback/recovery bila deploy gagal"
  VETO_4=$((VETO_4 + 1))
else
  ok "Rencana rollback/recovery ditemukan"
fi

TOTAL_VETO=$((TOTAL_VETO + VETO_4))
echo ""
if [ "$VETO_4" -gt 0 ]; then
  bad "TEMBAKAN 4 RESULT: $VETO_4 temuan SKENARIO"
else
  ok "TEMBAKAN 4 RESULT: BERSIH"
fi

# ══════════════════════════════════════════════════════════════════
# TEMBAKAN 5: GAP
# ══════════════════════════════════════════════════════════════════
echo ""
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
p "  TEMBAKAN 5 / 5 — GAP" 45
p "  Apa yang hilang, belum dibahas, atau sengaja dilewati?" 111
p "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 45
echo ""

VETO_5=0

# Cek security
HAS_SEC=$(echo "$INPUT" | grep -ciE '(security|keamanan|auth|autentikasi|injection|sanitize|escape|xss|csrf|sql injection)' || echo 0)
if [ "$HAS_SEC" -eq 0 ]; then
  sev_high "GAP: Tidak ada pembahasan keamanan (auth/injection/sanitization)"
  VETO_5=$((VETO_5 + 1))
else
  ok "Aspek keamanan dibahas"
fi

# Cek monitoring / observability
HAS_MON=$(echo "$INPUT" | grep -ciE '(monitor|log|logging|alert|observ|metrics|trace|error tracking)' || echo 0)
if [ "$HAS_MON" -eq 0 ]; then
  sev_medium "GAP: Tidak ada monitoring/logging/error tracking yang dibahas"
  VETO_5=$((VETO_5 + 1))
else
  ok "Monitoring/logging dibahas"
fi

# Cek dokumentasi
HAS_DOC=$(echo "$INPUT" | grep -ciE '(README|dokumentasi|docs|comment|komentar|changelog)' || echo 0)
if [ "$HAS_DOC" -eq 0 ]; then
  sev_low "GAP: Tidak ada rencana dokumentasi"
  VETO_5=$((VETO_5 + 1))
else
  ok "Dokumentasi dibahas"
fi

# Cek performa
HAS_PERF=$(echo "$INPUT" | grep -ciE '(performa|performance|latency|latensi|throughput|benchmark|load test|stress)' || echo 0)
if [ "$HAS_PERF" -eq 0 ] && [ "$TOTAL_LINES" -gt 30 ]; then
  sev_low "GAP: Performa/benchmark tidak dibahas di dokumen panjang ($TOTAL_LINES baris)"
  VETO_5=$((VETO_5 + 1))
else
  [ "$HAS_PERF" -gt 0 ] && ok "Performa/benchmark dibahas"
fi

TOTAL_VETO=$((TOTAL_VETO + VETO_5))
echo ""
if [ "$VETO_5" -gt 0 ]; then
  bad "TEMBAKAN 5 RESULT: $VETO_5 temuan GAP"
else
  ok "TEMBAKAN 5 RESULT: BERSIH"
fi

# ── Ringkasan ─────────────────────────────────────────────────────
echo ""
sep
p "                RINGKASAN CRITIQUE                   " 33
sep
echo ""
p "  SPESIFIKASI : $VETO_1 temuan" 111
p "  LOGIKA      : $VETO_2 temuan" 111
p "  BUKTI       : $VETO_3 temuan" 111
p "  SKENARIO    : $VETO_4 temuan" 111
p "  GAP         : $VETO_5 temuan" 111
echo ""
p "  TOTAL TEMUAN: $TOTAL_VETO" 214
echo ""

if [ "$TOTAL_VETO" -eq 0 ]; then
  ok "VERDICT: CLEAN ✓"
  ok "Tidak ada temuan signifikan — laporan boleh dikirim"
  echo ""
  sep
  p "  CRITIQUE_RESULT: CLEAN — semua 5 tembakan bersih ✓          " 82
  sep
  echo ""
  exit 0
else
  bad "VERDICT: VETO($TOTAL_VETO) ✗"
  bad "→ $TOTAL_VETO temuan harus diselesaikan sebelum lapor SELESAI"
  bad "→ Jalankan: fixer → ulang → critique lagi sampai CLEAN"
  echo ""
  sep
  p "  CRITIQUE_RESULT: VETO($TOTAL_VETO) — perbaiki dulu ✗       " 196
  sep
  echo ""
  exit 1
fi
