#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  CLEAN — bersihkan artefak kerja dari ALLOWLIST ketat.
#  Pemakaian: bash run.sh [root] [--dry]
#  Exit: 0 = bersih/dry selesai, 1 = ada gagal, 2 = root tidak ada
#  DILARANG sentuh: kode sumber, node_modules, .git, .env*, memori.
# ═════════════════════════════════════════════════════════════════
set -u
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
inf(){ p "  ▸ $1" 45; }
DRY=0; ROOT=""
for a in "$@"; do
  case "$a" in
    --dry) DRY=1 ;;
    *) [ -z "$ROOT" ] && ROOT="$a" ;;
  esac
done
[ -z "$ROOT" ] && ROOT="."
[ -d "$ROOT" ] || { p "  ✖ root tidak ada: $ROOT" 196; exit 2; }
ROOT="$(cd "$ROOT" && pwd)"

p "▮ CLEAN — mode: $([ $DRY -eq 1 ] && echo DRY || echo REAL) | root: $ROOT" 213

# ALLOWLIST ketat — node_modules/.git diprune, tidak pernah dituruni.
TARGETS=$(find "$ROOT" \( -type d -name node_modules -o -type d -name .git \) -prune -o \
  -type d \( -name dist -o -name build -o -name out -o -name .next -o -name .nuxt \
             -o -name .turbo -o -name .parcel-cache -o -name .cache -o -name coverage \
             -o -name .pytest_cache -o -name .mypy_cache -o -name __pycache__ -o -name tmp \) -print 2>/dev/null;
  find "$ROOT" \( -type d -name node_modules -o -type d -name .git \) -prune -o \
  -type f \( -name "*.log" -o -name "*.tmp" -o -name .DS_Store -o -name Thumbs.db \) -print 2>/dev/null)

[ -z "$TARGETS" ] && { inf "bersih — tidak ada artefak"; exit 0; }

TOTAL_KB=0; FAILED=0
while IFS= read -r t; do
  [ -z "$t" ] && continue
  KB=$(du -sk "$t" 2>/dev/null | cut -f1); KB=${KB:-0}
  TOTAL_KB=$((TOTAL_KB + KB))
  if [ "$DRY" -eq 1 ]; then
    inf "akan dihapus: $t (${KB}K)"
  else
    if rm -rf "$t" 2>/dev/null; then ok "hapus: $t (${KB}K)"; else p "  ✖ gagal hapus: $t" 196; FAILED=$((FAILED+1)); fi
  fi
done <<EOF
$TARGETS
EOF

if [ "$DRY" -eq 1 ]; then
  p "▮ CLEAN DRY — total ${TOTAL_KB}K bisa dibebaskan (jalankan tanpa --dry untuk hapus)" 214
else
  [ "$FAILED" -gt 0 ] && { p "▮ CLEAN — ${TOTAL_KB}K dibebaskan, $FAILED gagal" 196; exit 1; }
  p "▮ CLEAN — total dibebaskan: ${TOTAL_KB}K" 82
fi
exit 0
