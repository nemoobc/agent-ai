#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  UNINSTALL — DEV-BRAIN remover                                    ║
# ║  anti: agent • skill • command • doctrine • config               ║
# ║  aman: memory/ DIPERTAHANKAN • opencode.json user dipulihkan     ║
# ╚══════════════════════════════════════════════════════════════════╝
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/opencode"

# ════════════════════════════════════════════
#  WARNA / COLORS
# ════════════════════════════════════════════
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  pc(){ printf '\033[38;5;%sm%s\033[0m\n' "$1" "$2"; }
  bold(){ printf '\033[1;38;5;%sm%s\033[0m\n' "$1" "$2"; }
  dim(){ printf '\033[2;38;5;%sm%s\033[0m\n' "$1" "$2"; }
  pulse(){ printf '\033[1;38;5;%sm%s\033[0m\n' "$1" "$2"; }
  glow_line(){ printf '\033[1;38;5;%sm%s\033[0m' "$1" "$2"; }
else
  pc(){ printf '%s\n' "$2"; }
  bold(){ printf '%s\n' "$2"; }
  dim(){ printf '%s\n' "$2"; }
  pulse(){ printf '%s\n' "$2"; }
  glow_line(){ printf '%s' "$2"; }
fi
ok(){  pc 82  "  ✔ $1"; }
inf(){ pc 147 "  ▸ $1"; }
wrn(){ pc 214 "  ⚠ $1"; }
err(){ pc 196 "  ✖ $1"; }
div(){ dim 240 "  ──────────────────────────────────────────"; }

# ════════════════════════════════════════════
#  ANIMASI — append-only, CI-safe
# ════════════════════════════════════════════
ANIM="${ANIM:-1}"
_T0="$(date +%s 2>/dev/null || printf '%s' "${SECONDS:-0}")"
can_anim(){
  [ "${ANIM:-1}" -eq 1 ] 2>/dev/null || return 1
  [ -t 1 ] || return 1
  [ "${CI:-}" != "true" ] && [ "${CI:-}" != "1" ] || return 1
  [ "${NO_ANIM:-}" != "1" ] || return 1
  [ -z "${NO_COLOR:-}" ] || return 1
  [ "${TERM:-}" != "dumb" ] || return 1
  return 0
}
anim_on(){ can_anim; }
now(){ date +%s 2>/dev/null || printf '%s\n' "${SECONDS:-0}"; }
elapsed(){ printf '%s' "$(( $(now) - ${1:-0} ))"; }

ph(){
  local _m="${1:-}" _icon="${2:-◆}"
  printf '\n'
  if anim_on; then
    glow_line 141 "  $_icon"
    glow_line 213 "═══════════════════════════════════════════════"
    printf '\n'
    bold 213 "    $_m"
    glow_line 213 "  ══════════════════════════════════════════"
    glow_line 141 "$_icon"
    printf '\n'
  else
    bold 213 "  $_icon═══════════════════════════════════════════════"
    bold 213 "    $_m"
    bold 213 "  ══════════════════════════════════════════$_icon"
  fi
}
pdone(){
  local _d; _d="$(elapsed "${_T0:-0}")"
  ok "${1:-selesai} (${_d}s)"
}
dots(){
  local _m="${1:-...}" _n="${2:-3}" _i=1
  if anim_on; then
    printf '  ▸ %s' "${_m}"
    while [ "${_i}" -le "${_n}" ]; do printf '.'; sleep 0.15; _i=$((_i + 1)); done
    printf '\n'
  else
    inf "${_m}"
  fi
}
mode_strip(){
  if anim_on; then
    glow_line 240 '  [plan]  ────  [ dev ]  ────  [BUILD]'
    printf '\n'
  else
    pc 147 "  mode: uninstall"
  fi
}

# ── banner goodbye ──
goodbye_pulse(){
  local _bv="?" _ba="?" _bs="?" _bc="?"
  [ -f "$CFG/VERSION" ] && _bv="$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null || printf '?')"
  _ba="$(ls -1 "$CFG/agent/" 2>/dev/null | wc -l | tr -d ' ')"
  _bs="$(ls -1 "$CFG/skill/" 2>/dev/null | wc -l | tr -d ' ')"
  _bc="$(ls -1 "$CFG/command/" 2>/dev/null | wc -l | ' ')"
  if anim_on; then
    printf '\n'
    glow_line 213 '  ╭──────────────────────────────────────────────────────────╮'; printf '\n'; sleep 0.04
    glow_line 177 '  │                                                          │'; printf '\n'; sleep 0.03
    glow_line 196 "  │     🧠  DEV-BRAIN  v${_bv}  •  SHUTDOWN                │"; printf '\n'; sleep 0.04
    glow_line 177 '  │                                                          │'; printf '\n'; sleep 0.03
    glow_line 141 "  │     ◈ ${_ba} agents  ◈ ${_bs} skills  ◈ ${_bc} commands            │"; printf '\n'; sleep 0.04
    glow_line 213 '  ╰──────────────────────────────────────────────────────────╯'; printf '\n'; sleep 0.05
  else
    pulse 213 '  ╭──────────────────────────────────────────────────────────╮'
    pulse 196 "  │     🧠  DEV-BRAIN  v${_bv}  •  SHUTDOWN                │"
    pulse 141 "  │     ◈ ${_ba} agents  ◈ ${_bs} skills  ◈ ${_bc} commands            │"
    pulse 213 '  ╰──────────────────────────────────────────────────────────╯'
  fi
}

usage(){ cat <<'X'
Pemakaian:
  bash uninstall.sh          buang agent & doctrine (memori DIPERTAHANKAN)
  bash uninstall.sh --check  cek apa saja yang akan dihapus (tanpa menghapus)
  NO_ANIM=1 bash uninstall.sh   matikan animasi (CI/log aman)

Sama dengan: bash install.sh --uninstall
X
}

CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK=1; shift ;;
    --no-anim) ANIM=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) wrn "arg tak dikenal: $1 (diabaikan)"; shift ;;
  esac
done

# ════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════
goodbye_pulse
ph "UNINSTALL DEV-BRAIN"
mode_strip
div

if [ ! -d "$CFG" ]; then
  wrn "tidak ada instalasi DEV-BRAIN di $CFG — tidak ada yang dihapus"
  pdone "uninstall selesai (noop)"
  exit 0
fi

# hitung dulu (untuk laporan)
N_BEFORE=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHECK" -eq 1 ] && inf "MODE --check: daftar tanpa menghapus"; then :; fi

hapus(){
  local _target="$1" _label="$2"
  if [ -e "$_target" ]; then
    if [ "$CHECK" -eq 1 ]; then
      ok "$_label — ADA (akan dihapus)"
    else
      dots "hapus $_label" 2
      rm -rf "$_target" && ok "$_label dihapus" || err "$_label gagal dihapus"
    fi
  else
    inf "$_label — tidak ada (skip)"
  fi
}

hapus "$CFG/agent"   "agent (otak DEV + sub-agent)"
hapus "$CFG/skill"   "skill (62 direktori)"
hapus "$CFG/command" "command (/plan /build /verify ...)"
hapus "$CFG/docs"    "docs (USAGE + PLAYBOOKS)"
hapus "$CFG/AGENTS.md" "doctrine (AGENTS.md)"
hapus "$CFG/VERSION" "VERSION"

# ── opencode.json: pulihkan milik user, buang milik DEV-BRAIN ──
if [ "$CHECK" -eq 1 ]; then
  inf "opencode.json — diproses saat uninstall nyata (backup dipulihkan bila ada)"
else
  BAK=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  if [ -n "${BAK:-}" ]; then
    mv "$BAK" "$CFG/opencode.json" && ok "opencode.json dipulihkan dari backup" || err "pulihkan opencode.json gagal"
  elif [ -f "$CFG/opencode.json" ] && grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    rm -f "$CFG/opencode.json" && ok "opencode.json buatan DEV-BRAIN dihapus" || err "hapus opencode.json gagal"
  else
    inf "opencode.json milik user — DIPERTAHANKAN"
  fi
fi

echo
div
if [ -d "$CFG/memory" ]; then
  NM=$(ls -1 "$CFG/memory" 2>/dev/null | wc -l | tr -d ' ')
  wrn "folder memory/ DIPERTAHANKAN — $NM file ingatan kamu selamat"
else
  inf "tidak ada folder memory/ — tidak ada ingatan tersimpan"
fi
[ "$CHECK" -eq 0 ] && [ "${N_BEFORE:-0}" -gt 0 ] && ok "$N_BEFORE file otak dibersihkan"
div

if [ "$CHECK" -eq 1 ]; then
  pdone "cek selesai — jalankan tanpa --check untuk hapus nyata"
else
  printf '\n'
  if anim_on; then
    glow_line 196 '  ╔══════════════════════════════════════════════════════════╗'; printf '\n'; sleep 0.05
    glow_line 141 '  ║          🧠  DEV-BRAIN  —  OFFLINE                      ║'; printf '\n'; sleep 0.05
    glow_line 141 '  ║     terima kasih — semoga ketemu di install berikutnya  ║'; printf '\n'; sleep 0.05
    glow_line 196 '  ╚══════════════════════════════════════════════════════════╝'; printf '\n'; sleep 0.05
  else
    pulse 196 '  ╔══════════════════════════════════════════════════════════╗'
    pulse 141 '  ║          🧠  DEV-BRAIN  —  OFFLINE                      ║'
    pulse 141 '  ║     terima kasih — semoga ketemu di install berikutnya  ║'
    pulse 196 '  ╚══════════════════════════════════════════════════════════╝'
  fi
  inf "pinggirkan sisa: rm -rf $CFG (HATI-HATI: ikut menghapus memory/)"
  inf "pasang lagi: curl -fsSL https://raw.githubusercontent.com/nemoobc/agent-ai/master/install.sh | bash"
  pdone "uninstall selesai — DEV-BRAIN dilepas"
fi
exit 0
