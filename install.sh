#!/usr/bin/env bash
# =============================================================================
# install.sh — agent-ai universal installer (Termux + Linux)
# -----------------------------------------------------------------------------
# Auto-detect OS. Backup otomatis. Idempoten (aman diulang).
#
# Cara pakai:
#   bash install.sh              # install
#   bash install.sh --check      # cek status
#   bash install.sh --uninstall  # hapus
#   bash install.sh --version X  # install versi tertentu
# =============================================================================
set -u

REPO="nemoobc/agent-ai"
REPO_URL="https://github.com/$REPO"
TARBALL_URL="$REPO_URL/archive/refs/heads/master.tar.gz"
SRC="$(cd "$(dirname "$0")" && pwd)"
MODE="install"
VERSION=""

# --- parse args ---
while [ $# -gt 0 ]; do
  case "$1" in
    --check)     MODE="check"; shift ;;
    --uninstall) MODE="uninstall"; shift ;;
    --version)   VERSION="${2:-}"; shift 2 || shift ;;
    -h|--help)
      echo "Usage: bash install.sh [--check|--uninstall|--version X]"
      exit 0 ;;
    *) shift ;;
  esac
done

say()  { printf '%s\n' "$*"; }
ok()   { printf '  [ok] %s\n' "$*"; }
warn() { printf '  [!!] %s\n' "$*"; }
die()  { printf '[GAGAL] %s\n' "$*" >&2; exit 1; }

# --- detect OS ---
IS_TERMUX=0
if [ -n "${PREFIX:-}" ] && printf '%s' "$PREFIX" | grep -q "com.termux"; then
  IS_TERMUX=1
elif [ -d "/data/data/com.termux" ]; then
  IS_TERMUX=1
elif [ -n "${AGENT_OS:-}" ] && [ "$AGENT_OS" = "linux" ]; then
  IS_TERMUX=0
fi

if [ "$IS_TERMUX" = 1 ]; then
  say "OS: Termux (Android)"
else
  say "OS: Linux"
fi

# --- check tools ---
for t in cp mkdir rm find wc; do
  command -v "$t" >/dev/null 2>&1 || die "tool '$t' tidak ada"
done

# --- source files (local or download) ---
need_dir() { [ -d "$SRC/agents/config-agents" ] && [ -d "$SRC/skills/config-skills" ] && [ -d "$SRC/command" ]; }

if ! need_dir; then
  say "File repo tidak lengkap di $SRC — unduh otomatis..."
  command -v curl >/dev/null 2>&1 || die "butuh 'curl' atau clone manual: git clone $REPO_URL"
  [ -n "$VERSION" ] && TARBALL_URL="$REPO_URL/archive/refs/tags/v${VERSION}.tar.gz"
  TMPD="$(mktemp -d 2>/dev/null || echo "/tmp/agent-dl-$$")"
  mkdir -p "$TMPD"
  curl -fsSL -o "$TMPD/agent.tgz" "$TARBALL_URL" || die "unduh gagal: $TARBALL_URL"
  tar -xzf "$TMPD/agent.tgz" -C "$TMPD" || die "ekstrak gagal"
  SRC="$(find "$TMPD" -maxdepth 1 -type d -name 'agent-ai-*' | head -1)"
  [ -n "$SRC" ] || die "isi tarball aneh"
  need_dir || die "isi repo tidak lengkap"
  ok "sumber: tarball $TARBALL_URL"
else
  ok "sumber: $SRC"
fi

CFG="$HOME/.config/opencode"
AUTODEV_HOME="$HOME/.autodev"
TS="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo backup)"
count_md() { find "$1" -name '*.md' 2>/dev/null | wc -l; }

# --- uninstall mode ---
if [ "$MODE" = "uninstall" ]; say "=== UNINSTALL ===" &&
   rm -rf "$CFG/agent" "$CFG/skills" "$CFG/command" "$CFG/AGENTS.md" "$AUTODEV_HOME" &&
   rm -f "$HOME/.local/bin/agent-ai" 2>/dev/null &&
   ok "config dihapus: $CFG/agent, $CFG/skills, $CFG/command" &&
   ok "autodev dihapus: $AUTODEV_HOME" &&
   ok "UNINSTALL SELESAI. Config user (~/.config/opencode/opencode.json) tidak disentuh." &&
   exit 0; then
  exit 0
fi

# --- check mode ---
if [ "$MODE" = "check" ]; then
  say "=== STATUS ==="
  say "agent:     $(count_md "$CFG/agent") file di $CFG/agent"
  say "skills:    $(count_md "$CFG/skills") file di $CFG/skills"
  say "command:   $(count_md "$CFG/command") file di $CFG/command"
  say "AGENTS.md: $([ -f "$CFG/AGENTS.md" ] && echo "ada" || echo "HILANG")"
  say "opencode.json: $([ -f "$CFG/opencode.json" ] && echo "ada" || echo "HILANG")"
  say "autodev:   $([ -d "$AUTODEV_HOME" ] && echo "ada" || echo "HILANG")"
  say ""

  # check installed version from git or file
  if [ -f "$CFG/agent/autodev.md" ]; then
    say "agent-ai:  terpasang"
    [ -f "$CFG/agent/autodev-skills.md" ] && ok "autodev-skills: ada" || warn "autodev-skills: HILANG"
  else
    say "agent-ai:  BELUM terpasang"
  fi

  # check binary
  if [ "$IS_TERMUX" = 1 ]; then
    if command -v opencode-termux >/dev/null 2>&1; then
      ok "binary: $(command -v opencode-termux)"
    elif command -v opencode >/dev/null 2>&1; then
      ok "binary: $(command -v opencode)"
    else
      warn "binary opencode TIDAK ada di PATH"
      say "  Install: https://github.com/nemoobc/opencode-termux"
    fi
  else
    if command -v opencode >/dev/null 2>&1; then
      ok "binary: $(command -v opencode)"
    else
      warn "binary opencode TIDAK ada di PATH"
      say "  Install: npm install -g opencode-ai"
    fi
  fi

  # check for updates
  if command -v git >/dev/null 2>&1 && [ -d "$SRC/.git" ]; then
    cd "$SRC" 2>/dev/null && git fetch origin --quiet 2>/dev/null
    LOCAL=$(git rev-parse HEAD 2>/dev/null)
    REMOTE=$(git rev-parse origin/master 2>/dev/null || git rev-parse origin/main 2>/dev/null)
    if [ -n "$LOCAL" ] && [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
      say "update:    ADA versi baru (jalankan bash install.sh lagi)"
    else
      say "update:    sudah terbaru"
    fi
    cd - >/dev/null
  fi
  exit 0
fi

# --- backup ---
if [ -d "$CFG" ]; then
  cp -a "$CFG" "$CFG.bak.$TS" || die "backup gagal"
  ok "backup: $CFG.bak.$TS"
fi
if [ -d "$AUTODEV_HOME" ]; then
  cp -a "$AUTODEV_HOME" "$AUTODEV_HOME.bak.$TS" || die "backup autodev gagal"
  ok "backup: $AUTODEV_HOME.bak.$TS"
fi

# --- install ---
mkdir -p "$CFG/agent" "$CFG/skills" "$CFG/command" "$AUTODEV_HOME" || die "mkdir gagal"
cp -r "$SRC/agents/config-agents/." "$CFG/agent/" || die "copy agent gagal"
cp -r "$SRC/skills/config-skills/." "$CFG/skills/" || die "copy skills gagal"
cp -r "$SRC/command/." "$CFG/command/" || die "copy command gagal"
cp "$SRC/AGENTS.md" "$CFG/AGENTS.md" || die "copy AGENTS.md gagal"
[ -f "$SRC/opencode.json" ] && cp "$SRC/opencode.json" "$CFG/opencode.json"
cp -r "$SRC/autodev/." "$AUTODEV_HOME/" || die "copy autodev gagal"

# --- verify ---
say "--- verifikasi ---"
n_agent="$(count_md "$CFG/agent")"
n_skill="$(count_md "$CFG/skills")"
n_cmd="$(count_md "$CFG/command")"
[ "$n_agent" -ge 2 ] || die "agent kurang ($n_agent file)"
[ "$n_skill" -ge 10 ] || die "skills kurang ($n_skill file)"
[ "$n_cmd" -ge 5 ] || die "command kurang ($n_cmd file)"
[ -f "$CFG/AGENTS.md" ] || die "AGENTS.md hilang"
ok "agent: $n_agent file"
ok "skills: $n_skill file"
ok "command: $n_cmd file"
ok "AGENTS.md + autodev terpasang"

if [ "$IS_TERMUX" = 1 ]; then
  if command -v opencode-termux >/dev/null 2>&1; then
    ok "binary: $(command -v opencode-termux)"
  elif command -v opencode >/dev/null 2>&1; then
    ok "binary: $(command -v opencode)"
  else
    warn "binary opencode TIDAK ada."
    say "  Install: https://github.com/nemoobc/opencode-termux"
  fi
else
  if command -v opencode >/dev/null 2>&1; then
    ok "binary: $(command -v opencode)"
  else
    warn "binary opencode TIDAK ada."
    say "  Install: npm install -g opencode-ai"
  fi
fi

say ""
say "SELESAI. Jalankan: opencode"
say "Cek status: bash install.sh --check"
say "Uninstall:  bash install.sh --uninstall"
