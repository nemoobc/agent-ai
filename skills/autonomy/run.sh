#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  AUTONOMY — panduan tingkat kemandirian agent per tugas.
#  Args: $1=level (PENUH/TITIK/JANGAN) [optional]
#        $2=--set  → tulis level ke .opencode/memory/autonomy.txt
#  Exit 0 selalu.
# ═════════════════════════════════════════════════════════════════
set -u

p()   { printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok()  { p "  ✔ $1" 82; }
bad() { p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }
sep() { p "═══════════════════════════════════════════" 33; }

LEVEL="${1:-}"
ACTION="${2:-}"
MEMORY_DIR=".opencode/memory"
MEMORY_FILE="$MEMORY_DIR/autonomy.txt"

echo ""
sep
p "     🤖 AUTONOMY — PANDUAN TINGKAT KEMANDIRIAN     " 33
sep
echo ""

# ── Baca level tersimpan ─────────────────────────────────────────
STORED_LEVEL=""
if [ -f "$MEMORY_FILE" ]; then
  STORED_LEVEL=$(cat "$MEMORY_FILE" 2>/dev/null | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]')
fi

# ── Tampilkan level tersimpan saat ini ──────────────────────────
if [ -n "$STORED_LEVEL" ]; then
  p "▸ LEVEL SAAT INI (tersimpan di $MEMORY_FILE)" 45
  case "$STORED_LEVEL" in
    PENUH)  ok "Saat ini: PENUH — agent berjalan sampai semua gerbang hijau" ;;
    TITIK)  warn "Saat ini: TITIK — agent berhenti di keputusan penting, lapor opsi bernomor" ;;
    JANGAN) bad "Saat ini: JANGAN — agent read-only, tidak mengubah file" ;;
    *)      warn "Saat ini: $STORED_LEVEL (tidak dikenal — gunakan PENUH/TITIK/JANGAN)" ;;
  esac
  echo ""
else
  info "Tidak ada level tersimpan di $MEMORY_FILE"
  info "Default aktif: PENUH"
  echo ""
fi

# ── Panduan semua level ─────────────────────────────────────────
p "▸ PANDUAN TINGKAT KEMANDIRIAN" 45
echo ""

p "  ┌─────────────────────────────────────────────────────────────┐" 240
p "  │  PENUH — Kerja sampai SELESAI + semua gerbang hijau         │" 82
p "  │  • Default. Berhenti HANYA di HUKUM 5 (biaya/keputusan).   │" 82
p "  │  • Tidak perlu konfirmasi untuk langkah teknis biasa.       │" 82
p "  │  • Laporan akhir: SELESAI atau GAGAL (dengan sebab + bukti) │" 82
p "  └─────────────────────────────────────────────────────────────┘" 240
echo ""

p "  ┌─────────────────────────────────────────────────────────────┐" 240
p "  │  TITIK — Kerja sampai batas keputusan kritis, lalu STOP     │" 214
p "  │  • Berhenti di: biaya signifikan, data bisa hilang,         │" 214
p "  │    hukum/keamanan, ambiguitas besar yang tak bisa dicoba.   │" 214
p "  │  • Saat berhenti WAJIB: lapor progres + opsi A/B/C +       │" 214
p "  │    angka (biaya/waktu/risiko) + 1 rekomendasi.             │" 214
p "  │  • Setelah user putuskan: lanjut tanpa tanya ulang.         │" 214
p "  │  • Laporan akhir: TITIK-PUTUS (tunggu keputusan X)         │" 214
p "  └─────────────────────────────────────────────────────────────┘" 240
echo ""

p "  ┌─────────────────────────────────────────────────────────────┐" 240
p "  │  JANGAN — Read-only: analisa, review, riset, plan saja      │" 196
p "  │  • DILARANG: tulis/ubah/hapus file apa pun.                 │" 196
p "  │  • Boleh: baca, hitung, rencanakan, rekomendasikan.         │" 196
p "  │  • Gunakan bila user eksplisit minta ini.                   │" 196
p "  │  • Laporan akhir: ANALISIS (tanpa perubahan)                │" 196
p "  └─────────────────────────────────────────────────────────────┘" 240
echo ""

# ── Cara berhenti yang benar di mode TITIK ───────────────────────
p "▸ FORMAT LAPORAN SAAT TITIK-BERHENTI (mode TITIK)" 45
echo ""
p "  KONTEKS : <progres + bukti selesai>" 111
p "  PILIHAN :" 111
p "    A) <opsi A> — biaya/waktu/risiko: X" 111
p "    B) <opsi B> — biaya/waktu/risiko: Y" 111
p "    C) <opsi C> — biaya/waktu/risiko: Z" 111
p "  REKOMEND: <satu pilihan + alasan 1 kalimat>" 111
p "  TUNGGU  : keputusan user → gas = lanjut tanpa tanya ulang" 111
echo ""

# ── Gerbang ────────────────────────────────────────────────────
p "▸ GERBANG KEMANDIRIAN" 45
echo ""
bad "DILARANG: berhenti tanpa opsi bernomor = bukan titik berhenti, itu menyerah"
bad "DILARANG: berhenti untuk hal yang bisa dicoba sendiri (= pelanggaran HUKUM 1)"
bad "DILARANG: file setengah ubah / test setengah tulis / plan setengah rencana"
ok  "WAJIB   : status akhir laporan = SELESAI / TITIK-PUTUS / GAGAL"
echo ""

# ── Proses perintah set ─────────────────────────────────────────
if [ -n "$LEVEL" ]; then
  LEVEL_UPPER=$(echo "$LEVEL" | tr '[:lower:]' '[:upper:]')
  case "$LEVEL_UPPER" in
    PENUH|TITIK|JANGAN)
      if [ "$ACTION" = "--set" ] || [ "${2:-}" = "--set" ]; then
        mkdir -p "$MEMORY_DIR"
        echo "$LEVEL_UPPER" > "$MEMORY_FILE"
        ok "Level disimpan: $LEVEL_UPPER → $MEMORY_FILE"
        echo ""
      else
        p "▸ LEVEL DIMINTA: $LEVEL_UPPER" 45
        case "$LEVEL_UPPER" in
          PENUH)
            ok "PENUH: Kerja penuh sampai semua gerbang hijau"
            ok "       Konfirmasi hanya di HUKUM 5 (biaya/aksi destruktif)"
            ;;
          TITIK)
            warn "TITIK: Kerja sampai titik keputusan kritis"
            warn "       Lalu STOP — lapor progres + opsi + angka + rekomendasi"
            warn "       Setelah user gas → lanjut tanpa tanya ulang"
            ;;
          JANGAN)
            bad "JANGAN: Read-only — analisa saja, tidak ubah file apa pun"
            ;;
        esac
        echo ""
        info "Untuk menyimpan: bash skills/autonomy/run.sh $LEVEL_UPPER --set"
      fi
      ;;
    *)
      bad "Level tidak dikenal: $LEVEL"
      warn "Gunakan: PENUH / TITIK / JANGAN"
      echo ""
      ;;
  esac
fi

# ── Tips penggunaan ──────────────────────────────────────────────
p "▸ PENGGUNAAN" 45
echo ""
p "  bash skills/autonomy/run.sh              # tampilkan panduan + level saat ini" 245
p "  bash skills/autonomy/run.sh PENUH        # tampilkan detail level PENUH" 245
p "  bash skills/autonomy/run.sh TITIK        # tampilkan detail level TITIK" 245
p "  bash skills/autonomy/run.sh JANGAN       # tampilkan detail level JANGAN" 245
p "  bash skills/autonomy/run.sh PENUH --set  # simpan level PENUH ke memory" 245
p "  bash skills/autonomy/run.sh TITIK --set  # simpan level TITIK ke memory" 245
echo ""
sep
p "  AUTONOMY_RESULT: panduan ditampilkan — level default = PENUH  " 33
sep
echo ""
exit 0
