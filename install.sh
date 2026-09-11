#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║                                                                  ║
# ║     █████╗ ██╗   ██╗████████╗ ██████╗  █████╗  ██████╗ ██████╗  ║
# ║    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝██╔══██╗ ║
# ║    ███████║██║   ██║   ██║   ██║   ██║███████║██║     ██████╔╝ ║
# ║    ██╔══██║██║   ██║   ██║   ██║   ██║██╔══██║██║     ██╔══██╗ ║
# ║    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║  ██║╚██████╗██║  ██║ ║
# ║    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ║
# ║                                                                  ║
# ║   agent-ai full-agent installer — caveman mode • permanen       ║
# ║   auto: think → build → test → audit → fix → learn              ║
# ║                                                                  ║
# ╚══════════════════════════════════════════════════════════════════╝
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

sym(){ [ -z "${NO_COLOR:-}" ] && [ -t 1 ]; }

ok(){  pc 82  "  ✔ $1"; }
inf(){ pc 147 "  ▸ $1"; }
wrn(){ pc 214 "  ⚠ $1"; }
err(){ pc 196 "  ✖ $1"; }
key(){ pc 220 "  $1"; }
div(){ dim 240 "  ──────────────────────────────────────────"; }

# ════════════════════════════════════════════
#  ANIMASI — append-only, CI-safe
# ════════════════════════════════════════════
ANIM="${ANIM:-1}"
_ANIM_T0="$(date +%s 2>/dev/null || printf '%s' "${SECONDS:-0}")"
_SPIN_PID=""
_GP=0; _GPMAX=0

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

elapsed(){
  local _s="${1:-0}" _e="0"
  _e="$(now)"
  case "${_s}" in ''|*[!0-9]*) _s=0 ;; esac
  case "${_e}" in ''|*[!0-9]*) _e="${_s}" ;; esac
  printf '%s' "$((_e - _s))"
}

# ── phase header + glow + timer ──
_ph_t0=""
ph(){
  local _m="${1:-}"
  local _icon="${2:-◆}"
  printf '\n'
  if anim_on; then
    glow_line 141 "  $_icon"
    glow_line 213 "═══════════════════════════════════════════════"
    printf '\n'
    bold 213 "    $_m"
    glow_line 213 "  ════════════════════════════════════════════"
    glow_line 141 "$_icon"
    printf '\n'
  else
    bold 213 "  $_icon═══════════════════════════════════════════════"
    bold 213 "    $_m"
    bold 213 "  ════════════════════════════════════════════$_icon"
  fi
  _ph_t0="$(now)"
}

# ── phase done ──
pdone(){
  local _m="${1:-selesai}" _d="0"
  if [ -n "${_ph_t0:-}" ]; then _d="$(elapsed "${_ph_t0}")"; fi
  ok "${_m} (${_d}s)"
}

# ── animated dots ──
dots(){
  local _m="${1:-...}" _n="${2:-3}" _i=1
  if anim_on; then
    printf '  ▸ %s' "${_m}"
    while [ "${_i}" -le "${_n}" ]; do printf '.'; sleep 0.2; _i=$((_i + 1)); done
    printf '\n'
  else
    inf "${_m}"
  fi
}

# ── typewriter effect ──
typewriter(){
  local _msg="${1:-}" _delay="${2:-0.03}" _i=0 _len
  if ! anim_on; then
    inf "${_msg}"
    return
  fi
  _len=${#_msg}
  printf '  '
  while [ "${_i}" -lt "${_len}" ]; do
    printf '%s' "${_msg:$_i:1}"
    sleep "${_delay}"
    _i=$((_i + 1))
  done
  printf '\n'
}

# ── glow animation for borders ──
glow(){
  local _color="${1:-141}" _text="${2:-}"
  if anim_on; then
    glow_line "${_color}" "${_text}"
  else
    printf '%s' "${_text}"
  fi
}

# ── spinner start / stop ──
spin_start(){
  local _m="${1:-...}" _n="${2:-1}" _i=1
  if anim_on; then
    printf '  ▸ %s' "${_m}"
    while [ "${_i}" -le "${_n}" ]; do printf '.'; sleep 0.2; _i=$((_i + 1)); done
  else
    inf "${_m}"
  fi
  _SPIN_PID="started"
}
spin_stop(){
  local _pid="${1:-${_SPIN_PID:-}}" _m="${2:-}" _i=1
  if [ -n "${_pid}" ] && anim_on; then
    while [ "${_i}" -le 3 ]; do printf '.'; sleep 0.2; _i=$((_i + 1)); done
    printf '\n'
  elif [ -n "${_pid}" ]; then
    printf '\n'
  fi
  _SPIN_PID=""
  if [ -n "${_m}" ]; then ok "${_m}"; fi
}

# ── ok bar (step progress) ──
okbar(){
  local _i="${1:-0}" _n="${2:-1}" lbl="${3:-}" _fill=0 _k=0 _bar=""
  lbl="${lbl:0:40}"
  case "${_i}" in ''|*[!0-9]*) _i=0 ;; esac
  case "${_n}" in ''|*[!0-9]*) _n=1 ;; esac
  [ "${_n}" -le 0 ] 2>/dev/null && _n=1
  _fill=$((_i * 24 / _n)); [ "${_fill}" -gt 24 ] && _fill=24; [ "${_fill}" -lt 0 ] && _fill=0
  _k=0; while [ "${_k}" -lt "${_fill}" ]; do _bar="${_bar}█"; _k=$((_k + 1)); done
  _k=0; while [ "${_k}" -lt $((24 - _fill)) ]; do _bar="${_bar}░"; _k=$((_k + 1)); done
  printf '  ✔ [%s] %s/%s  %s\n' "${_bar}" "${_i}" "${_n}" "${lbl}"
}

# ── err bar ──
errbar(){
  local _i="${1:-0}" _n="${2:-1}" lbl="${3:-}" _fill=0 _k=0 _bar=""
  lbl="${lbl:0:40}"
  case "${_i}" in ''|*[!0-9]*) _i=0 ;; esac
  case "${_n}" in ''|*[!0-9]*) _n=1 ;; esac
  [ "${_n}" -le 0 ] 2>/dev/null && _n=1
  _fill=$((_i * 24 / _n)); [ "${_fill}" -gt 24 ] && _fill=24; [ "${_fill}" -lt 0 ] && _fill=0
  _k=0; while [ "${_k}" -lt "${_fill}" ]; do _bar="${_bar}█"; _k=$((_k + 1)); done
  _k=0; while [ "${_k}" -lt $((24 - _fill)) ]; do _bar="${_bar}░"; _k=$((_k + 1)); done
  printf '  ✖ [%s] %s/%s  %s  GAGAL\n' "${_bar}" "${_i}" "${_n}" "${lbl}"
}

# ── global progress bar ──
pbar(){
  local _c="${1:-0}" _t="${2:-0}" _lbl="${3:-}"
  case "${_c}" in ''|*[!0-9]*) _c=0 ;; esac
  case "${_t}" in ''|*[!0-9]*) _t=0 ;; esac
  [ "${_t}" -le 0 ] 2>/dev/null && _t=1
  local _pct=0 _fill=0 _k=0 _bar="" _el="0" _eta="—"
  _pct=$((_c * 100 / _t))
  _fill=$((_c * 30 / _t)); [ "${_fill}" -gt 30 ] && _fill=30; [ "${_fill}" -lt 0 ] && _fill=0
  _k=0; while [ "${_k}" -lt "${_fill}" ]; do _bar="${_bar}█"; _k=$((_k + 1)); done
  _k=0; while [ "${_k}" -lt $((30 - _fill)) ]; do _bar="${_bar}░"; _k=$((_k + 1)); done
  [ -n "${_ANIM_T0:-}" ] && _el="$(elapsed "${_ANIM_T0}")"
  if [ -n "${_ph_t0:-}" ]; then
    local _pe="$(elapsed "${_ph_t0}")"
    [ "${_c}" -gt 0 ] 2>/dev/null && [ "${_pe}" -gt 0 ] 2>/dev/null && _eta=$(( (_pe * (_t - _c)) / _c ))
  fi
  if [ -n "${_lbl}" ]; then
    printf '  ▏[%s] %3d%%  %s/%s  ⏱ %ss  ETA %ss  %s\n' "${_bar}" "${_pct}" "${_c}" "${_t}" "${_el}" "${_eta}" "${_lbl}"
  else
    printf '  ▏[%s] %3d%%  %s/%s  ⏱ %ss  ETA %ss\n' "${_bar}" "${_pct}" "${_c}" "${_t}" "${_el}" "${_eta}"
  fi
}

# ── brain pulse — neural style reveal (dinamis VERSION + ls, append-only) ──
# catatan: tanpa emoji di dalam box — lebar emoji beda-beda per terminal = border miring
brain_pulse(){
  local _bv="?" _ba="?" _bs="?" _bc="?"
  [ -f "$SCRIPT_DIR/VERSION" ] && _bv="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || printf '?')"
  [ -n "${_bv:-}" ] || _bv="?"
  _ba="$(ls -1 "$SCRIPT_DIR/agents/" 2>/dev/null | wc -l | tr -d ' ')"
  _bs="$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')"
  _bc="$(ls -1 "$SCRIPT_DIR/command/" 2>/dev/null | wc -l | tr -d ' ')"
  [ -n "${_ba:-}" ] || _ba="?"; [ -n "${_bs:-}" ] || _bs="?"; [ -n "${_bc:-}" ] || _bc="?"
  if anim_on; then
    printf '\n'
    glow_line 213 '  ╭──────────────────────────────────────────────────────────╮'; printf '\n'; sleep 0.04
    glow_line 177 '  │                                                          │'; printf '\n'; sleep 0.02
    glow_line 177 "  │      ◈  D E V - B R A I N   v${_bv}  —  ONLINE           │"; printf '\n'; sleep 0.04
    glow_line 177 '  │                                                          │'; printf '\n'; sleep 0.02
    glow_line 141 "  │   ${_ba} agents   ${_bs} skills   ${_bc} commands   all-rounder max   │"; printf '\n'; sleep 0.04
    glow_line 141 '  │                                                          │'; printf '\n'; sleep 0.02
    glow_line 213 '  ╰──────────────────────────────────────────────────────────╯'; printf '\n'; sleep 0.04
  else
    pulse 213 '  ╭──────────────────────────────────────────────────────────╮'
    pulse 177 "  │      ◈  D E V - B R A I N   v${_bv}  —  ONLINE           │"
    pulse 141 "  │   ${_ba} agents   ${_bs} skills   ${_bc} commands   all-rounder max   │"
    pulse 213 '  ╰──────────────────────────────────────────────────────────╯'
  fi
}

# ── logo reveal — ASCII art muncul baris demi baris (CI-safe fallback) ──
logo_reveal(){
  local _delay="${1:-0.05}"
  if anim_on; then
    printf '\n'
    glow_line 213 '  █████╗ ██████╗  ██████╗ ██╗   ██╗███████╗   ███████╗██╗   ██╗███████╗'; printf '\n'; sleep "$_delay"
    glow_line 213 '  ██╔══██╗██╔══██╗██╔════╝ ██║   ██║██╔════╝   ██╔════╝╚██╗ ██╔╝██╔════╝'; printf '\n'; sleep "$_delay"
    glow_line 213 '  ███████║██████╔╝██║  ███╗██║   ██║███████╗   █████╗   ╚████╔╝ █████╗'; printf '\n'; sleep "$_delay"
    glow_line 213 '  ██╔══██║██╔══██╗██║   ██║██║   ██║╚════██║   ██╔══╝    ╚██╔╝  ██╔══╝'; printf '\n'; sleep "$_delay"
    glow_line 213 '  ██║  ██║██║  ██║╚██████╔╝╚██████╔╝███████║██╗██║        ██║   ███████╗'; printf '\n'; sleep "$_delay"
    glow_line 213 '  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝╚═╝        ╚═╝   ╚══════╝'; printf '\n'; sleep "$_delay"
  else
    pc 213 '  █████╗ ██████╗  ██████╗ ██╗   ██╗███████╗   ███████╗██╗   ██╗███████╗'
    pc 213 '  ██╔══██╗██╔══██╗██╔════╝ ██║   ██║██╔════╝   ██╔════╝╚██╗ ██╔╝██╔════╝'
    pc 213 '  ███████║██████╔╝██║  ███╗██║   ██║███████╗   █████╗   ╚████╔╝ █████╗'
    pc 213 '  ██╔══██║██╔══██╗██║   ██║██║   ██║╚════██║   ██╔══╝    ╚██╔╝  ██╔══╝'
    pc 213 '  ██║  ██║██║  ██║╚██████╔╝╚██████╔╝███████║██╗██║        ██║   ███████╗'
    pc 213 '  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝╚═╝        ╚═╝   ╚══════╝'
  fi
}

# ── mode strip: PLAN → DEV → BUILD (+ship composite) ──
# warna konsisten: PLAN [82] biru-hijau, DEV [45] cyan, BUILD [213] magenta
# non-aktif dim [240], panah ───▶ glow ikut mode aktif — append-only, CI-safe
mode_strip(){
  local _active="${1:-dev}"
  if anim_on; then
    case "$_active" in
      plan)
        glow_line 82  '  [PLAN]'
        glow_line 82  ' ───▶ '
        glow_line 240 '[ dev ]'
        glow_line 240 ' ──── '
        glow_line 240 '[BUILD]'
        printf '\n'
        ;;
      dev)
        glow_line 240 '  [plan]'
        glow_line 45  ' ───▶ '
        glow_line 45  '[ DEV ]'
        glow_line 45  ' ───▶ '
        glow_line 240 '[BUILD]'
        printf '\n'
        ;;
      build)
        glow_line 240 '  [plan]'
        glow_line 240 ' ──── '
        glow_line 240 '[ dev ]'
        glow_line 213 ' ───▶ '
        glow_line 213 '[BUILD]'
        printf '\n'
        ;;
      ship)
        glow_line 82  '  [PLAN]'
        glow_line 45  ' ───▶ '
        glow_line 45  '[ DEV ]'
        glow_line 213 ' ───▶ '
        glow_line 213 '[BUILD]'
        printf '\n'
        ;;
      *)
        dim 240 '  [plan]  ────  [ dev ]  ────  [BUILD]'
        ;;
    esac
  else
    pc 147 "  mode: $_active"
  fi
}

# ── glow step: satu baris glow append-only (CI-safe, tanpa \r, tanpa timpa) ──
glow_step(){
  local _color="${1:-141}" _text="${2:-}" _sleep="${3:-0.15}"
  case "${_sleep}" in ''|*[!0-9.]*) _sleep=0.15 ;; esac
  if ! anim_on; then
    printf '%s\n' "${_text}"
    return
  fi
  glow_line "${_color}" "${_text}"
  printf '\n'
  sleep "${_sleep}"
}

# ── mode scene: animasi 3-mode berurutan plan→dev→build (append-only) ──
mode_scene(){
  if ! anim_on; then
    pc 147 "  mode: plan ──▶ dev ──▶ build"
    return
  fi
  mode_strip "plan"
  sleep 0.15
  mode_strip "dev"
  sleep 0.15
  mode_strip "build"
  sleep 0.15
}

# ── progress dots animation (append-only, tanpa \r, tanpa timpa — v8.2.0) ──
progress_dots(){
  local _label="${1:-}" _count="${2:-3}" _i=1
  case "${_count}" in ''|*[!0-9]*) _count=3 ;; esac
  if ! anim_on; then
    inf "${_label}"
    return
  fi
  printf '  ▸ %s ' "${_label}"
  while [ "${_i}" -le "${_count}" ]; do printf '●'; sleep 0.25; _i=$((_i + 1)); done
  printf '\n'
}

# ── banner reveal — full animated boot sequence ──
banner_reveal(){
  logo_reveal 0.04
  brain_pulse
  local _ba _bs _bc
  _bs="$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')"
  _bc="$(ls -1 "$SCRIPT_DIR/command/" 2>/dev/null | wc -l | tr -d ' ')"
  _ba="$(ls -1 "$SCRIPT_DIR/agents/" 2>/dev/null | wc -l | tr -d ' ')"

  ph "BOOT DEV-BRAIN"
  mode_strip "dev"
  div

  if anim_on; then
    mode_scene
    dots "memuat otak" 6
    dots "memuat agent" 6
    dots "memuat skill" 6
    dots "memuat command" 6
    dots "memuat doctrine" 4
    dots "mengelas route" 4
    echo
    typewriter "   otak utama: DEV • caveman ULTRA • ultronomatis"
    typewriter "   otak utama: DEV • plan ──▶ dev ──▶ build"
    pc 147 "   ${_ba:-?} agent  /  ${_bs:-?} skill  /  ${_bc:-?} command"
    sleep 0.04
    if [ -f "$SCRIPT_DIR/VERSION" ]; then
      pc 45 "   versi: $(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION")"
      sleep 0.04
    fi
    pc 45 "   auto test ✓ audit ✓ fix ✓ memori persisten ✓"
  else
    inf "memuat otak… memuat agent… memuat skill… memuat command…"
    bold 45 "   otak utama: DEV • caveman ULTRA • ultronomatis"
    bold 45 "   otak utama: DEV • plan ──▶ dev ──▶ build"
    pc 147 "   ${_ba:-?} agent  /  ${_bs:-?} skill  /  ${_bc:-?} command"
    if [ -f "$SCRIPT_DIR/VERSION" ]; then
      pc 45 "   versi: $(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION")"
    fi
    pc 45 "   auto test ✓ audit ✓ fix ✓ memori persisten ✓"
  fi
  echo
}

# ── celebrate — completion animation ──
celebrate(){
  local _dur="${1:-0}" _files="${2:-0}" _v="?"
  [ -f "$SCRIPT_DIR/VERSION" ] && _v="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || printf '?')"
  if anim_on; then
    echo
    glow_line 141 '  ╔══════════════════════════════════════════════════════════╗'; printf '\n'; sleep 0.05
    glow_line 82  '  │                                                          │'; printf '\n'; sleep 0.03
    glow_line 82  '  │          ◈  DEV-BRAIN  v'"${_v}"'  —  ONLINE                  │'; printf '\n'; sleep 0.05
    glow_line 82  '  │                                                          │'; printf '\n'; sleep 0.03
    glow_line 147 '  │    think → build → test → audit → fix → learn            │'; printf '\n'; sleep 0.04
    glow_line 147 '  │    plan ──▶ dev ──▶ build   •   anti-bentrok ✓          │'; printf '\n'; sleep 0.03
    glow_line 82  '  │                                                          │'; printf '\n'; sleep 0.03
    glow_line 141 "  ╚══════════════════════════════════════════════════════════╝"; printf '\n'; sleep 0.06
    # stars animation (append-only, tanpa \r)
    glow_line 220 '  ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦'; printf '\n'; sleep 0.08
    glow_line 220 "  INSTALL COMPLETE — ${_files} file otak — ${_dur}s — v${_v}"; printf '\n'
    glow_line 220 '  ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦'; printf '\n'; sleep 0.1
  else
    echo
    pulse 213 '  ╔══════════════════════════════════════════════════════════╗'
    pulse 82  '  │          ◈  DEV-BRAIN  v'"${_v}"'  —  ONLINE                  │'
    pulse 147 '  │    think → build → test → audit → fix → learn            │'
    pulse 147 '  │    plan ──▶ dev ──▶ build   •   anti-bentrok ✓          │'
    pulse 213 '  ╚══════════════════════════════════════════════════════════╝'
    echo
    ok "INSTALL COMPLETE — ${_files} file otak — ${_dur}s — v${_v}"
  fi
}

# ── cleanup trap ──
anim_cleanup(){
  _SPIN_PID=""
  if [ -n "${TMP:-}" ] && [ -d "${TMP:-}" ]; then rm -rf "${TMP:-}" 2>/dev/null || true; fi
  return 0
}
trap 'anim_cleanup' INT TERM EXIT

# ════════════════════════════════════════════
#  KONFIGURASI
# ════════════════════════════════════════════
CFG="$HOME/.config/opencode"
IS_TERMUX=0
[ -n "${TERMUX_VERSION:-}" ] && IS_TERMUX=1
[ -d /data/data/com.termux ] && IS_TERMUX=1

# ════════════════════════════════════════════
#  USAGE
# ════════════════════════════════════════════
usage(){ cat <<'X'
╔══════════════════════════════════════════════════════════════╗
║  AGENT-AI / DEV-BRAIN — installer                            ║
╚══════════════════════════════════════════════════════════════╝

  INSTAL
    bash install.sh                 install global (~/.config/opencode)
    bash install.sh --project DIR   sekalian pasang ke project (DIR/.opencode)
    bash install.sh --hook          pasang pre-commit hook git-guard
    bash install.sh --lint          lint-kit + self-test setelah install

  KESEHATAN & UPDATE
    bash install.sh --check         cek kesehatan instalasi (tanpa menulis)
    bash install.sh --update        update dari GitHub (memori aman)
    bash install.sh --offline       tanpa cek jaringan (CI aman)

  LAIN-LAIN
    bash install.sh --uninstall     buang agent & doctrine (memori DIPERTAHANKAN)
    bash uninstall.sh               uninstall standalone (tampilan penuh)
    bash install.sh --version       tampilkan versi
    bash install.sh --no-anim       matikan animasi (CI/log aman)
    env DEV_BRAIN_UPDATE_URL=...    override URL update (untuk tes/file://)
    env DEV_BRAIN_UPDATE_SHA256=... checksum wajib untuk update jaringan

  DI DALAM OPENCODE (tanpa install global di project ini)
    /bootstrap                      pasang DEV-BRAIN ke project ini (.opencode/)
    /allow-all                      buka semua izin (backup otomatis)
X
}

# ════════════════════════════════════════════
#  FLAG PARSING
# ════════════════════════════════════════════
PROJECT=""; UNINSTALL=0; CHECK=0; UPDATE=0; SHOWVER=0; OFFLINE=0; HOOK=0; LINT=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) [ $# -ge 2 ] || { err "--project butuh path folder"; exit 1; }; PROJECT="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    --check) CHECK=1; shift ;;
    --update) UPDATE=1; shift ;;
    --version) SHOWVER=1; shift ;;
    --offline) OFFLINE=1; shift ;;
    --no-anim) ANIM=0; shift ;;
    --hook) HOOK=1; shift ;;
    --lint) LINT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) wrn "arg tak dikenal: $1 (diabaikan)"; shift ;;
  esac
done

# ════════════════════════════════════════════
#  UPDATE
# ════════════════════════════════════════════
REPO="nemoobc/agent-ai"
UPDATE_URL="${DEV_BRAIN_UPDATE_URL:-https://codeload.github.com/$REPO/tar.gz/refs/heads/master}"
UPDATE_SHA256="${DEV_BRAIN_UPDATE_SHA256:-}"

update(){
  ph "UPDATE DEV-BRAIN"
  mode_strip "build"
  div
  command -v curl >/dev/null 2>&1 || { err "curl tidak ada — update manual: git clone $REPO"; exit 1; }
  TMP=$(mktemp -d)
  spin_start "unduh master terbaru…" 5
  _SPID="${_SPIN_PID:-}"
  if curl -fsSL --connect-timeout 5 --max-time 60 "$UPDATE_URL" -o "$TMP/kit.tgz"; then
    spin_stop "${_SPID:-}" "unduh selesai"
  else
    spin_stop "${_SPID:-}" ""
    err "unduh gagal — cek koneksi"; rm -rf "$TMP"; exit 1
  fi
  if [[ "$UPDATE_URL" != file://* ]]; then
    if ! command -v sha256sum >/dev/null 2>&1 || [ -z "$UPDATE_SHA256" ]; then
      err "update jaringan wajib: DEV_BRAIN_UPDATE_SHA256=<sha256 tepercaya>"
      rm -rf "$TMP"; exit 1
    fi
    ACTUAL_SHA256="$(sha256sum "$TMP/kit.tgz" | awk '{print $1}')"
    if [ "$ACTUAL_SHA256" != "$UPDATE_SHA256" ]; then
      err "checksum update tidak cocok — instalasi dibatalkan"
      rm -rf "$TMP"; exit 1
    fi
    ok "checksum update terverifikasi"
  fi
  dots "ekstrak paket…"
  tar -xzf "$TMP/kit.tgz" -C "$TMP" || { err "ekstrak gagal"; rm -rf "$TMP"; exit 1; }
  SRC=$(find "$TMP" -maxdepth 1 -type d -name 'agent-ai*' | head -1)
  [ -f "$SRC/install.sh" ] || { err "paket tidak valid"; rm -rf "$TMP"; exit 1; }
  NEWV=$(tr -d '[:space:]' < "$SRC/VERSION" 2>/dev/null)
  OLDV=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  inf "terpasang: ${OLDV:-?} → tersedia: ${NEWV:-?}"
  OLDER=$(printf '%s\n%s\n' "${OLDV:-0}" "${NEWV:-0}" | sort -V | head -1)
  if [ -n "$OLDV" ] && [ "$OLDER" != "$OLDV" ]; then
    ok "remote ($NEWV) tidak lebih baru dari terpasang ($OLDV) — skip"
    rm -rf "$TMP"; exit 0
  fi
  if [ "$NEWV" = "$OLDV" ]; then ok "sudah versi terbaru"; rm -rf "$TMP"; exit 0; fi
  if bash "$SRC/install.sh" --offline; then ok "update ke $NEWV selesai — memori tetap aman"; else err "update gagal di tengah — instalasi lama utuh"; fi
  rm -rf "$TMP"
  exit 0
}

# ── cek versi remote (non-blokir) ──
check_remote_version(){
  [ "$OFFLINE" -eq 1 ] && return 0
  command -v curl >/dev/null 2>&1 || return 0
  dots "cek versi remote…" 5
  REMOTE=$(curl -fsSL --connect-timeout 2 --max-time 3 "https://raw.githubusercontent.com/$REPO/master/VERSION" 2>/dev/null | tr -d '[:space:]')
  [ -n "$REMOTE" ] || return 0
  LOCALV=$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null)
  if [ -n "$LOCALV" ] && [ "$REMOTE" != "$LOCALV" ]; then
    wrn "versi baru tersedia: $REMOTE (lokal $LOCALV) — update: bash install.sh --update"
  fi
}

# ════════════════════════════════════════════
#  UNINSTALL
# ════════════════════════════════════════════
uninstall(){
  ph "UNINSTALL DEV-BRAIN"
  mode_strip ""
  div
  dots "menghitung file otak" 2
  N_BEFORE=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${N_BEFORE:-0}" -gt 0 ] && inf "$N_BEFORE file otak ditemukan — mulai membersihkan" || wrn "tidak ada file otak terpasang"
  dots "menghapus agent" 3
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command" "$CFG/docs"
  rm -f "$CFG/AGENTS.md" "$CFG/VERSION"
  BAK=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  if [ -n "${BAK:-}" ]; then mv "$BAK" "$CFG/opencode.json"; ok "opencode.json dipulihkan dari backup"
  elif [ -f "$CFG/opencode.json" ] && grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    rm -f "$CFG/opencode.json"; ok "opencode.json buatan DEV-BRAIN dihapus"
  fi
  if [ -d "$CFG/memory" ]; then
    NM=$(ls -1 "$CFG/memory" 2>/dev/null | wc -l | tr -d ' ')
    wrn "folder memory/ DIPERTAHANKAN — $NM file ingatan kamu selamat"
  fi
  [ "${N_BEFORE:-0}" -gt 0 ] && ok "$N_BEFORE file otak dibersihkan"
  inf "pasang lagi: bash install.sh  •  alternatif: bash uninstall.sh (standalone)"
  ok "uninstall selesai — DEV-BRAIN dilepas"
  exit 0
}

# ════════════════════════════════════════════
#  WRITE BRAIN — install to ~/.config/opencode
# ════════════════════════════════════════════
write_brain(){
  ph "TULIS OTAK → ~/.config/opencode"
  mode_strip "plan"
  div
  dots "menyiapkan otak" 3

  # prune instalasi lama
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command"
  mkdir -p "$CFG/agent" "$CFG/command" "$CFG/memory" "$CFG/skill"

  # backup config lama (bukan tulisan DEV-BRAIN)
  if [ -f "$CFG/opencode.json" ] && ! grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    cp "$CFG/opencode.json" "$CFG/opencode.json.bak.$(date +%s)"
  fi

  # opencode.json — izin granular: allow / ask / deny
  cat > "$CFG/opencode.json" <<'OPencodeEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "devbrain": true,
  "permission": {
    "edit": "allow",
    "write": "allow",
    "webfetch": "allow",
    "bash": {
      "*": "ask",
      "ls*": "allow", "ll*": "allow", "la*": "allow", "tree*": "allow",
      "file*": "allow", "stat*": "allow", "readlink*": "allow", "basename*": "allow", "dirname*": "allow",
      "cat*": "allow", "head*": "allow", "tail*": "allow", "less*": "allow", "more*": "allow",
      "nl*": "allow", "od*": "allow", "xxd*": "allow", "hexdump*": "allow", "strings*": "allow",
      "find*": "allow", "locate*": "allow",
      "grep*": "allow", "rg*": "allow", "egrep*": "allow", "fgrep*": "allow", "ag*": "allow", "ack*": "allow",
      "which*": "allow", "whereis*": "allow", "type*": "allow", "command*": "allow", "hash*": "allow",
      "wc*": "allow", "sort*": "allow", "uniq*": "allow", "diff*": "allow", "comm*": "allow", "cmp*": "allow",
      "col*": "allow", "column*": "allow", "fmt*": "allow", "fold*": "allow", "pr*": "allow",
      "expand*": "allow", "unexpand*": "allow",
      "whoami*": "allow", "id*": "allow", "hostname*": "allow", "uname*": "allow", "uptime*": "allow",
      "date*": "allow", "cal*": "allow", "df*": "allow", "du*": "allow", "free*": "allow", "vmstat*": "allow",
      "lscpu*": "allow", "lsblk*": "allow", "lsusb*": "allow", "lspci*": "allow", "lsmod*": "allow",
      "locale*": "allow", "env*": "allow", "printenv*": "allow", "set*": "allow",
      "echo*": "allow", "printf*": "allow", "pwd*": "allow", "test*": "allow", "true*": "allow", "false*": "allow",
      "git status*": "allow", "git log*": "allow", "git diff*": "allow", "git branch*": "allow",
      "git remote*": "allow", "git tag*": "allow", "git show*": "allow", "git blame*": "allow",
      "git reflog*": "allow", "git describe*": "allow", "git rev-parse*": "allow", "git rev-list*": "allow",
      "git shortlog*": "allow", "git count-objects*": "allow", "git fsck*": "allow",
      "git add*": "allow", "git commit*": "allow", "git pull*": "allow",
      "git clone*": "allow", "git checkout*": "allow", "git switch*": "allow", "git stash*": "allow",
      "git merge*": "allow", "git fetch*": "allow", "git revert*": "allow", "git cherry-pick*": "allow",
      "git reset*": "allow", "git rebase*": "allow", "git branch -m*": "allow", "git branch -d*": "allow",
      "git remote add*": "allow", "git remote set-url*": "allow", "git remote rename*": "allow",
      "git remote remove*": "allow", "git config*": "allow", "git archive*": "allow",
      "git clean*": "allow", "git restore*": "allow",
      "mkdir*": "allow", "cp*": "allow", "mv*": "allow", "touch*": "allow", "ln*": "allow",
      "rmdir*": "allow", "install*": "allow",
      "sed*": "allow", "awk*": "allow", "tr*": "allow", "cut*": "allow", "paste*": "allow",
      "join*": "allow", "tee*": "allow", "xargs*": "allow", "jq*": "allow", "yq*": "allow",
      "cd*": "allow",
      "export*": "allow", "unset*": "allow", "alias*": "allow", "unalias*": "allow",
      "history*": "allow", "jobs*": "allow", "bg*": "allow", "fg*": "allow", "wait*": "allow",
      "shopt*": "allow", "readonly*": "allow", "declare*": "allow", "local*": "allow", "typeset*": "allow",
      "node*": "allow", "npm*": "allow", "npx*": "allow", "yarn*": "allow", "pnpm*": "allow",
      "bun*": "allow", "deno*": "allow", "tsc*": "allow", "ts-node*": "allow", "tsx*": "allow",
      "eslint*": "allow", "prettier*": "allow", "stylelint*": "allow",
      "webpack*": "allow", "vite*": "allow", "esbuild*": "allow", "rollup*": "allow",
      "parcel*": "allow", "snowpack*": "allow", "turbo*": "allow", "lerna*": "allow", "nx*": "allow",
      "jest*": "allow", "vitest*": "allow", "mocha*": "allow", "chai*": "allow",
      "cypress*": "allow", "playwright*": "allow", "storybook*": "allow",
      "babel*": "allow", "postcss*": "allow", "tailwindcss*": "allow", "sass*": "allow",
      "python*": "allow", "python3*": "allow", "pip*": "allow", "pip3*": "allow",
      "poetry*": "allow", "pipenv*": "allow", "pytest*": "allow", "unittest*": "allow",
      "black*": "allow", "flake8*": "allow", "mypy*": "allow", "ruff*": "allow", "pyright*": "allow",
      "isort*": "allow", "bandit*": "allow", "safety*": "allow", "tox*": "allow", "pre-commit*": "allow",
      "ipython*": "allow", "jupyter*": "allow", "notebook*": "allow",
      "java*": "allow", "javac*": "allow", "jar*": "allow", "keytool*": "allow",
      "jdeps*": "allow", "jmod*": "allow", "jlink*": "allow", "jshell*": "allow",
      "gradle*": "allow", "gradlew*": "allow", "mvn*": "allow", "ant*": "allow",
      "kotlin*": "allow", "kotlinc*": "allow", "scala*": "allow", "scalac*": "allow", "groovy*": "allow",
      "cargo*": "allow", "rustc*": "allow", "rustup*": "allow", "clippy*": "allow", "rustfmt*": "allow",
      "go*": "allow", "gofmt*": "allow", "goimports*": "allow", "golint*": "allow", "govet*": "allow", "staticcheck*": "allow",
      "gcc*": "allow", "g++*": "allow", "clang*": "allow", "clang++*": "allow",
      "make*": "allow", "cmake*": "allow", "ninja*": "allow",
      "autoconf*": "allow", "automake*": "allow", "libtool*": "allow", "pkg-config*": "allow", "pkgconf*": "allow",
      "gdb*": "allow", "lldb*": "allow", "valgrind*": "allow", "strace*": "allow", "ltrace*": "allow",
      "ruby*": "allow", "gem*": "allow", "bundle*": "allow", "bundler*": "allow",
      "rails*": "allow", "rake*": "allow", "rspec*": "allow", "rubocop*": "allow",
      "php*": "allow", "composer*": "allow", "phpunit*": "allow", "psalm*": "allow", "phpstan*": "allow",
      "flutter*": "allow", "dart*": "allow", "adb*": "allow", "fastboot*": "allow",
      "xcodebuild*": "allow", "xcode-select*": "allow", "pod*": "allow", "carthage*": "allow",
      "react-native*": "allow", "expo*": "allow", "eas*": "allow",
      "bash*": "allow", "sh*": "allow", "zsh*": "allow", "fish*": "allow",
      "shellcheck*": "allow", "shfmt*": "allow",
      "dotnet*": "allow", "nuget*": "allow", "mono*": "allow",
      "ghc*": "allow", "cabal*": "allow", "stack*": "allow",
      "lua*": "allow", "luarocks*": "allow",
      "perl*": "allow", "cpan*": "allow", "cpanm*": "allow",
      "swift*": "allow", "swiftc*": "allow", "swift-package*": "allow",
      "ps*": "allow", "top*": "allow", "htop*": "allow", "atop*": "allow",
      "kill*": "allow", "killall*": "allow", "pkill*": "allow", "pgrep*": "allow",
      "nice*": "allow", "renice*": "allow", "nohup*": "allow", "disown*": "allow",
      "timeout*": "allow", "time*": "allow", "watch*": "allow",
      "apt install*": "allow", "apt-get install*": "allow", "apt update*": "allow", "apt-get update*": "allow",
      "apt upgrade*": "allow", "apt-get upgrade*": "allow",
      "pkg install*": "allow", "pkg update*": "allow", "pkg upgrade*": "allow",
      "brew install*": "allow", "brew update*": "allow", "brew upgrade*": "allow", "brew link*": "allow",
      "conda install*": "allow", "conda update*": "allow", "conda create*": "allow",
      "snap install*": "allow", "flatpak install*": "allow",
      "pip install*": "allow", "npm install*": "allow", "npm ci*": "allow", "npm update*": "allow",
      "yarn install*": "allow", "yarn add*": "allow", "yarn upgrade*": "allow",
      "pnpm install*": "allow", "pnpm add*": "allow",
      "cargo install*": "allow", "cargo update*": "allow",
      "gem install*": "allow", "bundle install*": "allow",
      "composer install*": "allow", "composer update*": "allow",
      "curl*": "allow", "wget*": "allow", "ssh*": "allow", "scp*": "allow", "rsync*": "allow", "sftp*": "allow",
      "nc*": "allow", "ncat*": "allow", "socat*": "allow",
      "ping*": "allow", "traceroute*": "allow", "nslookup*": "allow", "dig*": "allow", "host*": "allow",
      "ifconfig*": "allow", "ip*": "allow", "ss*": "allow", "netstat*": "allow",
      "tar*": "allow", "gzip*": "allow", "gunzip*": "allow", "bzip2*": "allow", "bunzip2*": "allow",
      "xz*": "allow", "unxz*": "allow", "zip*": "allow", "unzip*": "allow",
      "7z*": "allow", "zstd*": "allow", "unzstd*": "allow", "lzma*": "allow", "unlzma*": "allow",
      "zcat*": "allow", "bzcat*": "allow", "xzcat*": "allow",
      "psql*": "allow", "mysql*": "allow", "sqlite3*": "allow", "redis-cli*": "allow", "mongosh*": "allow",
      "pg_dump*": "allow", "pg_restore*": "allow", "mysqldump*": "allow",
      "docker*": "allow", "podman*": "allow", "nerdctl*": "allow", "buildah*": "allow", "skopeo*": "allow",
      "docker-compose*": "allow", "docker compose*": "allow",
      "qemu*": "allow", "qemu-img*": "allow", "qemu-system*": "allow",
      "terraform*": "allow", "terragrunt*": "allow", "ansible*": "allow", "ansible-playbook*": "allow",
      "helm*": "allow", "kubectl*": "allow", "kustomize*": "allow",
      "vagrant*": "allow", "packer*": "allow",
      "aws*": "allow", "gcloud*": "allow", "az*": "allow", "heroku*": "allow",
      "vercel*": "allow", "netlify*": "allow", "fly*": "allow", "railway*": "allow",
      "build*": "allow", "run*": "allow", "start*": "allow", "stop*": "allow", "restart*": "allow",
      "clean*": "allow", "test*": "allow", "lint*": "allow", "format*": "allow",
      "check*": "allow", "verify*": "allow", "deploy*": "allow", "release*": "allow",
      "package*": "allow", "compile*": "allow", "assemble*": "allow",
      "man*": "allow", "info*": "allow", "help*": "allow", "usage*": "allow", "version*": "allow",
      "bat*": "allow", "exa*": "allow", "lsd*": "allow", "delta*": "allow",
      "fzf*": "allow", "fd*": "allow", "ripgrep*": "allow", "tldr*": "allow", "howdoi*": "allow",
      "rm -rf /*": "ask", "rm -rf /": "ask", "rm -rf ~": "ask", "rm -rf ~/": "ask",
      "rm -rf ..": "ask", "rm -rf .git": "ask",
      "rm -rf /home": "ask", "rm -rf /root": "ask", "rm -rf /etc": "ask", "rm -rf /var": "ask",
      "rm -rf /usr": "ask", "rm -rf /bin": "ask", "rm -rf /sbin": "ask", "rm -rf /lib": "ask",
      "rm -rf /boot": "ask", "rm -rf /dev": "ask", "rm -rf /proc": "ask", "rm -rf /sys": "ask", "rm -rf /tmp": "ask",
      "git push --force*": "ask", "git push -f*": "ask", "git push --force-with-lease*": "ask",
      "git reset --hard*": "ask", "git reset --merge*": "ask",
      "git clean -fd*": "ask", "git clean -fxd*": "ask", "git clean -fXd*": "ask",
      "git filter-branch*": "ask", "git filter-repo*": "ask", "git branch -D*": "ask",
      "sudo*": "ask", "su*": "ask",
      "systemctl stop*": "ask", "systemctl disable*": "ask", "systemctl mask*": "ask",
      "service stop*": "ask", "init 0*": "ask", "init 6*": "ask",
      "shutdown*": "ask", "reboot*": "ask", "halt*": "ask", "poweroff*": "ask",
      "mkfs*": "ask", "fdisk*": "ask", "parted*": "ask", "dd*": "ask", "wipefs*": "ask",
      "mount*": "ask", "umount*": "ask", "swapon*": "ask", "swapoff*": "ask",
      "chmod 777*": "ask", "chmod -R 777*": "ask", "chown -R*": "ask",
      "rm*": "ask", "chmod*": "ask", "chown*": "ask",
      "eval*": "ask", "source*": "ask", ".*": "ask",
      "shred*": "ask", "wipe*": "ask", "srm*": "ask",
      "export PATH=*": "ask", "unset PATH": "ask", "env -i*": "ask",
      "curl | sh*": "ask", "curl | bash*": "ask", "wget | sh*": "ask", "wget | bash*": "ask",
      "curl -sL | sh*": "ask", "curl -sL | bash*": "ask",
      "apt remove*": "ask", "apt purge*": "ask", "apt-get remove*": "ask", "apt-get purge*": "ask",
      "pkg delete*": "ask", "npm uninstall -g*": "ask",
      "terraform destroy*": "ask", "terraform state rm*": "ask", "terragrunt destroy*": "ask",
      "docker system prune*": "ask", "docker system prune -a*": "ask",
      "docker volume rm*": "ask", "docker network rm*": "ask",
      "docker container prune*": "ask", "docker image prune -a*": "ask",
      "curl | sudo sh*": "deny", "curl | sudo bash*": "deny",
      "wget | sudo sh*": "deny", "wget | sudo bash*": "deny",
      "curl -sL | sudo sh*": "deny", "curl -sL | sudo bash*": "deny",
      "rm -rf / --no-preserve-root*": "deny",
      ":(){:|:&};:*": "deny", "fork bomb*": "deny",
      "dd if=/dev/zero of=/dev/sd*": "deny", "dd if=/dev/random of=/dev/sd*": "deny",
      "mkfs.ext4 /dev/sd*": "deny", "mkfs.xfs /dev/sd*": "deny", "mkfs.btrfs /dev/sd*": "deny",
      "format c:*": "deny", "format c:\\*": "deny",
      "> /dev/sda*": "deny", "mv /* /dev/null*": "deny", "mv ~ /dev/null*": "deny",
      "chmod -R 000 /*": "deny", "chown -R nobody:nogroup /*": "deny",
      "iptables -F": "deny", "iptables -P INPUT ACCEPT": "deny", "iptables -P FORWARD ACCEPT": "deny",
      "ufw disable*": "deny"
    }
  }
}
OPencodeEOF

  # ── AGENTS ──
  _FAIL=0
  _NA="$(ls -1 "$SCRIPT_DIR/agents/" 2>/dev/null | wc -l | tr -d ' ')"
  case "${_NA}" in ''|*[!0-9]*) _NA=1 ;; esac
  _ai=0
  for f in "$SCRIPT_DIR/agents/"*.md; do
    [ -f "$f" ] || continue
    if cp "$f" "$CFG/agent/"; then
      _ai=$((_ai + 1)); okbar "${_ai}" "${_NA}" "agent: $(basename "$f")"
    else
      errbar "${_ai}" "${_NA}" "agent: $(basename "$f")"; _FAIL=$((_FAIL + 1))
    fi
  done
  if [ "${_ai}" -eq 0 ]; then err "tidak ada file tersalin di agent — install dibatalkan"; exit 1; fi

  # ── SKILLS ── (copy massal 1 operasi + verifikasi — jauh lebih cepat di I/O lambat;
  #              skill/ hanya berisi SKILL.md + run.sh, jadi hasil identik dengan copy per-file)
  _NS="$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')"
  case "${_NS}" in ''|*[!0-9]*) _NS=1 ;; esac
  _si=0
  if cp -R "$SCRIPT_DIR/skills/." "$CFG/skill/" 2>/dev/null; then
    chmod +x "$CFG"/skill/*/run.sh 2>/dev/null
    for skill_dir in "$SCRIPT_DIR/skills/"*/; do
      skill_name=$(basename "$skill_dir")
      if [ -f "$CFG/skill/$skill_name/SKILL.md" ]; then
        _si=$((_si + 1)); okbar "${_si}" "${_NS}" "skill: $skill_name"
      else
        errbar "${_si}" "${_NS}" "skill: $skill_name (SKILL.md tidak tersalin)"; _FAIL=$((_FAIL + 1))
      fi
    done
  else
    errbar 0 "${_NS}" "copy massal skills gagal"; _FAIL=$((_FAIL + 1))
  fi
  if [ "${_si:-0}" -eq 0 ]; then err "tidak ada file tersalin di skill — install dibatalkan"; exit 1; fi

  # ── COMMANDS ──
  _NC="$(ls -1 "$SCRIPT_DIR/command/" 2>/dev/null | wc -l | tr -d ' ')"
  case "${_NC}" in ''|*[!0-9]*) _NC=1 ;; esac
  _ci=0
  for f in "$SCRIPT_DIR/command/"*.md; do
    [ -f "$f" ] || continue
    if cp "$f" "$CFG/command/"; then
      _ci=$((_ci + 1)); okbar "${_ci}" "${_NC}" "command: $(basename "$f")"
    else
      errbar "${_ci}" "${_NC}" "command: $(basename "$f")"; _FAIL=$((_FAIL + 1))
    fi
  done
  if [ "${_ci}" -eq 0 ]; then err "tidak ada file tersalin di command — install dibatalkan"; exit 1; fi
  if [ "${_FAIL}" -ne 0 ]; then err "${_FAIL} file gagal — instalasi tidak lengkap, ulangi install"; exit 1; fi

  _GPMAX=$((_NA + _NS + _NC + 4))
  _GP=$((_ai + _si + _ci))
  pbar "${_GP}" "${_GPMAX}" "agent+skill+command tersalin"

  # ── DOCS & MEMORY ──
  [ -f "$SCRIPT_DIR/AGENTS.md" ] && cp "$SCRIPT_DIR/AGENTS.md" "$CFG/" && ok "doctrine: AGENTS.md"

  mkdir -p "$CFG/docs"
  [ -f "$SCRIPT_DIR/docs/USAGE.md" ] && cp "$SCRIPT_DIR/docs/USAGE.md" "$CFG/docs/" && ok "panduan: docs/USAGE.md"
  [ -f "$SCRIPT_DIR/docs/PLAYBOOKS.md" ] && cp "$SCRIPT_DIR/docs/PLAYBOOKS.md" "$CFG/docs/" && ok "playbook: docs/PLAYBOOKS.md"
  [ -f "$SCRIPT_DIR/docs/ARCHITECTURE.md" ] && cp "$SCRIPT_DIR/docs/ARCHITECTURE.md" "$CFG/docs/" && ok "arsitektur: docs/ARCHITECTURE.md"
  [ -f "$SCRIPT_DIR/docs/ROADMAP.md" ] && cp "$SCRIPT_DIR/docs/ROADMAP.md" "$CFG/docs/" && ok "roadmap: docs/ROADMAP.md"

  for f in "$SCRIPT_DIR/memory/"*.md; do
    [ -f "$f" ] && [ ! -f "$CFG/memory/$(basename "$f")" ] && cp "$f" "$CFG/memory/"
  done

  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  ok "total $N file otak ditulis"
  pdone "tulis otak selesai"

  [ -f "$SCRIPT_DIR/VERSION" ] && cp "$SCRIPT_DIR/VERSION" "$CFG/VERSION"
}

# ════════════════════════════════════════════
#  PROJECT INSTALL
# ════════════════════════════════════════════
install_project(){
  ph "PASANG KE PROJECT"
  mode_strip "build"
  div
  dots "menyiapkan project" 3
  if [ ! -d "$PROJECT" ]; then err "folder tidak ditemukan: $PROJECT"; return 1; fi

  if [ -f "$PROJECT/AGENTS.md" ] && ! grep -q 'DEV-BRAIN (project ini)' "$PROJECT/AGENTS.md" 2>/dev/null; then
    cp "$PROJECT/AGENTS.md" "$PROJECT/AGENTS.md.bak.$(date +%s)"
    wrn "AGENTS.md project dibackup (isi asli dipertahankan di .bak)"
  fi

  rm -rf "$PROJECT/.opencode/agent" "$PROJECT/.opencode/skill" "$PROJECT/.opencode/command"
  mkdir -p "$PROJECT/.opencode/memory"
  cp -r "$CFG/agent"   "$PROJECT/.opencode/" 2>/dev/null
  cp -r "$CFG/skill"   "$PROJECT/.opencode/" 2>/dev/null
  cp -r "$CFG/command" "$PROJECT/.opencode/" 2>/dev/null
  [ -f "$PROJECT/.opencode/memory/MEMORY.md" ] || cp "$CFG/memory/MEMORY.md" "$PROJECT/.opencode/memory/"

  cat > "$PROJECT/AGENTS.md" <<'EOF'
# DEV-BRAIN (project ini)
Otak utama: DEV — caveman mode ULTRA, pipeline otomatis:
recall+scan → think → imagine+architect → plan (rencana 8 blok TAMPIL dulu) → coder → test → audit → fix → (BUG? debug) → (DOK? doc-full) → (MAHAL? cost) → memory → lapor.
Memori project: `.opencode/memory/`. Doctrine lengkap: `~/.config/opencode/AGENTS.md`.
Tidak perlu command manual — ketik tugas, DEV mengorkestrasi sendiri.
EOF
  ok "terpasang di $PROJECT/.opencode + AGENTS.md"
}

# ════════════════════════════════════════════
#  CHECK INSTALL
# ════════════════════════════════════════════
check_install(){
  ph "CHECK INSTALASI DEV-BRAIN"
  mode_strip ""
  div
  dots "memeriksa instalasi" 3
  BAD=0
  [ -f "$CFG/AGENTS.md" ] || { err "doctrine hilang: $CFG/AGENTS.md"; BAD=1; }
  [ -f "$CFG/opencode.json" ] || { err "config hilang: $CFG/opencode.json"; BAD=1; }
  grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null || { wrn "opencode.json tanpa marker devbrain (bukan tulisan installer)"; }
  for d in agent command memory skill; do
    [ -d "$CFG/$d" ] || { err "folder hilang: $CFG/$d"; BAD=1; }
  done
  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${N:-0}" -ge 20 ] || { err "file otak cuma $N — install ulang"; BAD=1; }
  V=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  if [ -n "$V" ]; then ok "versi terpasang: $V"; else wrn "versi tidak tercatat (install lama) — update disarankan"; fi
  for s in "$CFG"/skill/*/run.sh; do
    [ -f "$s" ] || continue
    bash -n "$s" 2>/dev/null || { err "script rusak: $s"; BAD=1; }
  done
  if [ "$BAD" -eq 0 ]; then ok "instalasi sehat — $N file otak, semua script valid"; pdone "cek selesai"; return 0
  else pdone "cek selesai (ada masalah)"; return 1
  fi
}

# ════════════════════════════════════════════
#  GIT HOOK
# ════════════════════════════════════════════
install_hook(){
  ph "HOOK GIT-GUARD"
  mode_strip ""
  div
  dots "menyiapkan hook" 3
  [ -d .git ] || { err "bukan git repo — jalankan dari root project"; return 1; }
  mkdir -p .git/hooks
  if [ -f .git/hooks/pre-commit ] && ! grep -q 'devbrain' .git/hooks/pre-commit 2>/dev/null; then
    cp .git/hooks/pre-commit ".git/hooks/pre-commit.bak.$(date +%s)"
    wrn "pre-commit lama dibackup (.bak)"
  fi
  cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# DEV-BRAIN git-guard (marker: devbrain) — blokir secret/marker/debug di staged diff
GUARD="$HOME/.config/opencode/skill/git-guard/run.sh"
[ -f "$GUARD" ] && exec bash "$GUARD"
EOF
  chmod +x .git/hooks/pre-commit
  ok "pre-commit → git-guard terpasang (setiap commit otomatis di-scan)"
}

# ════════════════════════════════════════════
#  FINISH — verifikasi + banner akhir
# ════════════════════════════════════════════
finish(){
  ph "VERIFIKASI"
  mode_strip "build"
  div

  _FA="$(find "$CFG/agent" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  _FS="$(find "$CFG/skill" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')"
  _FR="$(find "$CFG/skill" -mindepth 2 -maxdepth 2 -type f -name 'run.sh' 2>/dev/null | wc -l | tr -d ' ')"
  _FC="$(find "$CFG/command" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  _TOT="$(elapsed "${_ANIM_T0:-0}")"

  celebrate "${_TOT}" "$((_FA + _FS + _FC))"
  ok "$_FA agent • $_FS skill ($_FR dengan bash script) • $_FC command • memori + pelajaran persisten"
  echo
  div
  bold 220 "  CARA PAKAI:"
  pc 147 "  1) buka folder project apa saja"
  pc 147 "  2) jalankan:  opencode"
  pc 147 "  3) DEV otomatis aktif (satu-satunya primary)"
  pc 147 "  4) ketik tugas bahasa bebas, contoh:"
  pc 213 "     \"buat halaman login, testnya sekalian, audit juga\""
  pc 147 "  5) DEV jalan: plan tampil → build → test → audit → ingat"
  echo
  div
  pc 147 "  SHORTCUT : /ship <tugas>   /fix   /memory"
  pc 214 "  API key  : jalankan  opencode auth login  bila belum"
  echo

  pdone "verifikasi selesai"
  ok "durasi total ${_TOT}s"
  echo
  mode_strip ""
  echo
}

# ════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════
banner_reveal
[ "$SHOWVER" -eq 1 ] && { bold 45 "  DEV-BRAIN v$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo '?')"; exit 0; }
[ "$UNINSTALL" -eq 1 ] && { uninstall; }
[ "$CHECK" -eq 1 ] && { check_install; exit $?; }
[ "$UPDATE" -eq 1 ] && { update; }
check_remote_version
write_brain
if [ -n "$PROJECT" ]; then install_project || exit 1; fi
if [ "$HOOK" -eq 1 ]; then install_hook || exit 1; fi
finish
if [ "$LINT" -eq 1 ] && [ -f "$SCRIPT_DIR/tests/lint-kit.sh" ]; then
  ph "LINT VERIFIKASI" "◇"
  bash "$SCRIPT_DIR/tests/lint-kit.sh" && bash "$SCRIPT_DIR/tests/self-test.sh" || exit 1
  echo
fi
exit 0
