#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  PROFILE run.sh — tampilkan/simpan profil user dari memori.
#  Pemakaian: bash run.sh show                    → baca bagian PROFIL dari memory/MEMORY.md
#             bash run.sh set <A|B|C> <D1|D2|D3>  → tulis profil (memory/MEMORY.md project)
# ═════════════════════════════════════════════════════════════════
set -u
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
DIR="$(cd "$(dirname "$0")/.." && pwd)"
MEM="memory/MEMORY.md"
[ -f "$MEM" ] || MEM="$(cd "$(dirname "$0")/../../.." && pwd)/memory/MEMORY.md"

case "${1:-show}" in
  show)
    if grep -q 'PROFIL USER' "$MEM" 2>/dev/null; then
      grep -A2 'PROFIL USER' "$MEM" | sed 's/^/  /'
      exit 0
    fi
    p "  ▸ profil belum ada — default B/D2. DEV isi otomatis saat sinyal user jelas." 214
    exit 0
    ;;
  set)
    T="${2:-B}"; D="${3:-D2}"
    echo "$T" | grep -qE '^[ABC]$' && echo "$D" | grep -qE '^D[123]' || { p "  ✖ pakai: set <A|B|C> <D1|D2|D3>" 196; exit 2; }
    if grep -q 'PROFIL USER' "$MEM" 2>/dev/null; then
      sed -i.bak-profile "s/^PROFIL USER.*/PROFIL USER: $T\/$D ($(date +%F))/" "$MEM" && rm -f "$MEM.bak-profile"
      p "  ✔ profil diperbarui: $T/$D" 82
    else
      printf '\n## PROFIL USER: %s/%s (%s)\n' "$T" "$D" "$(date +%F)" >> "$MEM"
      p "  ✔ profil dibuat: $T/$D" 82
    fi
    exit 0
    ;;
  *) p "  ✖ pakai: show | set <A|B|C> <D1|D2|D3>" 196; exit 2 ;;
esac
