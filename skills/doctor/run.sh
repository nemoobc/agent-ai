#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  DOCTOR — diagnosa instalasi + kesehatan kit DEV-BRAIN
#  Jalankan: bash ~/.config/opencode/skill/doctor/run.sh .
#  Exit 0 = sehat, 1 = ada masalah
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; ISSUES=$((ISSUES+1)); }
warn(){ p "  ⚠ $1" 214; }
ISSUES=0

p "▮ DOCTOR: lingkungan" 213
for c in bash git grep; do
  command -v "$c" >/dev/null 2>&1 && ok "$c: $(command -v "$c")" || bad "$c tidak ada"
done
BASHV=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
ok "bash versi $BASHV"

p "▮ DOCTOR: dependensi opsional" 213
[ -f package.json ] && { command -v npm >/dev/null 2>&1 && ok "npm $(npm --version 2>/dev/null)" || warn "package.json ada, npm tidak terpasang"; }
command -v shellcheck >/dev/null 2>&1 && ok "shellcheck terpasang — audit bisa lebih tajam" || p "  · shellcheck tidak ada (opsional, audit tetap jalan)" 245
command -v gitleaks >/dev/null 2>&1 && ok "gitleaks terpasang — scan sejarah git aktif" || p "  · gitleaks tidak ada (opsional, scan sejarah skip)" 245
command -v pip-audit >/dev/null 2>&1 && ok "pip-audit terpasang" || true

p "▮ DOCTOR: kesehatan project" 213
if [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
  node_modules/.bin/tsc --noEmit >/dev/null 2>&1 && ok "typecheck bersih" || bad "type error (tsc --noEmit gagal)"
elif [ -f tsconfig.json ]; then
  warn "tsconfig ada tapi tsc tidak terinstall — typecheck dilewati"
fi
if [ -f package.json ] && [ ! -d node_modules ]; then
  warn "package.json ada, node_modules belum — jalankan install dulu"
fi
[ -d .git ] && ok "git repo: branch $(git branch --show-current 2>/dev/null || echo '?')" || p "  · bukan git repo" 245
[ -f AGENTS.md ] && ok "AGENTS.md ada (doctrine project)" || p "  · AGENTS.md tidak ada (opsional)" 245

p "▮ DOCTOR: memori DEV-BRAIN" 213
MEMDIR=""
[ -f .opencode/memory/MEMORY.md ] && MEMDIR=".opencode/memory"
[ -z "$MEMDIR" ] && [ -f "$HOME/.config/opencode/memory/MEMORY.md" ] && MEMDIR="$HOME/.config/opencode/memory"
if [ -n "$MEMDIR" ]; then
  ok "memori: $MEMDIR"
  EN=$(grep -c '^## ' "$MEMDIR/MEMORY.md" 2>/dev/null || echo 0)
  DC=$(grep -c '^- \[' "$MEMDIR/decisions.md" 2>/dev/null || echo 0)
  SL=$(grep -c '^- \[' "$MEMDIR/session-log.md" 2>/dev/null || echo 0)
  ok "entries: ${EN:-0} ingatan • ${DC:-0} keputusan • ${SL:-0} log sesi"
  grep -qiE '(api[_-]?key|password|token|secret)[[:space:]]*[:=][[:space:]]*[^[:space:]]{8,}' "$MEMDIR"/*.md 2>/dev/null \
    && bad "memori diduga menyimpan secret — bersihkan SEKARANG" \
    || ok "memori bebas secret"
else
  p "  · memori kosong — belum ada tugas penting terekam" 245
fi

echo
if [ "$ISSUES" -eq 0 ]; then p "DOCTOR_RESULT: SEHAT ✓" 82; exit 0; fi
p "DOCTOR_RESULT: $ISSUES MASALAH ✗" 196; exit 1
