#!/usr/bin/env bash
# onboard — onboarding: scan project + reminder HUKUM
# Usage: bash commands/onboard.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }

p "═══ ONBOARDING DEV-BRAIN ═══" 213

# Scan project
[ -f AGENTS.md ] && ok "AGENTS.md found" || warn "AGENTS.md missing"
[ -f VERSION ] && ok "VERSION: $(cat VERSION)" || warn "VERSION missing"
[ -d skills ] && ok "skills/ found ($(ls skills/ 2>/dev/null | wc -l) skills)" || warn "skills/ missing"
[ -d agents ] && ok "agents/ found ($(ls agents/ 2>/dev/null | wc -l) agents)" || warn "agents/ missing"
[ -d tests ] && ok "tests/ found ($(ls tests/ 2>/dev/null | wc -l) tests)" || warn "tests/ missing"
[ -d memory ] && ok "memory/ found" || warn "memory/ missing"

# Git status
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
  ok "git branch: $BRANCH ($COMMITS commits)"
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l)
  [ "$DIRTY" -gt 0 ] && warn "$DIRTY uncommitted changes" || ok "working tree clean"
else
  warn "not a git repo"
fi

# Reminder HUKUM
p "" 0
p "═══ HUKUM REMINDER ═══" 213
p "1. Caveman mode — kata kerja dulu, hasil = bukti" 248
p "2. Pipeline — MIKIR→BAYANGKAN→GODOK→BANGUN→TEST→AUDIT→FIX→LAPOR" 248
p "3. Memori — awal sesi recall, akhir sesi remember+learn" 248
p "4. Berhenti HANYA untuk: rm -rf, push --force, install paket, aksi berbiaya" 248
p "5. Lapor SELESAI hanya setelah semua gerbang hijau" 248
p "" 0
p "Siap kerja. Kasih tugas." 82
