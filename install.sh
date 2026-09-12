#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/opencode"

# Warna
R='\033[38;5;196m' G='\033[38;5;82m' C='\033[38;5;213m' W='\033[38;5;255m' M='\033[38;5;248m' N='\033[0m'

ok(){ printf "${G}  ✔ %s${N}\n" "$1"; }
inf(){ printf "${M}  ▸ %s${N}\n" "$1"; }
wrn(){ printf "\033[38;5;214m  ⚠ %s${N}\n" "$1"; }

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

# Backup config user sebelum ditimpa (hanya jika bukan tulisan DEV-BRAIN)
backup_config(){
  if [ -f "$CFG/opencode.json" ] && ! grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    cp "$CFG/opencode.json" "$CFG/opencode.json.bak.$(date +%s)"
    inf "config user dibackup"
  fi
}

# Tulis opencode.json DEV-BRAIN (allow-all) — MERGE, jangan timpa config user (MCP/provider/model)
write_config(){
  if [ -f "$CFG/opencode.json" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$CFG/opencode.json" <<'PYEOF'
import json, sys
path = sys.argv[1]
try:
    with open(path) as f:
        old = json.load(f)
except Exception:
    old = {}
new = {
    "$schema": "https://opencode.ai/config.json",
    "devbrain": "allow-all",
    "permission": {
        "edit": "allow",
        "write": "allow",
        "webfetch": "allow",
        "bash": {"*": "allow"}
    }
}
# Pertahankan semua bagian milik user (MCP, provider, model, agent, theme, dll)
for k, v in old.items():
    if k not in ("devbrain", "permission"):
        new[k] = v
with open(path, "w") as f:
    json.dump(new, f, indent=2)
    f.write("\n")
PYEOF
    ok "opencode.json DEV-BRAIN ditulis (config user dipertahankan)"
  else
    cat > "$CFG/opencode.json" <<'OPencodeEOF'
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
OPencodeEOF
    ok "opencode.json DEV-BRAIN ditulis"
  fi
}

install(){
  clear
  box_awal

  mkdir -p "$CFG/agent" "$CFG/skill" "$CFG/command" "$CFG/docs" "$CFG/memory"

  dots "agent..."
  cp -R "$SCRIPT_DIR/agents/." "$CFG/agent/"

  dots "skill..."
  for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    name=$(basename "$skill_dir")
    cp -R "$skill_dir" "$CFG/skill/$name"
    chmod +x "$CFG/skill/$name/run.sh" 2>/dev/null
  done

  dots "command..."
  cp -R "$SCRIPT_DIR/command/." "$CFG/command/"
  cp -R "$SCRIPT_DIR/commands/." "$CFG/command/" 2>/dev/null

  dots "docs..."
  cp "$SCRIPT_DIR/docs/"*.md "$CFG/docs/" 2>/dev/null

  dots "doctrine..."
  cp "$SCRIPT_DIR/AGENTS.md" "$SCRIPT_DIR/VERSION" "$CFG/"

  backup_config
  write_config

  local n=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo
  ok "$n file"

  box_selesai
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
  if [ -n "${bak:-}" ]; then
    mv "$bak" "$CFG/opencode.json"
    ok "opencode.json dipulihkan dari backup"
  elif [ -f "$CFG/opencode.json" ] && grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    rm -f "$CFG/opencode.json"
    ok "opencode.json buatan DEV-BRAIN dihapus"
  fi

  if [ -d "$CFG/memory" ]; then
    local nm=$(ls -1 "$CFG/memory" 2>/dev/null | wc -l | tr -d ' ')
    wrn "folder memory/ DIPERTAHANKAN — $nm file ingatan kamu selamat"
  fi

  echo
  inf "pasang lagi: bash install.sh"

  box_selesai
}

usage(){
  echo "Usage: bash install.sh [--offline] [--uninstall] [--update] [--check] [--help]"
  echo "  --offline     install tanpa animasi/cek jaringan (CI aman)"
  echo "  --uninstall   buang agent & doctrine (memori DIPERTAHANKAN)"
  echo "  --update      update dari DEV_BRAIN_UPDATE_URL (memori aman)"
  echo "  --check       cek kesehatan instalasi (tanpa menulis)"
  echo "  --help        tampilkan bantuan ini"
}

# Cek kesehatan instalasi
check_install(){
  local BAD=0
  [ -f "$CFG/AGENTS.md" ] || { wrn "doctrine hilang: $CFG/AGENTS.md"; BAD=1; }
  [ -f "$CFG/opencode.json" ] || { wrn "config hilang: $CFG/opencode.json"; BAD=1; }
  grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null || wrn "opencode.json tanpa marker devbrain (bukan tulisan installer)"
  for d in agent command memory skill; do
    [ -d "$CFG/$d" ] || { wrn "folder hilang: $CFG/$d"; BAD=1; }
  done
  local n=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${n:-0}" -ge 20 ] || { wrn "file otak cuma $n — install ulang"; BAD=1; }
  local v=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  if [ -n "$v" ]; then ok "versi terpasang: $v"; else wrn "versi tidak tercatat (install lama) — update disarankan"; fi
  for s in "$CFG"/skill/*/run.sh; do
    [ -f "$s" ] || continue
    bash -n "$s" 2>/dev/null || { wrn "script rusak: $s"; BAD=1; }
  done
  if [ "$BAD" -eq 0 ]; then ok "instalasi sehat — $n file otak, semua script valid"; return 0
  else wrn "cek selesai (ada masalah)"; return 1
  fi
}

# Update dari remote (file:// untuk test, https untuk produksi)
update(){
  local UPDATE_URL="${DEV_BRAIN_UPDATE_URL:-}"
  [ -n "$UPDATE_URL" ] || { wrn "DEV_BRAIN_UPDATE_URL kosong — update dibatalkan"; return 1; }
  command -v curl >/dev/null 2>&1 || { wrn "curl tidak ada — update manual: git clone"; return 1; }
  local TMP; TMP=$(mktemp -d)
  if curl -fsSL --connect-timeout 5 --max-time 60 "$UPDATE_URL" -o "$TMP/kit.tgz"; then
    ok "unduh selesai"
  else
    wrn "unduh gagal — cek koneksi"; rm -rf "$TMP"; return 1
  fi
  tar -xzf "$TMP/kit.tgz" -C "$TMP" || { wrn "ekstrak gagal"; rm -rf "$TMP"; return 1; }
  local SRC; SRC=$(find "$TMP" -maxdepth 1 -type d -name 'agent-ai*' | head -1)
  [ -f "$SRC/install.sh" ] || { wrn "paket tidak valid"; rm -rf "$TMP"; return 1; }
  local NEWV OLDV OLDER
  NEWV=$(tr -d '[:space:]' < "$SRC/VERSION" 2>/dev/null)
  OLDV=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  inf "terpasang: ${OLDV:-?} → tersedia: ${NEWV:-?}"
  OLDER=$(printf '%s\n%s\n' "${OLDV:-0}" "${NEWV:-0}" | sort -V | head -1)
  if [ -n "$OLDV" ] && [ "$OLDER" != "$OLDV" ]; then
    ok "remote ($NEWV) tidak lebih baru dari terpasang ($OLDV) — skip"
    rm -rf "$TMP"; return 0
  fi
  if [ "$NEWV" = "$OLDV" ]; then ok "sudah versi terbaru"; rm -rf "$TMP"; return 0; fi
  if bash "$SRC/install.sh" --offline; then ok "update ke $NEWV selesai — memori tetap aman"; else wrn "update gagal di tengah — instalasi lama utuh"; fi
  rm -rf "$TMP"
}

OFFLINE=0
UNINSTALL=0
UPDATE=0
CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --offline) OFFLINE=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --update) UPDATE=1; shift ;;
    --check) CHECK=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) wrn "arg tak dikenal: $1 (diabaikan)"; shift ;;
  esac
done

if [ "$CHECK" -eq 1 ]; then
  check_install
  exit $?
fi
if [ "$UPDATE" -eq 1 ]; then
  update
  exit $?
fi
if [ "$UNINSTALL" -eq 1 ]; then
  uninstall
else
  [ "$OFFLINE" -eq 1 ] && ANIM=0
  install
fi