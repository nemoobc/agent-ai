#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  AGENT-AI one-liner installer — `curl ... | bash`
#  Unduh arsip source dari GitHub, ekstrak ke temp, jalankan
#  install.sh asli (deteksi V1/V2, dependensi, config aman).
#
#  Install   : curl -fsSL https://raw.githubusercontent.com/nemoobc/agent-ai/master/curl-install.sh | bash
#  Cek       : ... | bash -s -- --check
#  Uninstall : ... | bash -s -- --uninstall
#
#  Keamanan: pipa `curl | bash` = jalankan skrip tanpa inspeksi.
#  Bila ragu, unduh dulu & baca: bash <(curl -fsSL <url>) bukan rekomendasi —
#  recommended: curl -o file && less file && bash file.
# ═══════════════════════════════════════════════════════════
set -euo pipefail

AGENT_AI_REPO="${AGENT_AI_REPO:-nemoobc/agent-ai}"
AGENT_AI_REF="${AGENT_AI_REF:-master}"
AGENT_AI_URL="${AGENT_AI_URL:-https://github.com/${AGENT_AI_REPO}/archive/refs/heads/${AGENT_AI_REF}.tar.gz}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v curl >/dev/null 2>&1 || { echo "✖ curl tidak ada — install dulu: pkg install curl (Termux) / apt-get install curl"; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "✖ tar tidak ada"; exit 1; }

curl -fsSL --connect-timeout 10 --max-time 120 "$AGENT_AI_URL" -o "$TMP/agent-ai.tgz" \
  || { echo "✖ unduh gagal: $AGENT_AI_URL"; exit 1; }
tar -xzf "$TMP/agent-ai.tgz" -C "$TMP" || { echo "✖ ekstrak gagal"; exit 1; }

SRC=$(find "$TMP" -maxdepth 1 -type d -name 'agent-ai*' | head -1)
[ -n "${SRC:-}" ] && [ -f "$SRC/install.sh" ] || { echo "✖ arsip tidak valid"; exit 1; }

exec bash "$SRC/install.sh" "$@"