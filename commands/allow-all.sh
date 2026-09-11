#!/usr/bin/env bash
# allow-all — buka semua izin opencode (edit/write/webfetch/bash = allow), backup otomatis
# Usage: bash commands/allow-all.sh
set -u

CFG="$HOME/.config/opencode"
mkdir -p "$CFG" || { echo "✖ tidak bisa buat $CFG"; exit 1; }

# Colors
R='\033[38;5;196m'
G='\033[38;5;82m'
Y='\033[38;5;214m'
C='\033[38;5;213m'
M='\033[38;5;248m'
W='\033[38;5;255m'
B='\033[38;5;244m'
RST='\033[0m'

# Animation helper
spin() {
  local msg="$1"
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  for i in {1..8}; do
    printf "\r${C}  %s${RST} ${M}%s${RST}" "${frames[$((i % 10))]}" "$msg"
    sleep 0.1
  done
  printf "\r${G}  ✔${RST} %s\n" "$msg"
}

clear_line() {
  printf "\033[2K"
}

# Header
echo ""
printf "${C}╔══════════════════════════════════════════════════════════╗${RST}\n"
printf "${C}║${RST}         ${W}🔓 ALLOW-ALL — BUKA SEMUA IZIN${RST}                  ${C}║${RST}\n"
printf "${C}╚══════════════════════════════════════════════════════════╝${RST}\n"
echo ""

# Step 1: Check config
spin "Memeriksa folder config..."
echo ""

# Step 2: Backup
if [ -f "$CFG/opencode.json" ]; then
  BAK="$CFG/opencode.json.bak.$(date +%s)"
  spin "Membuat backup..."
  cp "$CFG/opencode.json" "$BAK"
  printf "${G}  ✔${RST} Backup tersimpan: ${B}%s${RST}\n" "$BAK"
else
  printf "${Y}  ⚠${RST} Tidak ada config lama, backup dilewati\n"
fi
echo ""

# Step 3: Write config
spin "Menulis konfigurasi allow-all..."
cat > "$CFG/opencode.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "devbrain": "allow-all",
  "permission": {
    "edit": "allow",
    "write": "allow",
    "webfetch": "allow",
    "bash": {
      "*": "allow"
    }
  }
}
EOF

if [ $? -eq 0 ]; then
  printf "${G}  ✔${RST} Config berhasil ditulis\n"
else
  printf "${R}  ✖${RST} Gagal menulis config\n"
  exit 1
fi
echo ""

# Step 4: Summary
printf "${C}╔══════════════════════════════════════════════════════════╗${RST}\n"
printf "${C}║${RST}                   ${G}HASIL IZIN${RST}                           ${C}║${RST}\n"
printf "${C}╠══════════════════════════════════════════════════════════╣${RST}\n"
printf "${C}║${RST}  ${G}✔${RST} EDIT     : ${G}allow${RST}                                  ${C}║${RST}\n"
printf "${C}║${RST}  ${G}✔${RST} WRITE    : ${G}allow${RST}                                  ${C}║${RST}\n"
printf "${C}║${RST}  ${G}✔${RST} WEBFETCH : ${G}allow${RST}                                  ${C}║${RST}\n"
printf "${C}║${RST}  ${G}✔${RST} BASH     : ${G}* → allow${RST}                             ${C}║${RST}\n"
printf "${C}╠══════════════════════════════════════════════════════════╣${RST}\n"
printf "${C}║${RST}  ${Y}⚠ HUKUM 5 tetap berlaku: destruktif/force-push${RST}      ${C}║${RST}\n"
printf "${C}║${RST}  ${Y}   install/berbiaya tetap berhenti${RST}                  ${C}║${RST}\n"
printf "${C}╠══════════════════════════════════════════════════════════╣${RST}\n"
if [ -n "${BAK:-}" ]; then
  printf "${C}║${RST}  ${M}↩ REVERT : mv %s${RST}" "$BAK"
  printf "\x1b[%dC" $((35 - ${#BAK}))
  printf "${C}║${RST}\n"
fi
printf "${C}╚══════════════════════════════════════════════════════════╝${RST}\n"
echo ""
printf "${G}  🔓 SEMUA IZIN TERBUKA — SIAP KERJA!${RST}\n"
echo ""

exit 0
