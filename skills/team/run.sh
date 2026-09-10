#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  TEAM — pelacak unit kerja paralel.
#  Args: $1=action (split/status/merge/fail)
#        $2=unit_id (U1/U2/...)  [untuk status/merge/fail]
#        $3=files_or_desc        [untuk split: daftar file unit]
#        $4=description          [untuk split: deskripsi unit]
#  Membaca/menulis .opencode/team-board.md
#  Verifikasi: tidak ada 2 unit menyentuh file yang sama.
#  Exit 0 selalu.
# ═════════════════════════════════════════════════════════════════
set -u

p()   { printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok()  { p "  ✔ $1" 82; }
bad() { p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }
sep() { p "═══════════════════════════════════════════" 33; }

ACTION="${1:-status}"
UID_ARG="${2:-}"
ARG3="${3:-}"
ARG4="${4:-}"

BOARD_DIR=".opencode"
BOARD_FILE="$BOARD_DIR/team-board.md"

ensure_dir() { mkdir -p "$BOARD_DIR"; }

# ── Baca papan ───────────────────────────────────────────────────
read_board() {
  [ -f "$BOARD_FILE" ] && cat "$BOARD_FILE" || echo ""
}

# ── Tampilkan papan dengan warna ─────────────────────────────────
display_board() {
  echo ""
  sep
  p "              🤝 TEAM BOARD — UNIT PARALEL           " 33
  sep
  echo ""

  if [ ! -f "$BOARD_FILE" ] || [ ! -s "$BOARD_FILE" ]; then
    warn "Papan kosong — gunakan 'split' untuk mendaftarkan unit kerja"
    echo ""
    p "  Contoh:" 111
    p "    bash skills/team/run.sh split U1 'src/auth.ts,src/auth.test.ts' 'module auth'" 245
    p "    bash skills/team/run.sh split U2 'src/utils.ts,src/utils.test.ts' 'module utils'" 245
    p "    bash skills/team/run.sh status" 245
    p "    bash skills/team/run.sh merge U1 'test 4/4 PASS'" 245
    p "    bash skills/team/run.sh fail U2 'compile error baris 42'" 245
    echo ""
    return
  fi

  # Baca dan tampilkan per baris unit
  TOTAL=0; SELESAI=0; JALAN=0; ANTRE=0; GAGAL=0

  # Header kolom
  p "  $(printf '%-6s %-10s %-30s %s' 'UNIT' 'STATUS' 'DESKRIPSI' 'FILE')" 33
  p "  ─────────────────────────────────────────────────────────────" 240

  while IFS='|' read -r uid status desc files; do
    # Lewati komentar/header
    echo "$uid" | grep -qE '^\s*#|^\s*$|^UNIT' && continue

    uid=$(echo "$uid" | tr -d ' ')
    status=$(echo "$status" | tr -d ' ')
    desc=$(echo "$desc" | sed 's/^ *//; s/ *$//')
    files=$(echo "$files" | sed 's/^ *//; s/ *$//')

    TOTAL=$((TOTAL + 1))

    case "$status" in
      *SELESAI*)
        SELESAI=$((SELESAI + 1))
        printf '\033[38;5;82m  %-6s %-10s %-30s %s\033[0m\n' "$uid" "[SELESAI]" "${desc:0:30}" "${files:0:40}"
        ;;
      *JALAN*)
        JALAN=$((JALAN + 1))
        printf '\033[38;5;214m  %-6s %-10s %-30s %s\033[0m\n' "$uid" "[JALAN  ]" "${desc:0:30}" "${files:0:40}"
        ;;
      *GAGAL*)
        GAGAL=$((GAGAL + 1))
        printf '\033[38;5;196m  %-6s %-10s %-30s %s\033[0m\n' "$uid" "[GAGAL  ]" "${desc:0:30}" "${files:0:40}"
        ;;
      *)
        ANTRE=$((ANTRE + 1))
        printf '\033[38;5;111m  %-6s %-10s %-30s %s\033[0m\n' "$uid" "[ANTRE  ]" "${desc:0:30}" "${files:0:40}"
        ;;
    esac
  done < "$BOARD_FILE"

  echo ""
  p "  ─────────────────────────────────────────────────────────────" 240
  ok "SELESAI : $SELESAI"
  warn "JALAN   : $JALAN"
  info "ANTRE   : $ANTRE"
  [ "$GAGAL" -gt 0 ] && bad "GAGAL   : $GAGAL" || true
  p "  TOTAL   : $TOTAL" 245
  echo ""

  # Gerbang
  if [ "$GAGAL" -gt 0 ]; then
    bad "Gerbang: ada $GAGAL unit [GAGAL] — paralel BERHENTI sampai unit gagal diperbaiki"
    bad "Jalankan fixer sekarang, lanjut paralel setelah aman"
  fi
  if [ "$SELESAI" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
    ok "Semua $TOTAL unit SELESAI — siap untuk MERGE + verifikasi penuh"
    warn "INGAT: hasil paralel wajib verifikasi ulang: test-full + audit-full"
  fi
}

# ── Cek konflik file (tidak ada 2 unit menyentuh file yang sama) ──
check_file_conflicts() {
  local new_uid="$1"
  local new_files="$2"  # dipisah koma

  if [ ! -f "$BOARD_FILE" ]; then return 0; fi

  local conflict_found=0

  # Iterasi setiap file baru
  IFS=',' read -ra NEW_FILE_ARR <<< "$new_files"
  for new_file in "${NEW_FILE_ARR[@]}"; do
    new_file=$(echo "$new_file" | tr -d ' ')
    [ -z "$new_file" ] && continue

    # Cek di semua unit yang sudah ada
    while IFS='|' read -r uid status desc files; do
      echo "$uid" | grep -qE '^\s*#|^\s*$|^UNIT' && continue
      uid=$(echo "$uid" | tr -d ' ')
      [ "$uid" = "$new_uid" ] && continue  # lewati unit sendiri

      # Cek apakah file ini ada di unit lain
      if echo "$files" | grep -qE "(^|,)[[:space:]]*${new_file}[[:space:]]*(,|$)"; then
        bad "KONFLIK FILE: $new_file sudah dipakai oleh $uid"
        bad "→ Dua unit tidak boleh menyentuh file yang sama (HUKUM TEAM)"
        bad "→ Pecah ulang: pindahkan $new_file ke satu unit saja"
        conflict_found=1
      fi
    done < "$BOARD_FILE"
  done

  return $conflict_found
}

# ── Hitung ID unit berikutnya ─────────────────────────────────────
next_unit_id() {
  if [ ! -f "$BOARD_FILE" ] || [ ! -s "$BOARD_FILE" ]; then
    echo "U1"
    return
  fi
  MAX_NUM=0
  while IFS='|' read -r uid _; do
    echo "$uid" | grep -qE '^\s*#|^\s*$|^UNIT' && continue
    uid=$(echo "$uid" | tr -d ' ')
    NUM=$(echo "$uid" | grep -oE '[0-9]+' | head -1)
    [ -n "$NUM" ] && [ "$NUM" -gt "$MAX_NUM" ] && MAX_NUM="$NUM"
  done < "$BOARD_FILE"
  echo "U$((MAX_NUM + 1))"
}

# ── Update status unit ────────────────────────────────────────────
update_unit_status() {
  local uid="$1"
  local new_status="$2"
  local extra="${3:-}"

  if [ ! -f "$BOARD_FILE" ]; then
    bad "Papan tidak ditemukan — gunakan 'split' dulu"
    return 1
  fi

  if ! grep -qE "^${uid}[[:space:]]*\|" "$BOARD_FILE"; then
    bad "Unit $uid tidak ditemukan di papan"
    return 1
  fi

  TMP=$(mktemp)
  while IFS='|' read -r uid_col status_col desc_col files_col; do
    uid_trimmed=$(echo "$uid_col" | tr -d ' ')
    if [ "$uid_trimmed" = "$uid" ]; then
      # Perbarui status dan/atau deskripsi
      NEW_DESC="${extra:-$desc_col}"
      echo "${uid_col}|${new_status}|${NEW_DESC}|${files_col}"
    else
      echo "${uid_col}|${status_col}|${desc_col}|${files_col}"
    fi
  done < "$BOARD_FILE" > "$TMP"
  mv "$TMP" "$BOARD_FILE"
}

# ════════════════════════════════════════════════════════════════
# MAIN: proses action
# ════════════════════════════════════════════════════════════════
echo ""
sep
p "              🤝 TEAM — UNIT KERJA PARALEL           " 33
sep
echo ""

ACTION_LOWER=$(echo "$ACTION" | tr '[:upper:]' '[:lower:]')

case "$ACTION_LOWER" in

  # ── split: daftarkan unit kerja baru ────────────────────────────
  split)
    # Format: split [U1] [files] [description]
    # Jika UID_ARG tidak ada atau bukan format U[n], generate otomatis
    if [ -z "$UID_ARG" ] || ! echo "$UID_ARG" | grep -qE '^U[0-9]+$'; then
      # UID_ARG mungkin adalah files atau desc
      FILES_ARG="$UID_ARG"
      DESC_ARG="$ARG3"
      NEW_UID=$(next_unit_id)
    else
      NEW_UID="$UID_ARG"
      FILES_ARG="$ARG3"
      DESC_ARG="$ARG4"
    fi

    FILES_TEXT="${FILES_ARG:-<belum ditentukan>}"
    DESC_TEXT="${DESC_ARG:-unit $NEW_UID}"

    info "Mendaftarkan unit: $NEW_UID"
    info "Deskripsi: $DESC_TEXT"
    info "File: $FILES_TEXT"
    echo ""

    # Cek konflik file
    if [ "$FILES_TEXT" != "<belum ditentukan>" ]; then
      if ! check_file_conflicts "$NEW_UID" "$FILES_TEXT"; then
        echo ""
        bad "Unit TIDAK didaftarkan karena ada konflik file"
        bad "Pecah ulang unit agar setiap file hanya dipakai satu unit"
        exit 0
      fi
      ok "Tidak ada konflik file"
    fi

    ensure_dir

    # Cek duplikat
    if [ -f "$BOARD_FILE" ] && grep -qE "^${NEW_UID}[[:space:]]*\|" "$BOARD_FILE"; then
      warn "Unit $NEW_UID sudah ada — gunakan status/merge/fail untuk mengubahnya"
      display_board
      exit 0
    fi

    echo "${NEW_UID} | [ANTRE  ] | ${DESC_TEXT} | ${FILES_TEXT}" >> "$BOARD_FILE"
    ok "Unit ditambahkan: $NEW_UID [ANTRE] — $DESC_TEXT"
    echo ""
    info "Papan terkini:"
    display_board
    ;;

  # ── status: tampilkan papan ─────────────────────────────────────
  status|"")
    display_board
    ;;

  # ── jalan: mulai unit (ANTRE → JALAN) ──────────────────────────
  jalan|start)
    if [ -z "$UID_ARG" ]; then
      bad "Butuh unit ID. Contoh: bash skills/team/run.sh jalan U1"
      exit 0
    fi

    # Cek gerbang: apakah ada unit GAGAL?
    if [ -f "$BOARD_FILE" ] && grep -q '\[GAGAL  \]' "$BOARD_FILE"; then
      bad "Ada unit [GAGAL] — DILARANG memulai unit baru sampai unit gagal diperbaiki"
      display_board
      exit 0
    fi

    update_unit_status "$UID_ARG" " [JALAN  ] " "$ARG3"
    ok "Unit $UID_ARG dimulai: ANTRE → JALAN"
    echo ""
    display_board
    ;;

  # ── merge: unit selesai, tandai SELESAI ─────────────────────────
  merge)
    if [ -z "$UID_ARG" ]; then
      bad "Butuh unit ID. Contoh: bash skills/team/run.sh merge U1 'test 4/4 PASS'"
      exit 0
    fi

    PROOF="${ARG3:-bukti belum dicatat}"
    update_unit_status "$UID_ARG" " [SELESAI] " "$PROOF" && ok "Unit $UID_ARG: SELESAI — $PROOF"
    echo ""

    # Cek apakah semua unit selesai → ingatkan verifikasi
    if [ -f "$BOARD_FILE" ]; then
      STILL_JALAN=$(grep -c '\[JALAN  \]' "$BOARD_FILE" 2>/dev/null || echo 0)
      STILL_ANTRE=$(grep -c '\[ANTRE  \]' "$BOARD_FILE" 2>/dev/null || echo 0)
      DONE_COUNT=$(grep -c '\[SELESAI\]' "$BOARD_FILE" 2>/dev/null || echo 0)

      if [ "$STILL_JALAN" -eq 0 ] && [ "$STILL_ANTRE" -eq 0 ] && [ "$DONE_COUNT" -gt 0 ]; then
        echo ""
        ok "Semua unit SELESAI!"
        warn "WAJIB: Jalankan verifikasi penuh sebelum lapor SELESAI:"
        warn "  → bash skills/test-full/run.sh (bila ada)"
        warn "  → bash skills/audit-full/run.sh"
        warn "Hasil paralel tanpa verifikasi ulang = DILARANG dilapor SELESAI"
      fi
    fi
    echo ""
    display_board
    ;;

  # ── fail: tandai unit GAGAL ─────────────────────────────────────
  fail)
    if [ -z "$UID_ARG" ]; then
      bad "Butuh unit ID. Contoh: bash skills/team/run.sh fail U1 'compile error baris 42'"
      exit 0
    fi

    REASON="${ARG3:-alasan tidak dicatat}"
    update_unit_status "$UID_ARG" " [GAGAL  ] " "$REASON" && bad "Unit $UID_ARG: GAGAL — $REASON"
    echo ""
    bad "Gerbang AKTIF: unit lain BERHENTI sampai $UID_ARG diperbaiki"
    bad "→ Jalankan fixer sekarang"
    bad "→ Gunakan 'jalan' untuk restart unit setelah diperbaiki"
    echo ""
    display_board
    ;;

  # ── reset: kosongkan papan ──────────────────────────────────────
  reset)
    if [ -f "$BOARD_FILE" ]; then
      rm -f "$BOARD_FILE"
      ok "Papan team-board.md dikosongkan"
    else
      info "Papan sudah kosong"
    fi
    ;;

  *)
    bad "Action tidak dikenal: $ACTION"
    warn "Gunakan: split / status / jalan / merge / fail / reset"
    echo ""
    p "Contoh:" 111
    p "  bash skills/team/run.sh split U1 'src/auth.ts,src/auth.test.ts' 'module auth'" 245
    p "  bash skills/team/run.sh split U2 'src/utils.ts' 'module utils'" 245
    p "  bash skills/team/run.sh jalan U1" 245
    p "  bash skills/team/run.sh status" 245
    p "  bash skills/team/run.sh merge U1 'test 4/4 PASS'" 245
    p "  bash skills/team/run.sh fail U2 'error: cannot read file'" 245
    ;;
esac

echo ""
exit 0
