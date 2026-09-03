#!/usr/bin/env bash
# ============================================================
#  install-linux.sh — agent-ai untuk LINUX SAJA (PC/server/VPS).
#  Tanpa root/sudo. Backup otomatis. Idempoten (aman diulang).
#
#  Cara pakai:
#    bash install-linux.sh              # dari dalam folder repo
#    bash install-linux.sh --check      # cek status tanpa ubah apa-apa
# ============================================================
set -u

REPO_URL="https://github.com/nemoobc/agent-ai"
TARBALL_URL="https://github.com/nemoobc/agent-ai/archive/refs/heads/master.tar.gz"
SRC="$(cd "$(dirname "$0")" && pwd)"
MODE="install"
[ "${1:-}" = "--check" ] && MODE="check"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  [ok] %s\n' "$*"; }
warn() { printf '  [!!] %s\n' "$*"; }
die()  { printf '[GAGAL] %s\n' "$*" >&2; exit 1; }

# ---------- 1. wajib Linux (tolak Termux) ----------
if [ -n "${PREFIX:-}" ] && printf '%s' "$PREFIX" | grep -q "com.termux"; then
  die "ini Termux! pakai install-termux.sh"
fi
if [ -d "/data/data/com.termux" ] && [ -z "${AGENT_OS:-}" ]; then
  die "terdeteksi Termux. pakai install-termux.sh (atau AGENT_OS=linux untuk paksa)"
fi
say "OS: linux (valid)"
# ---------- 2. cek tool ----------
for t in cp mkdir rm find wc; do
  command -v "$t" >/dev/null 2>&1 || die "tool '$t' tidak ada. Termux: pkg install coreutils | Linux: apt install coreutils"
done

# ---------- 3. sumber file (lokal atau unduh) ----------
need_dir() { [ -d "$SRC/agents/config-agents" ] && [ -d "$SRC/skills/config-skills" ] && [ -d "$SRC/command" ]; }
if ! need_dir; then
  say "File repo tidak lengkap di $SRC — unduh otomatis..."
  command -v curl >/dev/null 2>&1 || die "butuh 'curl' (Termux: pkg install curl | Linux: apt install curl) atau clone manual: git clone $REPO_URL"
  TMPD="$(mktemp -d 2>/dev/null || echo "/tmp/agent-dl-$$")"
  mkdir -p "$TMPD"
  curl -fsSL -o "$TMPD/agent.tgz" "$TARBALL_URL" || die "unduh gagal. cek internet / URL: $TARBALL_URL"
  tar -xzf "$TMPD/agent.tgz" -C "$TMPD" || die "ekstrak tarball gagal"
  SRC="$(find "$TMPD" -maxdepth 1 -type d \( -name 'agent-ai-*' -o -name 'Agent-*' \) | head -1)"
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

# ---------- 4. mode check ----------
if [ "$MODE" = "check" ]; then
  say "--- status ---"
  say "agent:   $(count_md "$CFG/agent") file di $CFG/agent"
  say "skills:  $(count_md "$CFG/skills") file di $CFG/skills"
  say "command: $(count_md "$CFG/command") file di $CFG/command"
  say "AGENTS.md: $([ -f "$CFG/AGENTS.md" ] && echo ada || echo HILANG)"
  say "opencode.json: $([ -f "$CFG/opencode.json" ] && echo ada || echo HILANG)"
  say "autodev:  $([ -d "$AUTODEV_HOME" ] && echo ada || echo HILANG)"
  if command -v opencode >/dev/null 2>&1; then ok "binary opencode: $(command -v opencode)"; else warn "binary opencode TIDAK ada di PATH"; fi
  exit 0
fi

# ---------- 5. backup ----------
if [ -d "$CFG" ]; then
  cp -a "$CFG" "$CFG.bak.$TS" || die "backup $CFG gagal"
  ok "backup: $CFG.bak.$TS"
fi
if [ -d "$AUTODEV_HOME" ]; then
  cp -a "$AUTODEV_HOME" "$AUTODEV_HOME.bak.$TS" || die "backup autodev gagal"
  ok "backup: $AUTODEV_HOME.bak.$TS"
fi

# ---------- 6. copy ----------
mkdir -p "$CFG/agent" "$CFG/skills" "$CFG/command" "$AUTODEV_HOME" || die "mkdir gagal"
cp -r "$SRC/agents/config-agents/." "$CFG/agent/" || die "copy agent gagal"
cp -r "$SRC/skills/config-skills/." "$CFG/skills/" || die "copy skills gagal"
cp -r "$SRC/command/." "$CFG/command/" || die "copy command gagal"
cp "$SRC/AGENTS.md" "$CFG/AGENTS.md" || die "copy AGENTS.md gagal"
[ -f "$SRC/opencode.json" ] && cp "$SRC/opencode.json" "$CFG/opencode.json"
cp -r "$SRC/autodev/." "$AUTODEV_HOME/" || die "copy autodev gagal"

# ---------- 7. verifikasi ----------
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

if command -v opencode >/dev/null 2>&1; then
  ok "binary opencode: $(command -v opencode)"
else
  warn "binary opencode TIDAK ada di PATH."
  say "  Linux: npm install -g opencode-ai"
fi

say ""
say "SELESAI. Jalankan: opencode"
say "Cek lain waktu: bash install-linux.sh --check"
