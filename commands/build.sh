#!/usr/bin/env bash
# build — panduan fase BANGUN (butuh gerbang PLAN_DONE) — jalankan /build di dalam opencode
# Usage: bash commands/build.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

p "═══ BUILD — BANGUN SETELAH PLAN ═══" 213
p "  Fase ini jalan DI DALAM opencode (butuh otak DEV):" 248
p "    1) /plan <tugas> dulu — rencana 8 blok tampil + ACC" 248
p "    2) ketik:  /build <tugas sama>" 248
p "  DEV jalankan: coder → test-full → audit-full → fixer → doc → lapor" 248
p "  Gerbang: tanpa PLAN_DONE, /build DITOLAK (anti-bentrok G4/G5)" 248
p "  Verifikasi cepat dari shell: bash commands/verify.sh" 248
p "═══ BUILD — TUNGGU /build DI OPENCODE ═══" 213
exit 0
