#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  RUN-DEMO — buktikan pipeline DEV-BRAIN hidup, 60 detik.
#  Membangunkan project fixture dengan bug disengaja, lalu
#  test-full menangkapnya, fixer-style script memperbaiki,
#  test hijau, audit CLEAN.
#  Jalankan: bash tests/run-demo.sh
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
PASS=0; FAIL=0
ok(){ p "  ✔ $1" 82; PASS=$((PASS+1)); }
bad(){ p "  ✖ $1" 196; FAIL=$((FAIL+1)); }

p "▮ DEMO: bangun project fixture dengan bug disengaja" 213
FX=$(mktemp -d)
cat > "$FX/package.json" <<'EOF'
{
  "name": "demo-app",
  "version": "1.0.0",
  "scripts": {
    "test": "node test.js"
  }
}
EOF
cat > "$FX/test.js" <<'EOF'
// test pembuktian: add() harus benar
const { add } = require('./calc.js');
const assert = require('assert');
assert.strictEqual(add(2, 3), 5, 'add(2,3) harus 5');
assert.strictEqual(add(-1, 1), 0, 'add(-1,1) harus 0');
console.log('PASS: semua test lulus');
EOF
cat > "$FX/calc.js" <<'EOF'
// BUG SENGAJA: penjumlahan salah (akar masalah demo)
function add(a, b) { return a - b; }
module.exports = { add };
EOF
ok "fixture siap: calc.js + test.js (2 assertion)"

p "▮ DEMO 1: test-full MENANGKAP bug" 213
OUT=$(bash "$DIR/skills/test-full/run.sh" "$FX" 2>&1)
[ $? -eq 1 ] && ok "test MERAH — bug terdeteksi (exit 1)" || bad "test-full gagal menangkap bug"
echo "$OUT" | grep -q "FAIL" && ok "output jelas: TEST_RESULT: FAIL" || bad "output tidak jelas"

p "▮ DEMO 2: fixer-style script perbaiki akar masalah" 213
cat > "$FX/calc.js" <<'EOF'
// FIX: penjumlahan benar (akar masalah, bukan tambal sulam)
function add(a, b) { return a + b; }
module.exports = { add };
EOF
ok "calc.js diperbaiki: return a - b → a + b (akar masalah)"

p "▮ DEMO 3: re-test HIJAU" 213
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "test HIJAU — 2/2 PASS" || bad "test masih merah"

p "▮ DEMO 4: audit-full CLEAN" 213
bash "$DIR/skills/audit-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "audit CLEAN — tanpa secret, tanpa masalah" || bad "audit menemukan masalah"

rm -rf "$FX"
echo
if [ "$FAIL" -eq 0 ]; then p "DEMO_RESULT: PIPELINE TERBUKTI ($PASS langkah)" 82; exit 0; fi
p "DEMO_RESULT: GAGAL ($FAIL)" 196; exit 1
