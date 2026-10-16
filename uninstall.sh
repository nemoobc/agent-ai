#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  UNINSTALL — lepas instalasi kit dari ~/.config/opencode.
#  Satu sumber logika = install.sh --uninstall (HUKUM 10): layout V1
#  (agent/skill/command) & V2 (agents/skills/commands) ditangani di sana —
#  skrip ini TIDAK menduplikasi rm/restore yang bisa drift dari installer.
#  memory/ DIPERTAHANKAN; config user dipulihkan dari backup .bak.*.
#  Jalankan: bash uninstall.sh [--check] [--yes]
#    --check : pratinjau saja (tidak ada yang dilepas)
#    --yes   : wajib untuk non-interaktif (tanpa prompt)
# ═════════════════════════════════════════════════════════════════
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$DIR/install.sh" ] || { echo "uninstall.sh: install.sh tidak ditemukan di $DIR"; exit 1; }
case "${1:-}" in
  --check|-c) exec bash "$DIR/install.sh" --uninstall --check ;;
  --help|-h)  echo "Usage: bash uninstall.sh [--check] [--yes]"; exit 0 ;;
  *)          exec bash "$DIR/install.sh" --uninstall "$@" ;;
esac
