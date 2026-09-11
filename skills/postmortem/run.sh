#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  POSTMORTEM-RUN — generator postmortem insiden: GARIS WAKTU/
#  DAMPAK/AKAR/MENGAPA LOLOS/AKSI/PELAJARAN. Baca git log errors.
#  Simpan ke .opencode/memory/postmortem-YYYY-MM-DD.md.
#  Jalankan: bash skills/postmortem/run.sh "<title>"
#  Exit 0.
# ═════════════════════════════════════════════════════════════════
set -u

TITLE="${1:-Insiden Tidak Berjudul}"

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
OUTPUT_DIR=".opencode/memory"
OUTPUT_FILE="$OUTPUT_DIR/postmortem-${DATE}.md"

echo ""
p "═══════════════════════════════════════════════" 196
p "   📋 POSTMORTEM — BEDAH INSIDEN               " 196
p "═══════════════════════════════════════════════" 196
echo ""
p "JUDUL  : $TITLE" 214
p "TANGGAL: $DATE $TIME" 214
echo ""

# ── Baca git log untuk context ───────────────────────────────────
section "BACA GIT LOG — ERROR CONTEXT"

GIT_LOG=""
GIT_LOG_ERRORS=""
GIT_RECENT=""

if git rev-parse --git-dir >/dev/null 2>&1; then
  GIT_RECENT=$(git log --oneline -20 2>/dev/null || echo '(no commits)')
  GIT_LOG_ERRORS=$(git log --oneline -50 2>/dev/null \
    | grep -iE '(fix|hotfix|revert|rollback|error|bug|crash|fail|broken|urgent|critical|patch)' \
    | head -10)
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo 'detached')

  ok "Branch: $GIT_BRANCH"

  if [ -n "$GIT_LOG_ERRORS" ]; then
    p "  ── Commit terkait error/fix (heuristik) ──" 45
    echo "$GIT_LOG_ERRORS" | while IFS= read -r line; do echo -e "${YELLOW}    $line${NC}"; done
  else
    info "Tidak ada commit error/fix ditemukan di 50 commit terakhir"
  fi

  GIT_LOG="$GIT_RECENT"
else
  warn "Bukan git repo"
  GIT_LOG="(bukan git repo)"
  GIT_BRANCH="N/A"
fi

# ── Check existing postmortems ───────────────────────────────────
section "POSTMORTEM SEBELUMNYA"

if [ -d "$OUTPUT_DIR" ]; then
  PREV=$(ls -t "$OUTPUT_DIR"/postmortem-*.md 2>/dev/null | head -5)
  if [ -n "$PREV" ]; then
    info "Postmortem sebelumnya:"
    echo "$PREV" | while IFS= read -r f; do echo -e "${CYAN}    $(basename "$f")${NC}"; done
  else
    info "Belum ada postmortem sebelumnya"
  fi
fi

# ── Buat output dir ──────────────────────────────────────────────
section "GENERATE POSTMORTEM"

mkdir -p "$OUTPUT_DIR" 2>/dev/null
ok "Output: $OUTPUT_FILE"

# Handle duplicate filename
if [ -f "$OUTPUT_FILE" ]; then
  SUFFIX=$(date +%H%M)
  OUTPUT_FILE="$OUTPUT_DIR/postmortem-${DATE}-${SUFFIX}.md"
  warn "File sudah ada — menyimpan ke: $OUTPUT_FILE"
fi

# ── Tulis postmortem template ─────────────────────────────────────
cat > "$OUTPUT_FILE" <<POSTMORTEM
## POSTMORTEM: $TITLE — $DATE

> Dibuat otomatis oleh \`skills/postmortem/run.sh\`
> Isi setiap seksi dengan bukti aktual — DILARANG "lebih teliti lain kali"

---

### GARIS WAKTU

| Waktu | Kejadian |
|-------|----------|
| $DATE HH:MM | _Insiden pertama terdeteksi_ |
| $DATE HH:MM | _Root cause diidentifikasi_ |
| $DATE HH:MM | _Fix diimplementasikan_ |
| $DATE HH:MM | _Sistem kembali normal_ |

_Isi waktu aktual dari log/monitoring/git commit timestamps_

---

### DAMPAK

- **Layanan terdampak**: _Sebutkan service/endpoint/fitur_
- **Durasi**: _X menit/jam_
- **User terdampak**: _Berapa user / % traffic_
- **Data**: _Ada data hilang/korup? Berapa record?_
- **Revenue/SLA**: _Dampak bisnis jika ada_

---

### AKAR MASALAH

_Sebab utama — teknis, bukan orang. Jawab: MENGAPA terjadi?_

**Akar**:
\`\`\`
[Isi akar masalah teknis di sini]
\`\`\`

**Kontribusi faktor**:
1. _Faktor teknis #1_
2. _Faktor proses #2_
3. _Faktor lain jika ada_

---

### MENGAPA LOLOS

_Kenapa test/audit/monitoring tidak menangkap sebelum ke produksi?_

- [ ] Test coverage kurang di area ini? → tambah test regression
- [ ] Tidak ada monitoring/alert untuk kondisi ini?
- [ ] Proses review tidak mencakup skenario ini?
- [ ] Staging tidak merepresentasikan produksi?

**Jawaban**: _[WAJIB diisi — kalau skip, gerbang yang sama akan bobol lagi]_

---

### AKSI

| Status | Aksi | PIC | Deadline |
|--------|------|-----|----------|
| [x] | Fix immediate — _deskripsi_ | - | $DATE |
| [ ] | Test regression untuk skenario ini | - | _+1 hari_ |
| [ ] | Pencegahan permanen (gerbang/rule/skill) | - | _+3 hari_ |
| [ ] | Update lessons.md | - | $DATE |
| [ ] | Monitoring/alert untuk mencegah terulang | - | _+1 minggu_ |

**DILARANG**: Aksi "lebih teliti" atau "code review lebih ketat" tanpa mekanisme konkret.

---

### PELAJARAN

_1–2 baris → harus masuk lessons.md_

\`\`\`
Tanggal: $DATE
Pelajaran: [Isi 1 baris pelajaran konkret]
Aksi permanen: [Apa yang ditambahkan/diubah agar tidak terulang]
\`\`\`

---

### LAMPIRAN

#### Git commits terkait:
\`\`\`
$(echo "$GIT_LOG_ERRORS" | head -10)
\`\`\`

#### 20 commit terakhir:
\`\`\`
$(echo "$GIT_RECENT" | head -20)
\`\`\`

#### Branch saat insiden: $GIT_BRANCH

---

### REFERENSI

- Postmortem sebelumnya: lihat \`.opencode/memory/postmortem-*.md\`
- Lessons: \`.opencode/memory/lessons.md\`
- Hotfix: \`bash skills/hotfix/run.sh "<issue>"\`

---

*Tanpa menyalahkan orang. Bedah sistem, bukan pribadi.*
*Dibuat: $DATE $TIME*
POSTMORTEM

ok "Postmortem disimpan: $OUTPUT_FILE"

# ── Tampilkan preview ────────────────────────────────────────────
echo ""
section "PREVIEW"
p "  ── Header postmortem ──" 45
head -20 "$OUTPUT_FILE" | while IFS= read -r line; do echo -e "${CYAN}  $line${NC}"; done
echo -e "${CYAN}  ...${NC}"

# ── Reminder masuk lessons.md ────────────────────────────────────
section "LANGKAH SELANJUTNYA"
echo -e "${YELLOW}  1. Edit: $OUTPUT_FILE${NC}"
echo -e "${YELLOW}  2. Isi GARIS WAKTU dengan waktu aktual${NC}"
echo -e "${YELLOW}  3. Isi AKAR MASALAH dengan bukti teknis${NC}"
echo -e "${YELLOW}  4. WAJIB isi MENGAPA LOLOS${NC}"
echo -e "${YELLOW}  5. Buat AKSI konkret (bukan 'lebih teliti')${NC}"
echo -e "${YELLOW}  6. Copy PELAJARAN → .opencode/memory/lessons.md${NC}"

echo ""
p "═══════════════════════════════════════════════" 213
p "         POSTMORTEM SELESAI                    " 213
p "═══════════════════════════════════════════════" 213
echo ""
ok "File: $OUTPUT_FILE"
warn "WAJIB: isi semua seksi sebelum dianggap selesai"
warn "INGAT: Aksi tanpa perubahan konkret = DILARANG"
echo ""
p "POSTMORTEM: template siap — edit & selesaikan" 82
exit 0
