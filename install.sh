#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/opencode"

# Warna
R='\033[38;5;196m' G='\033[38;5;82m' C='\033[38;5;213m' W='\033[38;5;255m' M='\033[38;5;248m' N='\033[0m'

ok(){ printf "${G}  ✔ %s${N}\n" "$1"; }

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

install(){
  clear
  box_awal

  mkdir -p "$CFG/agent" "$CFG/skill" "$CFG/command" "$CFG/docs" "$CFG/memory"

  dots "agent..."
  cp -R "$SCRIPT_DIR/agents/." "$CFG/agent/"

  dots "skill..."
  cp -R "$SCRIPT_DIR/skills/." "$CFG/skill/"
  chmod +x "$CFG"/skill/*/run.sh 2>/dev/null

  dots "command..."
  cp -R "$SCRIPT_DIR/command/." "$CFG/command/"
  cp -R "$SCRIPT_DIR/commands/." "$CFG/command/" 2>/dev/null

  dots "docs..."
  cp "$SCRIPT_DIR/docs/"*.md "$CFG/docs/" 2>/dev/null

  dots "doctrine..."
  cp "$SCRIPT_DIR/AGENTS.md" "$SCRIPT_DIR/VERSION" "$CFG/"

  local n=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo
  ok "$n file"

  box_selesai
}

case "${1:-}" in
  --help|-h) echo "Usage: bash install.sh";;
  *) install;;
esac
