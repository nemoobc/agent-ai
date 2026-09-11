#!/usr/bin/env bash
set -u

CFG="$HOME/.config/opencode"

# Warna
R='\033[38;5;196m' G='\033[38;5;82m' C='\033[38;5;213m' W='\033[38;5;255m' M='\033[38;5;248m' N='\033[0m'

ok(){ printf "${G}  ✔ %s${N}\n" "$1"; }
inf(){ printf "${M}  ▸ %s${N}\n" "$1"; }

# Loading dots
dots(){
  local msg="$1" d=("." ".." "...")
  for j in {1..3}; do
    printf "\r${M}  %s${N} ${C}%s${N}" "${d[$((j%3))]}" "$msg"
    sleep 0.3
  done
  printf "\r${G}  ✔${N} %s\n" "$msg"
}

# Animasi
ANIM="${ANIM:-1}"
anim_on(){ [ "${ANIM:-1}" -eq 1 ] && [ -t 1 ] && [ "${NO_ANIM:-}" != "1" ]; }

box_awal(){
  if anim_on; then
    printf "${C}  ┌─────────────────────┐${N}\n"
    printf "${W}  │      AGENT AI       │${N}\n"
    printf "${C}  └─────────────────────┘${N}\n"
  else
    printf "  ┌─────────────────────┐\n"
    printf "  │      AGENT AI       │\n"
    printf "  └─────────────────────┘\n"
  fi
}

box_selesai(){
  if anim_on; then
    printf "\n${G}  ┌─────────────────────┐${N}\n"
    printf "${G}  │       SELESAI       │${N}\n"
    printf "${G}  └─────────────────────┘${N}\n"
  else
    printf "\n  ┌─────────────────────┐\n"
    printf "  │       SELESAI       │\n"
    printf "  └─────────────────────┘\n"
  fi
}

uninstall(){
  clear
  box_awal

  if [ ! -d "$CFG" ]; then
    inf "Tidak ada instalasi"
    box_selesai
    return
  fi

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

  local bak=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  [ -n "${bak:-}" ] && mv "$bak" "$CFG/opencode.json" && ok "config dipulihkan"

  echo
  inf "memory/ aman"

  box_selesai
}

case "${1:-}" in
  --help|-h) echo "Usage: bash uninstall.sh";;
  *) uninstall;;
esac
