#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  HANDOFF-RUN — kemas konteks sesi: SELESAI/SETENGAH/SISA/
#  VALIDASI/JEBAKAN. Baca memory files + git log -10. Simpan ke
#  output file.
#  Jalankan: bash skills/handoff/run.sh [output_file]
#  Exit 0.
# ═════════════════════════════════════════════════════════════════
set -u

OUTPUT_FILE="${1:-.opencode/handoff.md}"

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
MEMORY_DIR=".opencode/memory"

echo ""
p "═══════════════════════════════════════════════" 213
p "     📋 HANDOFF — PAKET SERAH TERIMA SESI      " 213
p "═══════════════════════════════════════════════" 213
echo ""

# ── Baca memory files ────────────────────────────────────────────
section "BACA MEMORY FILES"

MEMORY_CONTENT=""
DECISIONS_CONTENT=""
LESSONS_CONTENT=""
TODO_CONTENT=""

if [ -d "$MEMORY_DIR" ]; then
  ok "Memory dir ditemukan: $MEMORY_DIR"

  for f in "$MEMORY_DIR"/*.md "$MEMORY_DIR"/*.txt; do
    [ -f "$f" ] || continue
    FNAME=$(basename "$f")
    info "Membaca: $FNAME"
    FILE_CONTENT=$(cat "$f" 2>/dev/null | head -50)

    case "$FNAME" in
      decisions*) DECISIONS_CONTENT="$FILE_CONTENT" ;;
      lessons*)   LESSONS_CONTENT="$FILE_CONTENT" ;;
      todo*|task*) TODO_CONTENT="$FILE_CONTENT" ;;
      *)           MEMORY_CONTENT="${MEMORY_CONTENT}
### $FNAME
$FILE_CONTENT
" ;;
    esac
  done
else
  warn "Memory dir tidak ada: $MEMORY_DIR"
  info "Akan dibuat dengan konten default"
fi

# ── Git log ──────────────────────────────────────────────────────
section "GIT CONTEXT"

GIT_LOG=""
GIT_STATUS=""
GIT_BRANCH=""

if git rev-parse --git-dir >/dev/null 2>&1; then
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo 'detached')
  GIT_LOG=$(git log --oneline -10 2>/dev/null || echo '(no commits)')
  GIT_STATUS=$(git status --short 2>/dev/null || echo '(no changes)')

  ok "Branch: $GIT_BRANCH"
  info "10 commit terakhir:"
  echo "$GIT_LOG" | while IFS= read -r line; do echo -e "${CYAN}    $line${NC}"; done

  UNCOMMITTED=$(echo "$GIT_STATUS" | grep -v '^$' | wc -l | tr -d ' ')
  if [ "$UNCOMMITTED" -gt 0 ]; then
    warn "Ada $UNCOMMITTED file tidak di-commit:"
    echo "$GIT_STATUS" | while IFS= read -r line; do echo -e "${YELLOW}    $line${NC}"; done
  else
    ok "Working tree bersih"
  fi
else
  warn "Bukan git repo"
  GIT_LOG="(bukan git repo)"
  GIT_STATUS="N/A"
  GIT_BRANCH="N/A"
fi

# ── Cek test terakhir ────────────────────────────────────────────
section "STATUS VALIDASI"

TEST_RESULT="Belum diketahui — jalankan test-full"

# Check for common test result indicators
if [ -f .opencode/last-test.log ]; then
  LAST_TEST=$(tail -5 .opencode/last-test.log 2>/dev/null)
  if echo "$LAST_TEST" | grep -qiE 'pass|ok|success'; then
    TEST_RESULT="HIJAU (dari .opencode/last-test.log)"
    ok "Test terakhir: PASS"
  elif echo "$LAST_TEST" | grep -qiE 'fail|error|broken'; then
    TEST_RESULT="MERAH — cek .opencode/last-test.log"
    bad "Test terakhir: FAIL"
  fi
fi

# ── Buat output dir ──────────────────────────────────────────────
section "GENERATE HANDOFF"

OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
if [ "$OUTPUT_DIR" != "." ] && [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR" 2>/dev/null
  ok "Dibuat direktori: $OUTPUT_DIR"
fi

# ── Tulis handoff document ───────────────────────────────────────
cat > "$OUTPUT_FILE" <<HANDOFF
# HANDOFF $DATE $TIME

> Dokumen ini dibuat otomatis oleh \`skills/handoff/run.sh\`
> Edit bagian SELESAI/SETENGAH/SISA sesuai kondisi aktual sesi.

---

## STATUS SESI

\`\`\`
HANDOFF  : $DATE $TIME
BRANCH   : $GIT_BRANCH
\`\`\`

---

## SELESAI

<!-- Isi: hal yang sudah selesai + bukti (test/audit/commit) -->
<!-- Contoh: + implementasi auth login — test 12/12 PASS, commit abc1234 -->

$(if [ -n "$GIT_LOG" ]; then
  echo "Commit terakhir (10):"
  echo '```'
  echo "$GIT_LOG"
  echo '```'
fi)

---

## SETENGAH

<!-- HUKUM: WAJIB KOSONG -->
<!-- Jika ada item di sini, selesaikan atau batalkan sebelum handoff -->
<!-- Handoff dengan SETENGAH terisi = DITOLAK -->

_(tidak ada — HUKUM handoff)_

---

## SISA

<!-- Daftar terukur dengan definisi selesai per item -->
<!-- Format: - [ ] Nama task — definisi selesai: test X PASS / file Y ada -->

$(if [ -n "$TODO_CONTENT" ]; then
  echo "$TODO_CONTENT"
else
  echo "- [ ] _Isi dari memory/todo jika ada_"
fi)

---

## VALIDASI

Command untuk memverifikasi semua masih hijau:

\`\`\`bash
# Test suite
bash tests/self-test.sh 2>/dev/null || make test 2>/dev/null || npm test 2>/dev/null

# Audit
bash skills/scan/run.sh .

# Git status bersih
git status
\`\`\`

**Hasil terakhir**: $TEST_RESULT

---

## JEBAKAN

<!-- 1-3 hal yang akan menjebak penerus -->
<!-- File jangan disentuh, keputusan jangan dibalik, dll -->

1. _[Isi jebakan #1 — file/keputusan yang sensitif]_
2. _[Isi jebakan #2 jika ada]_
3. _[Isi jebakan #3 jika ada]_

---

## KEPUTUSAN SESI INI

$(if [ -n "$DECISIONS_CONTENT" ]; then
  echo "$DECISIONS_CONTENT"
else
  echo "_Lihat .opencode/memory/decisions.md_"
fi)

---

## PELAJARAN

$(if [ -n "$LESSONS_CONTENT" ]; then
  echo "$LESSONS_CONTENT"
else
  echo "_Lihat .opencode/memory/lessons.md_"
fi)

---

## GIT STATUS SAAT HANDOFF

\`\`\`
$GIT_STATUS
\`\`\`

---

## MEMORY LAINNYA

$MEMORY_CONTENT

---

*Dibuat: $DATE $TIME*
*Untuk sesi/agent berikutnya: baca SELESAI+SISA+JEBAKAN dulu sebelum mulai.*
HANDOFF

ok "Handoff disimpan: $OUTPUT_FILE"

# ── Ringkasan ────────────────────────────────────────────────────
echo ""
p "═══════════════════════════════════════════════" 213
p "         HANDOFF SUMMARY                       " 213
p "═══════════════════════════════════════════════" 213
echo ""
ok "Output : $OUTPUT_FILE"
ok "Branch : $GIT_BRANCH"
ok "Tanggal: $DATE $TIME"
warn "WAJIB: Isi bagian SELESAI / SISA / JEBAKAN secara manual"
warn "HUKUM: SETENGAH harus kosong sebelum handoff dikirim"
echo ""
p "HANDOFF: selesai — edit file lalu kirim ke penerus" 82
exit 0
