#!/usr/bin/env bash
set -uo pipefail

CFG="$HOME/.config/opencode"

# Warna + UI modern (box rounded, section, dots ringan)
R='\033[38;5;196m' G='\033[38;5;82m' C='\033[38;5;213m' W='\033[38;5;255m' M='\033[38;5;248m' N='\033[0m'
B='\033[1m' D='\033[38;5;240m' Y='\033[38;5;214m'
ok(){ printf "${G}  ✔ %s${N}\n" "$1"; }
inf(){ printf "${M}  ▸ %s${N}\n" "$1"; }
wrn(){ printf "${Y}  ⚠ %s${N}\n" "$1"; }

# Animasi
ANIM="${ANIM:-1}"
anim_on(){ [ "${ANIM:-1}" -eq 1 ] && [ -t 1 ] && [ "${NO_ANIM:-}" != "1" ] && [ -z "${CI:-}" ]; }

# lebar teks buang escape ansi
plen(){ printf '%s' "$1" | sed -e 's/\\033\[[0-9;]*m//g' -e 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' '; }

# lebar box adaptif layar
W_=60
if [ -n "${COLUMNS:-}" ] && [ "${COLUMNS:-0}" -ge 40 ]; then
  W_=$(( COLUMNS - 6 )); [ "$W_" -gt 60 ] && W_=60
fi

# rounded box
box(){
  local color="$1"; shift
  printf "${color}╭"; printf '─%.0s' $(seq 1 "$W_"); printf "╮${N}\n"
  for line in "$@"; do
    printf "${color}│${N}  "
    printf '%b' "$line"
    local plain pad; plain=$(plen "$line")
    pad=$(( W_ - 3 - plain )); [ "$pad" -lt 0 ] && pad=0
    printf '%*s' "$pad" ''
    printf "${color}│${N}\n"
  done
  printf "${color}╰"; printf '─%.0s' $(seq 1 "$W_"); printf "╯${N}\n"
}

# section bernomor
section(){ printf "  ${C}${B}[%s]${N} ${B}%s${N} ${D}%s${N}\n" "$1" "$2" "$(printf '─%.0s' $(seq 1 40))"; }

# Loading dots — tampilan modern (⋯ animasi TTY / ▸ polos non-TTY)
dots(){
  local msg="$1" i
  if anim_on; then
    for i in 1 2 3; do
      printf "\r  ${C}⋯${N} ${M}%s${N}   " "$msg"
      sleep 0.12
    done
    printf "\r  ${G}✔${N} ${M}%s${N}\n" "$msg"
  else
    printf "  ${D}▸${N} ${M}%s${N}\n" "$msg"
  fi
}

box_awal(){
  local color="$C"; anim_on || color=""
  box "$color" \
    "${B}${C}  ◆ AGENT AI${N}${D}  —  uninstaller${N}" \
    "${M}  lepas agent/skill/command + doktrin — memory TETAP aman${N}"
}

box_selesai(){ # $1 = lepas|batal
  local mode="${1:-lepas}" color="$G" title="  ${G}${B}✔ DILEPAS${N}"
  local sub="install lagi: bash install.sh"
  case "$mode" in
    batal) color="$M"; title="  ${M}${B}◦ DIBATALKAN${N}"; sub="tidak ada yang diubah" ;;
  esac
  anim_on || color=""
  echo
  box "$color" "$title ${M}${sub}${N}"
}

uninstall(){
  clear
  box_awal

  if [ ! -d "$CFG" ]; then
    inf "Tidak ada instalasi"
    box_selesai
    return
  fi

  if [ "${1:-}" != "--yes" ]; then
    nagent=$(ls -1 "$CFG/agent" 2>/dev/null | wc -l | tr -d ' ')
    nskill=$(ls -1d "$CFG/skill"/*/ 2>/dev/null | wc -l | tr -d ' ')
    ncmd=$(ls -1 "$CFG/command"/*.md 2>/dev/null | wc -l | tr -d ' ')
    inf "Akan dilepas: agent $nagent | skill $nskill | command $ncmd + AGENTS.md + VERSION (memory DIPERTAHANKAN)"
    inf "Pratinjau dulu: bash uninstall.sh --check"
    if [ -t 0 ]; then
      local col="$Y"; anim_on || col=""
      box "$col" \
        "  ${Y}${B}⚠ LEPAS INSTALASI${N}${D} — agent $nagent | skill $nskill | command $ncmd${N}" \
        "  ${M}memory/ TETAP aman • config dipulihkan dari backup${N}"
      printf "\n  Lanjutkan lepas? (y/n): "; read -r ans
      case "$ans" in y|Y|yes|YES) ;; *) inf "dibatalkan"; box_selesai batal; return 1;; esac
    else
      inf "dibatalkan — non-interaktif wajib: bash uninstall.sh --yes"
      box_selesai batal; return 1
    fi
  fi

  section "1/2" "MELEPAS"
  dots "agent..."
  rm -rf "$CFG/agent"

  dots "skill..."
  rm -rf "$CFG/skill"

  dots "command..."
  rm -rf "$CFG/command"

  dots "docs..."
  rm -rf "$CFG/docs"

  dots "doctrine..."
  rm -f "$CFG/AGENTS.md" "$CFG/VERSION"

  section "2/2" "MEMULIHKAN"
  local bak=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  [ -n "${bak:-}" ] && mv "$bak" "$CFG/opencode.json" && ok "config dipulihkan"

  echo
  wrn "memory/ DIPERTAHANKAN"

  box_selesai lepas
}

case "${1:-}" in
  --check|-c)
    # PRATINJAU — hitung & tampilkan, TANPA melepas apa pun
    if [ ! -d "$CFG" ]; then
      inf "Tidak ada instalasi"
      exit 0
    fi
    nagent=$(ls -1 "$CFG/agent" 2>/dev/null | wc -l | tr -d ' ')
    nskill=$(ls -1d "$CFG/skill"/*/ 2>/dev/null | wc -l | tr -d ' ')
    ncmd=$(ls -1 "$CFG/command"/*.md 2>/dev/null | wc -l | tr -d ' ')
    ndocs=$(ls -1 "$CFG/docs" 2>/dev/null | wc -l | tr -d ' ')
    bak=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
    inf "PRATINJAU (--check) — tidak ada yang dilepas:"
    inf "  agent: $nagent | skill: $nskill | command: $ncmd | docs: $ndocs"
    inf "  AGENTS.md + VERSION akan dilepas"
    if [ -n "${bak:-}" ]; then
      inf "  opencode.json dipulihkan dari: $(basename "$bak")"
    else
      inf "  opencode.json TIDAK dipulihkan (tidak ada backup)"
    fi
    inf "  memory/ DIPERTAHANKAN"
    exit 0
    ;;
  --help|-h) echo "Usage: bash uninstall.sh [--check] [--yes]";;
  --yes) uninstall --yes;;
  *) uninstall;;
esac
