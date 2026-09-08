#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  E2E-FLOW — simulasi alur agent DEV-BRAIN ujung-ke-ujung.
#  Sama seperti run-demo (bug→merah→fix→hijau), plus:
#  plan file, doc sinkron, dan audit menangkap secret yang masuk.
#  Buktikan PIPELINE, bukan cuma detektor tunggal.
#  Jalankan: bash tests/e2e-flow.sh   (exit 0 = PASS)
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
PASS=0; FAIL=0
ok(){ p "  ✔ $1" 82; PASS=$((PASS+1)); }
bad(){ p "  ✖ $1" 196; FAIL=$((FAIL+1)); }

p "▮ E2E: think+plan — fixture & rencana" 213
FX=$(mktemp -d)
cat > "$FX/package.json" <<'EOF'
{
  "name": "e2e-app",
  "version": "1.0.0",
  "scripts": { "test": "node test.js" }
}
EOF
cat > "$FX/calc.js" <<'EOF'
function add(a, b) { return a + b; }
module.exports = { add };
EOF
cat > "$FX/PLAN.md" <<'EOF'
# PLAN
- calc.js: fungsi add (implement)
- test.js: 2 assertion
- SELESAI BILA: test-full exit 0 DAN audit-full exit 0
EOF
[ -f "$FX/PLAN.md" ] && ok "plan ada: definisi selesai tertulis" || bad "plan hilang"

p "▮ E2E: build — test lewat pertama kali" 213
cat > "$FX/test.js" <<'EOF'
const { add } = require('./calc.js');
const assert = require('assert');
assert.strictEqual(add(2, 3), 5);
assert.strictEqual(add(-1, 1), 0);
console.log('PASS');
EOF
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "test hijau sejak awal" || bad "test merah tanpa sebab"

p "▮ E2E: regresi — bug masuk, test merah, fix, hijau lagi" 213
printf 'function add(a, b) { return a - b; }\nmodule.exports = { add };\n' > "$FX/calc.js"
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "regresi tertangkap (exit 1)" || bad "regresi lolos!"
printf 'function add(a, b) { return a + b; }\nmodule.exports = { add };\n' > "$FX/calc.js"
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "re-test hijau setelah fix" || bad "fix tidak menyelesaikan"

p "▮ E2E: doc sinkron — CHANGELOG ikut dirilis" 213
cat > "$FX/CHANGELOG.md" <<'EOF'
# CHANGELOG
## [1.1.0] — hari ini
### Added
- fungsi add dengan test
EOF
[ -f "$FX/CHANGELOG.md" ] && grep -q "1.1.0" "$FX/CHANGELOG.md" && ok "doc user-visible ada" || bad "doc tidak sinkron"

p "▮ E2E: audit menangkap secret yang menyusup" 213
printf 'token = "ghp_%s"\n' "$(printf 'B%.0s' $(seq 36))" > "$FX/token.js"
bash "$DIR/skills/audit-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "audit MENANGKAP secret (exit 1)" || bad "audit lolos secret"
rm "$FX/token.js"
bash "$DIR/skills/audit-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "audit CLEAN setelah secret dibuang" || bad "audit masih menemukan sesuatu"

rm -rf "$FX"
echo
if [ "$FAIL" -eq 0 ]; then p "E2E_RESULT: PIPELINE UTUH ($PASS langkah)" 82; exit 0; fi
p "E2E_RESULT: GAGAL ($FAIL)" 196; exit 1
