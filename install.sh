#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/opencode"
VERSION="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo 'unknown')"

# Warna
R='\033[38;5;196m' G='\033[38;5;82m' C='\033[38;5;213m' W='\033[38;5;255m' M='\033[38;5;248m' N='\033[0m'
ok()  { printf "${G}  ✔ %s${N}\n" "$1"; }
inf() { printf "${M}  ▸ %s${N}\n" "$1"; }
wrn() { printf "\033[38;5;214m  ⚠ %s${N}\n" "$1"; }

dots(){
  local msg="$1" d=("." ".." "...")
  for j in {1..3}; do
    printf "\r${M}  %s${N} ${C}%s${N}" "${d[$((j%3))]}" "$msg"
    sleep 0.3
  done
  printf "\r${G}  ✔${N} %s\n" "$msg"
}

ANIM="${ANIM:-1}"
anim_on(){ [ "${ANIM:-1}" -eq 1 ] && [ -t 1 ] && [ "${NO_ANIM:-}" != "1" ]; }

box_awal(){
  local border="${C}"
  anim_on || border=""
  printf "${border}  ┌─────────────────────┐${N}\n"
  printf "${W}  │      AGENT AI       │${N}\n"
  printf "${border}  └─────────────────────┘${N}\n"
}

box_selesai(){
  local border="${G}"
  anim_on || border=""
  printf "\n${border}  ┌─────────────────────┐${N}\n"
  printf "${border}  │       SELESAI       │${N}\n"
  printf "${border}  └─────────────────────┘${N}\n"
}

# ═══════════════════════════════════════════════════════════
# AUTO-DETECT — v1 or v2
# ═══════════════════════════════════════════════════════════
detect_version(){
  # 1. Check binary versions
  local oc_bin=""
  # Check opencode-termux-v2 (npm package)
  for b in opencode-termux-v2 opencode2 opencode; do
    command -v "$b" >/dev/null 2>&1 && { oc_bin="$b"; break; }
  done
  # Also check known vendor paths
  [ -z "$oc_bin" ] && for p in \
    /data/data/com.termux/files/usr/lib/node_modules/opencode-termux-v2/vendor/opencode \
    /data/data/com.termux/files/usr/lib/node_modules/@opencode/cli/bin/opencode.exe; do
    [ -x "$p" ] && { oc_bin="$p"; break; }
  done
  if [ -n "$oc_bin" ]; then
    local oc_ver
    oc_ver=$("$oc_bin" --version 2>/dev/null | head -1 | tr -d '[:space:]')
    case "$oc_ver" in
      opencodev2*|2.*|v2.*) echo "v2"; return ;;
      opencodev1*|1.*|v1.*) echo "v1"; return ;;
    esac
  fi
  # 2. Check directory structure
  [ -d "$CFG/agents" ] && { echo "v2"; return; }
  [ -d "$CFG/agent" ] && { echo "v1"; return; }
  # 3. Config markers
  local cfg_file=""
  [ -f "$CFG/opencode.json" ] && cfg_file="$CFG/opencode.json"
  [ -f "$CFG/opencode.jsonc" ] && cfg_file="$CFG/opencode.jsonc"
  [ -n "$cfg_file" ] && grep -q '"permissions"' "$cfg_file" 2>/dev/null && { echo "v2"; return; }
  # 4. Default
  echo "v1"
}

# ═══════════════════════════════════════════════════════════
# BACKUP
# ═══════════════════════════════════════════════════════════
backup_config(){
  local cfg_file="$CFG/opencode.json"
  [ -f "$CFG/opencode.jsonc" ] && cfg_file="$CFG/opencode.jsonc"
  if [ -f "$cfg_file" ] && ! grep -q '"devbrain"' "$cfg_file" 2>/dev/null; then
    cp "$cfg_file" "$cfg_file.bak.$(date +%s)"
    inf "config user dibackup"
  fi
}

# ═══════════════════════════════════════════════════════════
# CONFIG — V1
# ═══════════════════════════════════════════════════════════
write_config_v1(){
  local MODE="$1" cfg_file="$2" PERM_JSON MARK
  if [ "$MODE" = "allow-all" ]; then
    PERM_JSON='{"edit":"allow","write":"allow","webfetch":"allow","bash":{"*":"allow"}}'
    MARK="allow-all"
  else
    PERM_JSON='{"edit":"ask","write":"ask","webfetch":"ask","bash":{"*":"ask"}}'
    MARK="granular"
  fi

  if [ -f "$cfg_file" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$cfg_file" "$MARK" "$PERM_JSON" <<'PYEOF'
import json, sys
path, mark, perm_json = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path) as f: old = json.load(f)
except: old = {}
perm = json.loads(perm_json)
new = {"$schema":"https://opencode.ai/config.json","devbrain":mark,"share":"disabled","snapshot":False,"autoupdate":False,"experimental":{"openTelemetry":False},"permission":perm}
for k, v in old.items():
    if k not in ("devbrain","permission","share","snapshot","autoupdate","experimental"): new[k] = v
with open(path, "w") as f: json.dump(new, f, indent=2); f.write("\n")
PYEOF
    ok "config V1 ditulis ($MARK)"
  elif [ -f "$cfg_file" ] && command -v node >/dev/null 2>&1; then
    node - "$cfg_file" "$MARK" "$PERM_JSON" <<'NODEEOF'
const fs=require('fs'),[p,m,pj]=process.argv.slice(2);
let o={};try{o=JSON.parse(fs.readFileSync(p,'utf8'))}catch(e){}
const c={"$schema":"https://opencode.ai/config.json","devbrain":m,"share":"disabled","snapshot":false,"autoupdate":false,"experimental":{"openTelemetry":false},"permission":JSON.parse(pj)};
for(const k of Object.keys(o)){if(!["devbrain","permission","share","snapshot","autoupdate","experimental"].includes(k))c[k]=o[k]}
fs.writeFileSync(p,JSON.stringify(c,null,2)+"\n")
NODEEOF
    ok "config V1 ditulis ($MARK, via node)"
  else
    cat > "$cfg_file" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "devbrain": "$MARK",
  "share": "disabled",
  "snapshot": false,
  "autoupdate": false,
  "experimental": { "openTelemetry": false },
  "permission": $PERM_JSON
}
EOF
    ok "config V1 ditulis ($MARK, template)"
  fi
}

# ═══════════════════════════════════════════════════════════
# CONFIG — V2
# ═══════════════════════════════════════════════════════════
write_config_v2(){
  local MODE="$1" cfg_file="$2" PERM_ARRAY MARK
  if [ "$MODE" = "allow-all" ]; then
    PERM_ARRAY='[{"action":"*","resource":"*","effect":"allow"}]'
    MARK="allow-all"
  else
    PERM_ARRAY='[{"action":"*","resource":"*","effect":"ask"}]'
    MARK="granular"
  fi

  if [ -f "$cfg_file" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$cfg_file" "$MARK" "$PERM_ARRAY" <<'PYEOF'
import json, sys
path, mark, perm_json = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path) as f: old = json.load(f)
except: old = {}
perm = json.loads(perm_json)
new = {"$schema":"https://opencode.ai/config.json","devbrain":mark,"permissions":perm,"update":"notify","snapshots":False}
for k, v in old.items():
    if k not in ("devbrain","permissions","update","snapshots","$schema"): new[k] = v
with open(path, "w") as f: json.dump(new, f, indent=2); f.write("\n")
PYEOF
    ok "config V2 ditulis ($MARK)"
  elif [ -f "$cfg_file" ] && command -v node >/dev/null 2>&1; then
    node - "$cfg_file" "$MARK" "$PERM_ARRAY" <<'NODEEOF'
const fs=require('fs'),[p,m,pj]=process.argv.slice(2);
let o={};try{o=JSON.parse(fs.readFileSync(p,'utf8'))}catch(e){}
const c={"$schema":"https://opencode.ai/config.json","devbrain":m,"permissions":JSON.parse(pj),"update":"notify","snapshots":false};
for(const k of Object.keys(o)){if(!["devbrain","permissions","update","snapshots","$schema"].includes(k))c[k]=o[k]}
fs.writeFileSync(p,JSON.stringify(c,null,2)+"\n")
NODEEOF
    ok "config V2 ditulis ($MARK, via node)"
  else
    cat > "$cfg_file" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "devbrain": "$MARK",
  "permissions": $PERM_ARRAY,
  "update": "notify",
  "snapshots": false
}
EOF
    ok "config V2 ditulis ($MARK, template)"
  fi
}

# ═══════════════════════════════════════════════════════════
# DEPS
# ═══════════════════════════════════════════════════════════
install_deps(){
  local NEED=() c
  for c in rg git curl node python make jq sqlite3; do
    command -v "$c" >/dev/null 2>&1 || NEED+=("$c")
  done
  [ ${#NEED[@]} -eq 0 ] && { ok "dependensi lengkap"; return 0; }
  wrn "dependensi kurang: ${NEED[*]}"
  local PKG=""
  command -v pkg >/dev/null 2>&1 && PKG="pkg"
  command -v apt-get >/dev/null 2>&1 && PKG="apt-get"
  [ -z "$PKG" ] && { wrn "install manual: ${NEED[*]}"; return 1; }
  local PKGS=() b
  for b in "${NEED[@]}"; do
    case "$b" in
      rg) PKGS+=(ripgrep) ;; node) PKGS+=(nodejs) ;; sqlite3) PKGS+=(sqlite) ;;
      python) [ "$PKG" = "apt-get" ] && PKGS+=(python3) || PKGS+=(python) ;;
      *) PKGS+=("$b") ;;
    esac
  done
  if [ "${ALLOW_YES:-0}" = "1" ] || ([ -t 0 ] && { printf "  install ${PKGS[*]} via $PKG? [y/N] "; read -r ans; [ "$ans" = "y" ] || [ "$ans" = "Y" ]; }); then
    inf "install: ${PKGS[*]}"
    $PKG install -y "${PKGS[@]}" || { wrn "install gagal"; return 1; }
    ok "dependensi siap"
  else
    wrn "dilewati — install manual: ${NEED[*]}"; return 1
  fi
}

# ═══════════════════════════════════════════════════════════
# MAIN INSTALL
# ═══════════════════════════════════════════════════════════
install(){
  clear
  box_awal
  install_deps || { wrn "dependensi kurang — dibatalkan"; box_selesai; return 1; }

  local VER
  VER=$(detect_version)
  inf "terdeteksi: OpenCode $VER"

  local AGENT_DIR CMD_DIR CMD_WRAP=""
  if [ "$VER" = "v2" ]; then
    AGENT_DIR="$CFG/agents"
    CMD_DIR="$CFG/commands"
  else
    AGENT_DIR="$CFG/agent"
    CMD_DIR="$CFG/command"
    CMD_WRAP="$CFG/commands"
  fi

  mkdir -p "$AGENT_DIR" "$CFG/skills" "$CMD_DIR" "$CFG/docs" "$CFG/memory" || { wrn "gagal buat folder"; return 1; }
  [ -n "$CMD_WRAP" ] && mkdir -p "$CMD_WRAP"

  dots "agents..."
  cp -R "$SCRIPT_DIR/agents/." "$AGENT_DIR/" || { wrn "gagal copy agent"; return 1; }

  dots "skills..."
  for d in "$SCRIPT_DIR/skills/"*/; do
    [ -d "$d" ] || continue
    local n; n=$(basename "$d")
    cp -R "$d" "$CFG/skills/$n" || { wrn "gagal copy skill $n"; return 1; }
    chmod +x "$CFG/skills/$n/run.sh" 2>/dev/null
  done

  dots "commands..."
  cp -R "$SCRIPT_DIR/command/." "$CMD_DIR/" || { wrn "gagal copy command"; return 1; }
  [ -n "$CMD_WRAP" ] && cp -R "$SCRIPT_DIR/commands/." "$CMD_WRAP/" 2>/dev/null

  dots "docs..."
  cp "$SCRIPT_DIR/docs/"*.md "$CFG/docs/" 2>/dev/null || true

  dots "doctrine..."
  cp "$SCRIPT_DIR/AGENTS.md" "$SCRIPT_DIR/VERSION" "$CFG/" || { wrn "gagal copy doctrine"; return 1; }

  backup_config
  if [ "$VER" = "v2" ]; then
    write_config_v2 "${ALLOW_ALL:+allow-all}" "$CFG/opencode.json"
  else
    write_config_v1 "${ALLOW_ALL:+allow-all}" "$CFG/opencode.json"
  fi

  local n; n=$(find "$AGENT_DIR" "$CFG/skills" "$CMD_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo; ok "$n file terpasang (OpenCode $VER)"
  box_selesai
}

# ═══════════════════════════════════════════════════════════
# UNINSTALL
# ═══════════════════════════════════════════════════════════
uninstall(){
  clear; box_awal
  [ ! -d "$CFG" ] && { inf "Tidak ada instalasi"; box_selesai; return; }

  local VER; VER=$(detect_version)
  local AGENT_DIR CMD_DIR CMD_WRAP=""
  if [ "$VER" = "v2" ]; then
    AGENT_DIR="$CFG/agents"; CMD_DIR="$CFG/commands"
  else
    AGENT_DIR="$CFG/agent"; CMD_DIR="$CFG/command"; CMD_WRAP="$CFG/commands"
  fi

  if [ "${ALLOW_YES:-0}" != "1" ] && [ -t 0 ]; then
    local na; na=$(ls -1 "$AGENT_DIR" 2>/dev/null | wc -l | tr -d ' ')
    inf "Lepas: agent ($na) + skills + commands + AGENTS.md (memory aman)"
    printf "  Lanjut? (y/n): "; read -r ans
    case "$ans" in y|Y|yes|YES) ;; *) inf "dibatalkan"; box_selesai; return 1;; esac
  fi

  dots "agents..."; rm -rf "$AGENT_DIR"
  dots "skills..."; rm -rf "$CFG/skills"
  dots "commands..."; rm -rf "$CMD_DIR"; [ -n "$CMD_WRAP" ] && rm -rf "$CMD_WRAP"
  dots "docs..."; rm -rf "$CFG/docs"
  dots "doctrine..."; rm -f "$CFG/AGENTS.md" "$CFG/VERSION"

  local bak; bak=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  if [ -n "${bak:-}" ]; then mv "$bak" "$CFG/opencode.json"; ok "config dipulihkan"
  elif grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then rm -f "$CFG/opencode.json"; ok "config DEV-BRAIN dilepas"
  fi

  [ -d "$CFG/memory" ] && wrn "memory/ DIPERTAHANKAN"
  echo; inf "pasang lagi: bash install.sh"; box_selesai
}

# ═══════════════════════════════════════════════════════════
# CHECK
# ═══════════════════════════════════════════════════════════
check_install(){
  local BAD=0 VER; VER=$(detect_version)
  inf "terdeteksi: OpenCode $VER"

  local AGENT_DIR CMD_DIR
  if [ "$VER" = "v2" ]; then
    AGENT_DIR="$CFG/agents"; CMD_DIR="$CFG/commands"
  else
    AGENT_DIR="$CFG/agent"; CMD_DIR="$CFG/command"
  fi

  [ -f "$CFG/AGENTS.md" ] || { wrn "doctrine hilang"; BAD=1; }
  [ -f "$CFG/opencode.json" ] || { wrn "config hilang"; BAD=1; }
  grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null || wrn "tanpa marker devbrain"
  [ -d "$AGENT_DIR" ] || { wrn "folder hilang: $AGENT_DIR"; BAD=1; }
  [ -d "$CMD_DIR" ] || { wrn "folder hilang: $CMD_DIR"; BAD=1; }
  [ -d "$CFG/skills" ] || { wrn "folder skills hilang"; BAD=1; }

  local n; n=$(find "$AGENT_DIR" "$CFG/skills" "$CMD_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${n:-0}" -ge 20 ] || { wrn "file cuma $n — install ulang"; BAD=1; }

  local v; v=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  [ -n "$v" ] && ok "versi: $v" || wrn "versi tidak tercatat"

  for s in "$CFG/skills"/*/run.sh; do
    [ -f "$s" ] || continue
    bash -n "$s" 2>/dev/null || { wrn "script rusak: $s"; BAD=1; }
  done

  if [ "$BAD" -eq 0 ]; then ok "sehat — $n file, OpenCode $VER"; return 0
  else wrn "ada masalah"; return 1; fi
}

# ═══════════════════════════════════════════════════════════
# UPDATE
# ═══════════════════════════════════════════════════════════
OFFICIAL_PREFIX="https://raw.githubusercontent.com/nemoobc/agent-ai"
update(){
  local UPDATE_URL="${DEV_BRAIN_UPDATE_URL:-}"
  [ -n "$UPDATE_URL" ] || { wrn "DEV_BRAIN_UPDATE_URL kosong"; return 1; }
  case "$UPDATE_URL" in
    file://*|"$OFFICIAL_PREFIX"*) ;; *) wrn "URL tidak resmi"; return 1 ;;
  esac
  command -v curl >/dev/null 2>&1 || { wrn "curl tidak ada"; return 1; }
  local TMP; TMP=$(mktemp -d)
  curl -fsSL --proto '=https,file' --tlsv1.2 --connect-timeout 5 --max-time 60 "$UPDATE_URL" -o "$TMP/kit.tgz" || { wrn "unduh gagal"; rm -rf "$TMP"; return 1; }
  case "$UPDATE_URL" in https://*)
    [ -n "${DEV_BRAIN_UPDATE_SHA:-}" ] || { wrn "SHA kosong — DITOLAK"; rm -rf "$TMP"; return 1; }
    command -v sha256sum >/dev/null 2>&1 || { wrn "sha256sum tidak ada"; rm -rf "$TMP"; return 1; }
    printf '%s  %s\n' "$DEV_BRAIN_UPDATE_SHA" "$TMP/kit.tgz" | sha256sum -c - >/dev/null 2>&1 || { wrn "SHA mismatch"; rm -rf "$TMP"; return 1; }
    ok "SHA cocok";;
  esac
  tar -xzf "$TMP/kit.tgz" -C "$TMP" || { wrn "ekstrak gagal"; rm -rf "$TMP"; return 1; }
  local SRC; SRC=$(find "$TMP" -maxdepth 1 -type d -name 'agent-ai*' | head -1)
  [ -f "$SRC/install.sh" ] || { wrn "paket tidak valid"; rm -rf "$TMP"; return 1; }
  local NEWV OLDV; NEWV=$(tr -d '[:space:]' < "$SRC/VERSION" 2>/dev/null); OLDV=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  inf "terpasang: ${OLDV:-?} → tersedia: ${NEWV:-?}"
  [ "$NEWV" = "$OLDV" ] && { ok "sudah terbaru"; rm -rf "$TMP"; return 0; }
  bash "$SRC/install.sh" --offline && ok "update ke $NEWV" || wrn "update gagal"
  rm -rf "$TMP"
}

# ═══════════════════════════════════════════════════════════
# USAGE
# ═══════════════════════════════════════════════════════════
usage(){
  cat <<EOF
Usage: bash install.sh [OPTIONS]
  --offline     tanpa animasi
  --uninstall   lepas agent (memory aman)
  --update      update dari DEV_BRAIN_UPDATE_URL
  --check       cek kesehatan
  --allow-all   permission allow semua
  --yes         lewati konfirmasi
  --help        bantuan

Auto-detect: OpenCode V1 atau V2 → install ke lokasi yang benar.
EOF
}

# ═══════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════
OFFLINE=0 UNINSTALL=0 UPDATE=0 CHECK=0 ALLOW_ALL=0 ALLOW_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --offline) OFFLINE=1;; --uninstall) UNINSTALL=1;; --update) UPDATE=1;;
    --check) CHECK=1;; --allow-all) ALLOW_ALL=1;; --yes|-y) ALLOW_YES=1;;
    --help|-h) usage; exit 0;; *) wrn "arg tak dikenal: $1";;
  esac
  shift
done

[ "$CHECK" -eq 1 ] && { check_install; exit $?; }
[ "$UPDATE" -eq 1 ] && { update; exit $?; }
[ "$OFFLINE" -eq 1 ] && ANIM=0
[ "$UNINSTALL" -eq 1 ] && uninstall || install
