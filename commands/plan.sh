#!/usr/bin/env bash
# plan — panduan fase GODOK (rencana 8 blok) — jalankan /plan di dalam opencode
# Usage: bash commands/plan.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

p "═══ PLAN — GODOK RENCANA 8 BLOK ═══" 213
p "  Fase ini jalan DI DALAM opencode (butuh otak DEV):" 248
p "    1) buka opencode di folder project" 248
p "    2) ketik:  /plan <tugas>" 248
p "  DEV jalankan: scan → think → imagine (architect) → plan 8 blok" 248
p "  Gerbang: rencana TAMPIL ke user → ACC → baru /build" 248
[ -f "$DIR/docs/ARCHITECTURE.md" ] && p "  Arsitektur kit: $DIR/docs/ARCHITECTURE.md" 248
p "═══ PLAN — TUNGGU /plan DI OPENCODE ═══" 213
exit 0
