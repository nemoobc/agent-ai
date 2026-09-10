#!/usr/bin/env bash
# upgrade — upgrade kit dari remote (install.sh --update)
# Usage: bash commands/upgrade.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ UPGRADE DEV-BRAIN ═══" 213

if [ -f "$DIR/install.sh" ]; then
  bash "$DIR/install.sh" --update
  EXIT=$?
  if [ "$EXIT" -eq 0 ]; then
    ok "Upgrade selesai"
  else
    bad "Upgrade gagal (exit $EXIT)"
    exit 1
  fi
else
  bad "install.sh not found"
  exit 1
fi

p "═══ UPGRADE SELESAI ═══" 82
