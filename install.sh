#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/opencode"
VERSION="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo 'unknown')"

# Warna + UI modern (box rounded, section bernomor, step, progress bar)
R='\033[38;5;196m' G='\033[38;5;82m' C='\033[38;5;213m' W='\033[38;5;255m' M='\033[38;5;248m' N='\033[0m'
B='\033[1m' D='\033[38;5;240m' Y='\033[38;5;214m'
ok()  { printf "${G}  ✔ %s${N}\n" "$1"; }
inf() { printf "${M}  ▸ %s${N}\n" "$1"; }
wrn() { printf "${Y}  ⚠ %s${N}\n" "$1"; }

# animasi aktif hanya: TTY + ANIM=1 + bukan NO_ANIM/CI
ANIM="${ANIM:-1}"
anim_on(){ [ "${ANIM:-1}" -eq 1 ] && [ -t 1 ] && [ "${NO_ANIM:-}" != "1" ] && [ -z "${CI:-}" ]; }

# lebar teks buang escape ansi (dua bentuk: literal \033 & ESC nyata)
plen(){ printf '%s' "$1" | sed -e 's/\\033\[[0-9;]*m//g' -e 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' '; }

# lebar box adaptif layar (default 60, min 40)
W_=60
if [ -n "${COLUMNS:-}" ] && [ "${COLUMNS:-0}" -ge 40 ]; then
  W_=$(( COLUMNS - 6 )); [ "$W_" -gt 60 ] && W_=60
fi

# rounded box — isi baris-baris teks (escape \033 diproses via %b)
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

# section bernomor: [n/N] JUDUL ───────
section(){ printf "  ${C}${B}[%s]${N} ${B}%s${N} ${D}%s${N}\n" "$1" "$2" "$(printf '─%.0s' $(seq 1 40))"; }

# step: ikon + label (kolom 16) + detail
step(){ local col="$G"; case "$1" in ⚠) col="$Y" ;; ✖) col="$R" ;; ▸) col="$M" ;; esac
  printf "   ${col}%s${N}  %-16s ${D}%s${N}\n" "$1" "$2" "$3"; }

# progress bar (TTY): \r overwrite; non-TTY: fallback step ✔
progres(){ local pct="$1" label="$2" fill i
  if anim_on; then
    fill=$(( pct * 34 / 100 ))
    printf "\r   ${C}[${N}"
    for ((i=0;i<34;i++)); do
      if [ "$i" -lt "$fill" ]; then printf "${C}▓${N}"; else printf "${D}░${N}"; fi
    done
    printf "${C}]${N} ${B}%3d%%${N} ${M}%s${N}   " "$pct" "$label"
  else
    step "✔" "$label" ""
  fi
}
progres_nl(){ [ "${ANIM:-1}" -eq 1 ] && [ -t 1 ] && printf "\n"; return 0; }

# loading lama → tampilan modern (analog dots versi kit): ▸ singkat / ✔ animasi
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

box_awal(){ # $1 = judul (opsional)
  local color="$C"; anim_on || color=""
  box "$color" \
    "${B}${C}  ◆ AGENT AI${N}${D}  —  otak permanen untuk opencode${N}" \
    "${M}  v${VERSION} · auto-detect OpenCode V1/V2${N}" \
    "${D}  11 agent · 64 skill · 40 command${N}"
}

box_selesai(){ # $1 = ok|batal|lepas|gagal
  local mode="${1:-ok}" color="$G" title="  ${G}${B}✔ INSTALASI SELESAI${N}"
  local sub="restart opencode biar semua agent & skill aktif"
  case "$mode" in
    batal) color="$M"; title="  ${M}${B}◦ DIBATALKAN${N}"; sub="tidak ada yang diubah" ;;
    lepas) color="$G"; title="  ${G}${B}✔ DILEPAS${N}"; sub="install lagi: curl -fsSL …/curl-install.sh | bash" ;;
    gagal) color="$R"; title="  ${R}${B}✖ GAGAL${N}"; sub="ulangi: bash install.sh" ;;
    esac
  anim_on || color=""
  echo
  box "$color" "$title ${M}v${VERSION}${N}" "  ${M}${sub}${N}"
}

# ═══════════════════════════════════════════════════════════
# AUTO-DETECT — v1 or v2
# ═══════════════════════════════════════════════════════════
# Klasifikasi murni dari string versi → echo v1/v2 (kosong bila tak jelas).
classify_oc_ver(){
  case "$1" in
    opencodev2*|2.*|v2.*|opencode/2*) echo "v2"; return 0 ;;
    opencodev1*|1.*|v1.*|0.*|opencode/1*|opencode/0*) echo "v1"; return 0 ;;
  esac
  return 1
}

# Versi upstream yang dibundel wrapper Termux (opencode-termux*).
# TIDAK menjalankan binary — shebang package bisa rusak di Termux (#!/usr/bin/env).
opencode_termux_version(){
  local bin="$1" pkg=""
  if command -v "$bin" >/dev/null 2>&1; then
    pkg=$(readlink -f "$(command -v "$bin")" 2>/dev/null || command -v "$bin")
  else
    pkg=$(readlink -f "$bin" 2>/dev/null || echo "$bin")
  fi
  local root; root=$(dirname "$(dirname "$pkg")")
  local up=""
  if [ -f "$root/package.json" ]; then
    if command -v node >/dev/null 2>&1; then
      up=$(node -e 'const p=require(process.argv[1]);process.stdout.write(String(p.opencodeUpstream||p.version||""))' "$root/package.json" 2>/dev/null)
    else
      up=$(grep -o '"opencodeUpstream"[^,}]*' "$root/package.json" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
    fi
  fi
  classify_oc_ver "$up" || echo "v2"
}

detect_version(){
  # 1. Check binary — cakup channel Termux (opencode-termux*) + resmi + path vendor
  local oc_bin=""
  for b in opencode-termux-v2 opencode-termux opencode2 opencode; do
    command -v "$b" >/dev/null 2>&1 && { oc_bin="$b"; break; }
  done
  [ -z "$oc_bin" ] && for p in \
    /data/data/com.termux/files/usr/lib/node_modules/opencode-termux-v2/vendor/opencode \
    /data/data/com.termux/files/usr/lib/node_modules/@nemoobc/opencode-termux/bin/opencode-termux.js \
    /data/data/com.termux/files/usr/lib/node_modules/@opencode/cli/bin/opencode.exe; do
    [ -e "$p" ] && { oc_bin="$p"; break; }
  done
  if [ -n "$oc_bin" ]; then
    case "$oc_bin" in
      *opencode-termux*)
        echo "$(opencode_termux_version "$oc_bin")"; return ;;
      *)
        local oc_ver
        oc_ver=$("$oc_bin" --version 2>/dev/null | head -1 | tr -d '[:space:]')
        classify_oc_ver "$oc_ver" && return ;;
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
    if k not in ("devbrain","permissions","update","snapshots","$schema","permission","share","snapshot","autoupdate","experimental"): new[k] = v
with open(path, "w") as f: json.dump(new, f, indent=2); f.write("\n")
PYEOF
    ok "config V2 ditulis ($MARK)"
  elif [ -f "$cfg_file" ] && command -v node >/dev/null 2>&1; then
    node - "$cfg_file" "$MARK" "$PERM_ARRAY" <<'NODEEOF'
const fs=require('fs'),[p,m,pj]=process.argv.slice(2);
let o={};try{o=JSON.parse(fs.readFileSync(p,'utf8'))}catch(e){}
const c={"$schema":"https://opencode.ai/config.json","devbrain":m,"permissions":JSON.parse(pj),"update":"notify","snapshots":false};
for(const k of Object.keys(o)){if(!["devbrain","permissions","update","snapshots","$schema","permission","share","snapshot","autoupdate","experimental"].includes(k))c[k]=o[k]}
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
  install_deps || { wrn "dependensi kurang — dibatalkan"; box_selesai gagal; return 1; }

  local VER
  VER=$(detect_version)

  section "1/4" "PENYIAPAN"
  step "✔" "OpenCode" "terdeteksi: $VER (auto V1/V2)"

  # Sisihkan layout versi lain yang tersisa (deteksi lama/keliru) — aman, tidak dihapus
  if [ "$VER" = "v2" ]; then
    local saw_v1=0
    for d in agent command; do
      if [ -d "$CFG/$d" ]; then
        mv "$CFG/$d" "$CFG/$d.v1.bak"
        wrn "layout V1 sisa dipindah: $d → $d.v1.bak"
        saw_v1=1
      fi
    done
    # commands/ folder V2 yang SAH — pindahkan hanya bila beneran sisa V1 (ada agent|command)
    if [ "$saw_v1" -eq 1 ] && [ -d "$CFG/commands" ]; then
      mv "$CFG/commands" "$CFG/commands.v1.bak"
      wrn "layout V1 sisa dipindah: commands → commands.v1.bak"
    fi
  else
    [ -d "$CFG/agents" ] && { mv "$CFG/agents" "$CFG/agents.v2.bak"; wrn "layout V2 sisa dipindah: agents → agents.v2.bak"; }
  fi

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

  section "2/4" "MEMASANG"
  progres 5 "agents..."
  cp -R "$SCRIPT_DIR/agents/." "$AGENT_DIR/" || { wrn "gagal copy agent"; return 1; }

  progres 40 "skills..."
  for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    local n; n=$(basename "$skill_dir")
    cp -R "$skill_dir" "$CFG/skills/$n" || { wrn "gagal copy skill $n"; return 1; }
    chmod +x "$CFG/skills/$n/run.sh" 2>/dev/null
  done

  progres 70 "commands..."
  cp -R "$SCRIPT_DIR/command/." "$CMD_DIR/" || { wrn "gagal copy command"; return 1; }
  [ -n "$CMD_WRAP" ] && cp -R "$SCRIPT_DIR/commands/." "$CMD_WRAP/" 2>/dev/null

  progres 90 "docs..."
  cp "$SCRIPT_DIR/docs/"*.md "$CFG/docs/" 2>/dev/null || true

  progres 100 "doctrine..."
  cp "$SCRIPT_DIR/AGENTS.md" "$SCRIPT_DIR/VERSION" "$CFG/" || { wrn "gagal copy doctrine"; return 1; }
  progres_nl

  section "3/4" "KEAMANAN & PRIVASI"
  backup_config
  local MODE="granular"
  [ "${ALLOW_ALL:-0}" -eq 1 ] && MODE="allow-all"
  if [ "$VER" = "v2" ]; then
    write_config_v2 "$MODE" "$CFG/opencode.json"
  else
    write_config_v1 "$MODE" "$CFG/opencode.json"
  fi
  step "✔" "Permission" "$MODE"
  step "✔" "Privasi" "share/snapshot/telemetry: OFF"
  step "✔" "Config kamu" "di-merge, tidak ditimpa • backup .bak"

  section "4/4" "VERIFIKASI"
  local n; n=$(find "$AGENT_DIR" "$CFG/skills" "$CMD_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
  step "✔" "Terpasang" "$n file (OpenCode $VER)"
  box_selesai
}

# ═══════════════════════════════════════════════════════════
# UNINSTALL
# ═══════════════════════════════════════════════════════════
uninstall(){
  clear; box_awal
  [ ! -d "$CFG" ] && { inf "Tidak ada instalasi"; box_selesai batal; return; }

  local VER; VER=$(detect_version)
  local AGENT_DIR CMD_DIR CMD_WRAP=""
  if [ "$VER" = "v2" ]; then
    AGENT_DIR="$CFG/agents"; CMD_DIR="$CFG/commands"
  else
    AGENT_DIR="$CFG/agent"; CMD_DIR="$CFG/command"; CMD_WRAP="$CFG/commands"
  fi

  if [ "${ALLOW_YES:-0}" != "1" ] && [ -t 0 ]; then
    local na; na=$(ls -1 "$AGENT_DIR" 2>/dev/null | wc -l | tr -d ' ')
    local col="$Y"; anim_on || col=""
    box "$col" \
      "  ${Y}${B}⚠ LEPAS INSTALASI${N}${D} — agent ($na) + skills + commands + doktrin${N}" \
      "  ${M}memory/ TETAP aman • config dipulihkan dari backup${N}"
    printf "\n  Lanjut lepas? (y/N): "; read -r ans
    case "$ans" in y|Y|yes|YES) ;; *) inf "dibatalkan"; box_selesai batal; return 1;; esac
  fi

  section "1/2" "MELEPAS"
  dots "agents..."; rm -rf "$AGENT_DIR"
  dots "skills..."; rm -rf "$CFG/skills"
  dots "commands..."; rm -rf "$CMD_DIR"; [ -n "$CMD_WRAP" ] && rm -rf "$CMD_WRAP"
  dots "docs..."; rm -rf "$CFG/docs"
  dots "doctrine..."; rm -f "$CFG/AGENTS.md" "$CFG/VERSION"

  section "2/2" "MEMULIHKAN"
  local bak; bak=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  if [ -n "${bak:-}" ]; then mv "$bak" "$CFG/opencode.json"; ok "config dipulihkan"
  elif grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then rm -f "$CFG/opencode.json"; ok "config DEV-BRAIN dilepas"
  fi

  [ -d "$CFG/memory" ] && wrn "memory/ DIPERTAHANKAN"
  echo; inf "pasang lagi: bash install.sh"; box_selesai lepas
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
# Bandingkan semver: ver_gt A B → 0 bila A > B (upto 3 segmen; A==B → 1)
ver_gt(){
  local a="$1" b="$2" an bn i
  a=$(printf '%s' "$a" | sed 's/[^0-9.]//g'); b=$(printf '%s' "$b" | sed 's/[^0-9.]//g')
  IFS=. read -r -a an <<< "$a"
  IFS=. read -r -a bn <<< "$b"
  for i in 0 1 2; do
    [ "${an[$i]:-0}" -gt "${bn[$i]:-0}" ] && return 0
    [ "${an[$i]:-0}" -lt "${bn[$i]:-0}" ] && return 1
  done
  return 1
}
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
  if ver_gt "$OLDV" "$NEWV"; then
    wrn "anti-downgrade: $NEWV < $OLDV — DITOLAK (versi lama utuh)"
    rm -rf "$TMP"; return 0
  fi
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
if [ "${DEV_BRAIN_NO_RUN:-0}" -eq 1 ]; then
  : # mode source — fungsi dipanggil langsung (unit test)
elif [ "$UNINSTALL" -eq 1 ]; then
  uninstall
else
  install
fi
