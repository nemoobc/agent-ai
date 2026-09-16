#!/usr/bin/env bash
set -uo pipefail

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

# Tulis opencode.json DEV-BRAIN — MERGE, jangan timpa config user (MCP/provider/model)
# HANYA keamanan+privasi ditambah: devbrain marker + permission ask (granular, allow-all opt-in
# via --allow-all / DEV_BRAIN_ALLOW_ALL=1) + share/snapshot/autoupdate/openTelemetry dimatikan
# (provider/model tidak lihat aktivitas user). model/provider TIDAK di-set. Engine merge:
# python3 → node. Tanpa keduanya: config user berisi TETAP DIAMKAN, template hanya untuk
# instalasi baru / config DEV-BRAIN lama.
write_config(){
  local MODE="granular"
  [ "${ALLOW_ALL:-0}" = "1" ] && MODE="allow-all"
  [ "${DEV_BRAIN_ALLOW_ALL:-}" = "1" ] && MODE="allow-all"
  local PERM_JSON MARK
  PERM_JSON='{"edit":"ask","write":"ask","webfetch":"ask","bash":{"*":"ask"}}'
  [ "$MODE" = "allow-all" ] && PERM_JSON='{"edit":"allow","write":"allow","webfetch":"allow","bash":{"*":"allow"}}'
  MARK='granular'
  [ "$MODE" = "allow-all" ] && MARK='allow-all'

  write_tpl(){
    printf '%s\n' '{' \
      '  "$schema": "https://opencode.ai/config.json",' \
      "  \"devbrain\": \"$MARK\"," \
      '  "share": "disabled",' \
      '  "snapshot": false,' \
      '  "autoupdate": false,' \
      '  "experimental": {' \
      '    "openTelemetry": false' \
      '  },' \
      '  "permission": {' \
      '    "edit": "ask",' \
      '    "write": "ask",' \
      '    "webfetch": "ask",' \
      '    "bash": {' \
      '      "*": "ask"' \
      '    }' \
      '  }' \
      '}' > "$CFG/opencode.json"
    [ "$MODE" = "allow-all" ] && sed -i 's/"edit": "ask"/"edit": "allow"/; s/"write": "ask"/"write": "allow"/; s/"webfetch": "ask"/"webfetch": "allow"/; s/"\*": "ask"/"*": "allow"/' "$CFG/opencode.json"
  }

  if [ -f "$CFG/opencode.json" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$CFG/opencode.json" "$MODE" <<'PYEOF'
import json, sys
path, mode = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        old = json.load(f)
except Exception:
    old = {}
if mode == "allow-all":
    perm = {"edit": "allow", "write": "allow", "webfetch": "allow", "bash": {"*": "allow"}}
else:
    perm = {"edit": "ask", "write": "ask", "webfetch": "ask", "bash": {"*": "ask"}}
# Privasi: provider/model TIDAK melihat aktivitas user — share/snapshot/telemetry dimatikan.
# User yang sudah set sendiri TETAP menang (loop di bawah menimpa key milik user).
new = {"$schema": "https://opencode.ai/config.json", "devbrain": "granular" if mode != "allow-all" else "allow-all", "share": "disabled", "snapshot": False, "autoupdate": False, "experimental": {"openTelemetry": False}, "permission": perm}
# Pertahankan semua bagian milik user (MCP, provider, model, agent, theme, dll)
for k, v in old.items():
    if k not in ("devbrain", "permission"):
        new[k] = v
with open(path, "w") as f:
    json.dump(new, f, indent=2)
    f.write("\n")
PYEOF
    ok "opencode.json DEV-BRAIN ditulis ($MODE, config user dipertahankan)"
  elif [ -f "$CFG/opencode.json" ] && command -v node >/dev/null 2>&1; then
    node - "$CFG/opencode.json" "$MODE" "$PERM_JSON" <<'NODEEOF'
const fs = require('fs');
const [path, mode, permJson] = process.argv.slice(2);
let old = {};
try { old = JSON.parse(fs.readFileSync(path, 'utf8')); } catch (e) { old = {}; }
const perm = JSON.parse(permJson);
// Privasi: share/snapshot/autoupdate/telemetry dimatikan; set user menang (loop bawah).
const cfg = { "$schema": "https://opencode.ai/config.json", "devbrain": mode === "allow-all" ? "allow-all" : "granular", "share": "disabled", "snapshot": false, "autoupdate": false, "experimental": { "openTelemetry": false }, "permission": perm };
for (const k of Object.keys(old)) { if (k !== "devbrain" && k !== "permission") cfg[k] = old[k]; }
fs.writeFileSync(path, JSON.stringify(cfg, null, 2) + "\n");
NODEEOF
    ok "opencode.json DEV-BRAIN ditulis ($MODE, config user dipertahankan via node)"
  elif [ -f "$CFG/opencode.json" ] && grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    # Config milik DEV-BRAIN lama — segarkan template
    write_tpl
    ok "opencode.json DEV-BRAIN ditulis ($MODE)"
  elif [ -f "$CFG/opencode.json" ] && ! grep -qE '"(mcp|provider|model|agent|theme|key|custom|hooks|experimental)"' "$CFG/opencode.json"; then
    # Config kosong/milik DEV-BRAIN lama — aman timpa template penuh
    write_tpl
    ok "opencode.json DEV-BRAIN ditulis ($MODE)"
  elif [ -f "$CFG/opencode.json" ]; then
    wrn "config user DIAMKAN (tidak ditimpa) — butuh python3 atau node untuk merge permission"
    inf "install dulu:  apt/pkg install python  atau  nodejs, lalu jalankan ulang install"
  else
    # Instalasi baru / config belum ada — tulis template penuh (tidak ada yang diamankan)
    write_tpl
    ok "opencode.json DEV-BRAIN ditulis ($MODE)"
  fi
}

# Dependensi penting — cek yang kurang, install via pkg (Termux) / apt-get (linux)
# Binary → nama paket: rg=ripgrep, node=nodejs, sqlite3=sqlite, sisanya sama.
pkg_of(){ case "$1" in rg) echo ripgrep;; node) echo nodejs;; sqlite3) echo sqlite;; *) echo "$1";; esac; }
install_deps(){
  local NEED=() PKG="" c
  for c in rg git curl node python make jq sqlite3; do
    command -v "$c" >/dev/null 2>&1 || NEED+=("$c")
  done
  [ ${#NEED[@]} -eq 0 ] && { ok "dependensi lengkap"; return 0; }
  wrn "dependensi kurang: ${NEED[*]}"
  if command -v pkg >/dev/null 2>&1; then
    PKG="pkg"
  elif command -v apt-get >/dev/null 2>&1; then
    PKG="apt-get"
  else
    wrn "manajer paket tidak dikenal — install manual: ${NEED[*]}"
    return 1
  fi
  if [ "${ALLOW_YES:-0}" = "1" ]; then
    inf "install: ${NEED[*]}"
    $PKG install -y "${NEED[@]}" || { wrn "install dependensi gagal"; return 1; }
    ok "dependensi siap"
  elif [ -t 0 ]; then
    printf "  install ${NEED[*]} via $PKG? [y/N] "; read -r ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
      inf "install: ${NEED[*]}"
      $PKG install -y "${NEED[@]}" || { wrn "install dependensi gagal"; return 1; }
      ok "dependensi siap"
    else
      wrn "dilewati — install manual: ${NEED[*]}"
      return 1
    fi
  else
    wrn "non-interaktif tanpa --yes — install manual: ${NEED[*]}"
    return 1
  fi
}

install(){
  clear
  box_awal

  install_deps || { wrn "dependensi belum lengkap — install dibatalkan"; box_selesai; return 1; }

  mkdir -p "$CFG/agent" "$CFG/skills" "$CFG/command" "$CFG/docs" "$CFG/memory" \
    || { wrn "gagal buat folder config"; return 1; }

  dots "agent..."
  cp -R "$SCRIPT_DIR/agents/." "$CFG/agent/" \
    || { wrn "gagal copy agent"; return 1; }

  dots "skill..."
  for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    name=$(basename "$skill_dir")
    cp -R "$skill_dir" "$CFG/skills/$name" || { wrn "gagal copy skill $name"; return 1; }
    chmod +x "$CFG/skills/$name/run.sh" 2>/dev/null
  done

  dots "command..."
  cp -R "$SCRIPT_DIR/command/." "$CFG/command/" || { wrn "gagal copy command"; return 1; }
  cp -R "$SCRIPT_DIR/commands/." "$CFG/command/" 2>/dev/null || { wrn "gagal copy wrapper"; return 1; }

  dots "docs..."
  cp "$SCRIPT_DIR/docs/"*.md "$CFG/docs/" 2>/dev/null || { wrn "gagal copy docs"; return 1; }

  dots "doctrine..."
  cp "$SCRIPT_DIR/AGENTS.md" "$SCRIPT_DIR/VERSION" "$CFG/" \
    || { wrn "gagal copy doctrine"; return 1; }

  backup_config
  write_config

  local n=$(find "$CFG/agent" "$CFG/skills" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
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

  if [ "${ALLOW_YES:-0}" != "1" ]; then
    if [ -t 0 ]; then
      local nagent=$(ls -1 "$CFG/agent" 2>/dev/null | wc -l | tr -d ' ')
      inf "Akan dilepas: agent $nagent + skill/command/docs + AGENTS.md (memory DIPERTAHANKAN)"
      printf "  Lanjutkan lepas? (y/n): "; read -r ans
      case "$ans" in y|Y|yes|YES) ;; *) inf "dibatalkan"; box_selesai; return 1;; esac
    else
      inf "dibatalkan — non-interaktif wajib --yes"
      box_selesai; return 1
    fi
  fi

  dots "agent..."
  rm -rf "$CFG/agent"

  dots "skill..."
  rm -rf "$CFG/skills"

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
    ok "opencode.json buatan DEV-BRAIN dilepas"
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
  echo "Usage: bash install.sh [--offline] [--uninstall] [--update] [--check] [--allow-all] [--help]"
  echo "  --offline     install tanpa animasi/cek jaringan (CI aman)"
  echo "  --uninstall   buang agent & doctrine (memori DIPERTAHANKAN)"
  echo "  --update      update dari DEV_BRAIN_UPDATE_URL (memori aman, https wajib SHA via DEV_BRAIN_UPDATE_SHA)"
  echo "  --check       cek kesehatan instalasi (tanpa menulis)"
  echo "  --allow-all   opt-in: permission allow semua (default granular ask). Bisa juga DEV_BRAIN_ALLOW_ALL=1"
  echo "  --yes         lewati konfirmasi lepas (untuk --uninstall non-interaktif)"
  echo "  --help        tampilkan bantuan ini"
}

# Cek kesehatan instalasi
check_install(){
  local BAD=0
  [ -f "$CFG/AGENTS.md" ] || { wrn "doctrine hilang: $CFG/AGENTS.md"; BAD=1; }
  [ -f "$CFG/opencode.json" ] || { wrn "config hilang: $CFG/opencode.json"; BAD=1; }
  grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null || wrn "opencode.json tanpa marker devbrain (bukan tulisan installer)"
  for d in agent command memory skills; do
    [ -d "$CFG/$d" ] || { wrn "folder hilang: $CFG/$d"; BAD=1; }
  done
  local n=$(find "$CFG/agent" "$CFG/skills" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
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
# https wajib SHA: DEV_BRAIN_UPDATE_SHA (sha256 tarball). file:// skip SHA (test lokal).
# UPDATE_URL dipin ke repo resmi bila tidak diawali file:// atau URL resmi.
OFFICIAL_PREFIX="https://raw.githubusercontent.com/nemoobc/agent-ai"
update(){
  local UPDATE_URL="${DEV_BRAIN_UPDATE_URL:-}"
  [ -n "$UPDATE_URL" ] || { wrn "DEV_BRAIN_UPDATE_URL kosong — update dibatalkan"; return 1; }
  case "$UPDATE_URL" in
    file://*|"$OFFICIAL_PREFIX"*) ;;
    *) wrn "UPDATE_URL tidak resmi — hanya $OFFICIAL_PREFIX atau file:// (test). Update dibatalkan"; return 1 ;;
  esac
  command -v curl >/dev/null 2>&1 || { wrn "curl tidak ada — update manual: git clone"; return 1; }
  local TMP; TMP=$(mktemp -d)
  if curl -fsSL --proto '=https,file' --tlsv1.2 --connect-timeout 5 --max-time 60 "$UPDATE_URL" -o "$TMP/kit.tgz"; then
    ok "unduh selesai"
  else
    wrn "unduh gagal — cek koneksi"; rm -rf "$TMP"; return 1
  fi
  case "$UPDATE_URL" in
    https://*)
      if [ -n "${DEV_BRAIN_UPDATE_SHA:-}" ]; then
        command -v sha256sum >/dev/null 2>&1 || { wrn "sha256sum tidak ada — SHA tak bisa diverifikasi, update dibatalkan"; rm -rf "$TMP"; return 1; }
        printf '%s  %s\n' "$DEV_BRAIN_UPDATE_SHA" "$TMP/kit.tgz" | sha256sum -c - >/dev/null 2>&1 \
          || { wrn "SHA mismatch — tarball ditolak, update dibatalkan"; rm -rf "$TMP"; return 1; }
        ok "SHA cocok"
      else
        wrn "DEV_BRAIN_UPDATE_SHA kosong — update https tanpa verifikasi DITOLAK"; rm -rf "$TMP"; return 1
      fi
      ;;
  esac
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
ALLOW_ALL=0
ALLOW_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --offline) OFFLINE=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --update) UPDATE=1; shift ;;
    --check) CHECK=1; shift ;;
    --allow-all) ALLOW_ALL=1; shift ;;
    --yes|-y) ALLOW_YES=1; shift ;;
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