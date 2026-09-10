#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  MILESTONE — papan status milestone bernomor M1..Mn.
#  Args: $1=action (init/update/show/done)
#        $2=milestone_id (M1/M2/M3/...)
#        $3=description (untuk init/update)
#  Membaca/menulis .opencode/milestone.md
#  Exit 0 selalu.
# ═════════════════════════════════════════════════════════════════
set -u

p()   { printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok()  { p "  ✔ $1" 82; }
bad() { p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }
sep() { p "═══════════════════════════════════════════" 33; }

ACTION="${1:-show}"
MID="${2:-}"
DESC="${3:-}"

BOARD_DIR=".opencode"
BOARD_FILE="$BOARD_DIR/milestone.md"

ensure_dir() {
  mkdir -p "$BOARD_DIR"
}

# ── Baca papan ───────────────────────────────────────────────────
read_board() {
  if [ -f "$BOARD_FILE" ]; then
    cat "$BOARD_FILE"
  else
    echo ""
  fi
}

# ── Tulis papan ──────────────────────────────────────────────────
write_board() {
  ensure_dir
  cat > "$BOARD_FILE"
}

# ── Tampilkan papan dengan warna ─────────────────────────────────
display_board() {
  echo ""
  sep
  p "           📋 MILESTONE BOARD                       " 33
  sep
  echo ""

  if [ ! -f "$BOARD_FILE" ] || [ ! -s "$BOARD_FILE" ]; then
    warn "Papan kosong — gunakan 'init' untuk menambahkan milestone"
    echo ""
    p "  Contoh:" 111
    p "    bash skills/milestone/run.sh init M1 'auth core'" 245
    p "    bash skills/milestone/run.sh init M2 'session + middleware'" 245
    p "    bash skills/milestone/run.sh update M1 'test 5/5 PASS'" 245
    p "    bash skills/milestone/run.sh done M1" 245
    p "    bash skills/milestone/run.sh show" 245
    echo ""
    return
  fi

  # Hitung statistik
  TOTAL=0
  SELESAI=0
  JALAN=0
  ANTRE=0

  while IFS= read -r line; do
    # Lewati baris header/kosong/---
    echo "$line" | grep -qE '^\s*$|^#|^---' && continue

    TOTAL=$((TOTAL + 1))

    if echo "$line" | grep -q '\[SELESAI\]'; then
      SELESAI=$((SELESAI + 1))
      printf '\033[38;5;82m  %s\033[0m\n' "$line"
    elif echo "$line" | grep -q '\[JALAN  \]'; then
      JALAN=$((JALAN + 1))
      printf '\033[38;5;214m  %s\033[0m\n' "$line"
    elif echo "$line" | grep -q '\[ANTRE  \]'; then
      ANTRE=$((ANTRE + 1))
      printf '\033[38;5;111m  %s\033[0m\n' "$line"
    else
      printf '\033[38;5;245m  %s\033[0m\n' "$line"
    fi
  done < "$BOARD_FILE"

  echo ""
  p "  ─────────────────────────────────────────" 240
  ok "SELESAI : $SELESAI"
  warn "JALAN   : $JALAN"
  info "ANTRE   : $ANTRE"
  p "  TOTAL   : $TOTAL" 245
  echo ""

  # Gerbang: cek apakah ada yang JALAN
  if [ "$JALAN" -gt 0 ]; then
    warn "Gerbang: ada $JALAN milestone [JALAN] — milestone berikutnya tunggu yang [JALAN] selesai dulu"
  fi
  if [ "$SELESAI" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
    ok "Semua $TOTAL milestone SELESAI ✓"
  fi
}

# ── Ambil deskripsi milestone dari papan ─────────────────────────
get_milestone_line() {
  local mid="$1"
  if [ -f "$BOARD_FILE" ]; then
    grep -E "^${mid}[[:space:]]" "$BOARD_FILE" | head -1
  fi
}

# ── Update status milestone ──────────────────────────────────────
update_milestone_status() {
  local mid="$1"
  local new_status="$2"
  local extra_info="${3:-}"

  if [ ! -f "$BOARD_FILE" ]; then
    bad "Papan belum diinisialisasi. Gunakan: bash skills/milestone/run.sh init $mid '<deskripsi>'"
    return 1
  fi

  # Cek apakah milestone ada
  if ! grep -qE "^${mid}[[:space:]]" "$BOARD_FILE"; then
    bad "Milestone $mid tidak ditemukan di papan"
    warn "Gunakan 'init' untuk menambahkan: bash skills/milestone/run.sh init $mid '<deskripsi>'"
    return 1
  fi

  # Ambil deskripsi lama
  OLD_LINE=$(grep -E "^${mid}[[:space:]]" "$BOARD_FILE" | head -1)
  # Ekstrak deskripsi (hilangkan ID dan status lama)
  OLD_DESC=$(echo "$OLD_LINE" | sed 's/^[A-Z][0-9]*[[:space:]]*\[.*\][[:space:]]*//')

  # Ganti deskripsi bila ada info baru
  if [ -n "$extra_info" ]; then
    NEW_DESC="$extra_info"
  else
    NEW_DESC="$OLD_DESC"
  fi

  NEW_LINE="${mid} ${new_status} ${NEW_DESC}"

  # Update baris di file
  TMP_FILE=$(mktemp)
  sed "s|^${mid}[[:space:]].*|${NEW_LINE}|" "$BOARD_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$BOARD_FILE"

  ok "Updated: $NEW_LINE"
}

# ════════════════════════════════════════════════════════════════
# MAIN: proses action
# ════════════════════════════════════════════════════════════════
echo ""
sep
p "           📋 MILESTONE — PAPAN STATUS               " 33
sep
echo ""

ACTION_LOWER=$(echo "$ACTION" | tr '[:upper:]' '[:lower:]')

case "$ACTION_LOWER" in

  # ── init: tambahkan milestone baru ─────────────────────────────
  init)
    if [ -z "$MID" ]; then
      bad "Butuh milestone ID. Contoh: bash skills/milestone/run.sh init M1 'deskripsi'"
      exit 0
    fi
    # Validasi format ID
    if ! echo "$MID" | grep -qE '^M[0-9]+$'; then
      bad "Format ID tidak valid: $MID — gunakan M1, M2, M3, ..."
      exit 0
    fi

    ensure_dir

    # Cek duplikat
    if [ -f "$BOARD_FILE" ] && grep -qE "^${MID}[[:space:]]" "$BOARD_FILE"; then
      warn "Milestone $MID sudah ada:"
      get_milestone_line "$MID" | while IFS= read -r line; do warn "  $line"; done
      warn "Gunakan 'update' untuk memperbarui"
      exit 0
    fi

    DESC_TEXT="${DESC:-milestone $MID}"
    NEW_ENTRY="${MID} [ANTRE  ] ${DESC_TEXT}"

    # Cek apakah ada milestone [JALAN] — tambahkan sebagai ANTRE
    if [ -f "$BOARD_FILE" ] && grep -q '\[JALAN  \]' "$BOARD_FILE"; then
      warn "Ada milestone [JALAN] — $MID ditambahkan sebagai [ANTRE]"
    fi

    echo "$NEW_ENTRY" >> "$BOARD_FILE"
    ok "Ditambahkan: $NEW_ENTRY"
    echo ""
    info "Papan terkini:"
    display_board
    ;;

  # ── update: perbarui status/deskripsi milestone ─────────────────
  update)
    if [ -z "$MID" ]; then
      bad "Butuh milestone ID. Contoh: bash skills/milestone/run.sh update M1 'test 5/5 PASS'"
      exit 0
    fi

    # Cek apakah sedang ANTRE — set ke JALAN
    if [ -f "$BOARD_FILE" ]; then
      CURRENT=$(get_milestone_line "$MID")
      if echo "$CURRENT" | grep -q '\[ANTRE  \]'; then
        update_milestone_status "$MID" "[JALAN  ]" "$DESC"
        info "Status diubah: ANTRE → JALAN"
      elif echo "$CURRENT" | grep -q '\[JALAN  \]'; then
        update_milestone_status "$MID" "[JALAN  ]" "$DESC"
        info "Status tetap JALAN, deskripsi diperbarui"
      elif echo "$CURRENT" | grep -q '\[SELESAI\]'; then
        warn "Milestone $MID sudah SELESAI — gunakan 'done' ulang atau buat milestone baru"
      else
        update_milestone_status "$MID" "[JALAN  ]" "$DESC"
      fi
    else
      bad "Papan tidak ditemukan — gunakan 'init' dulu"
    fi
    echo ""
    info "Papan terkini:"
    display_board
    ;;

  # ── done: tandai milestone selesai ─────────────────────────────
  done)
    if [ -z "$MID" ]; then
      bad "Butuh milestone ID. Contoh: bash skills/milestone/run.sh done M1"
      exit 0
    fi

    if [ -f "$BOARD_FILE" ]; then
      CURRENT=$(get_milestone_line "$MID")
      if [ -z "$CURRENT" ]; then
        bad "Milestone $MID tidak ditemukan"
        exit 0
      fi

      PROOF="${DESC:-bukti belum dicatat}"
      update_milestone_status "$MID" "[SELESAI]" "$PROOF"
      ok "Milestone $MID ditandai SELESAI"
      echo ""

      # Cek gerbang: milestone berikutnya boleh mulai?
      NEXT_NUM=$((${MID#M} + 1))
      NEXT_MID="M${NEXT_NUM}"
      if [ -f "$BOARD_FILE" ] && grep -qE "^${NEXT_MID}[[:space:]].*\[ANTRE" "$BOARD_FILE"; then
        ok "Gerbang terbuka: $NEXT_MID boleh mulai (status ANTRE → update ke JALAN)"
        warn "Jalankan: bash skills/milestone/run.sh update $NEXT_MID '<deskripsi>'"
      fi
    else
      bad "Papan tidak ditemukan — gunakan 'init' dulu"
    fi
    echo ""
    info "Papan terkini:"
    display_board
    ;;

  # ── show: tampilkan papan ───────────────────────────────────────
  show|"")
    display_board
    ;;

  # ── reset: hapus papan (konfirmasi diperlukan) ──────────────────
  reset)
    if [ -f "$BOARD_FILE" ]; then
      warn "Papan di-reset (file dihapus): $BOARD_FILE"
      rm -f "$BOARD_FILE"
      ok "Papan dikosongkan"
    else
      info "Papan sudah kosong"
    fi
    ;;

  *)
    bad "Action tidak dikenal: $ACTION"
    warn "Gunakan: init / update / show / done / reset"
    echo ""
    p "Contoh:" 111
    p "  bash skills/milestone/run.sh init M1 'auth core'" 245
    p "  bash skills/milestone/run.sh update M1 'test 3/5'" 245
    p "  bash skills/milestone/run.sh done M1 'test 5/5 PASS, audit CLEAN'" 245
    p "  bash skills/milestone/run.sh show" 245
    ;;
esac

echo ""
exit 0
