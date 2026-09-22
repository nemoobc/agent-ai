#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  WEB-SYNC — cek data.json sinkron dengan kit:
#  version = VERSION, skills = 64, commands = 40.
#  Jalankan: bash tests/web-sync.sh
#  Exit 0 = sinkron, 1 = drift.
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
PASS=0; FAIL=0
ok(){ p "  ✔ $1" 82; PASS=$((PASS+1)); }
bad(){ p "  ✖ $1" 196; FAIL=$((FAIL+1)); }

command -v node >/dev/null 2>&1 || { p "  ✖ butuh node (npm install nodejs)" 196; exit 1; }

# Generate data.json dari kit
node "$DIR/web/build.js" 2>/dev/null
[ -f "$DIR/web/data.json" ] && ok "data.json ter-generate" || bad "data.json gagal generate"

# Baca pakai node
VFILE=$(tr -d '[:space:]' < "$DIR/VERSION")
DSKILL=$(node -e "const d=require('$DIR/web/data.json'); console.log(d.skills.length)")
DCMD=$(node -e "const d=require('$DIR/web/data.json'); console.log(d.commands.length)")
DVER=$(node -e "const d=require('$DIR/web/data.json'); console.log(d.version)")

[ "$DVER" = "$VFILE" ] && ok "data.json version = $DVER" || bad "data.json version $DVER ≠ VERSION $VFILE"
[ "$DSKILL" -eq 64 ] && ok "data.json skills = $DSKILL" || bad "data.json skills = $DSKILL, harusnya 64"
[ "$DCMD" -eq 40 ] && ok "data.json commands = $DCMD" || bad "data.json commands = $DCMD, harusnya 40"

echo
if [ "$FAIL" -eq 0 ]; then p "WEB_SYNC: SINKRON ✓" 82; exit 0; fi
p "WEB_SYNC: $FAIL MASALAH" 196; exit 1
