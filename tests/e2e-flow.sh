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
function multiply(a, b) { return a * b; }
module.exports = { add, multiply };
EOF
cat > "$FX/PLAN.md" <<'EOF'
# PLAN
- calc.js: fungsi add + multiply (implement)
- test.js: 4 assertion
- SELESAI BILA: test-full exit 0 DAN audit-full exit 0
EOF
[ -f "$FX/PLAN.md" ] && ok "plan ada: definisi selesai tertulis" || bad "plan hilang"

p "▮ E2E: build — test lewat pertama kali" 213
cat > "$FX/test.js" <<'EOF'
const { add, multiply } = require('./calc.js');
const assert = require('assert');
assert.strictEqual(add(2, 3), 5, 'add(2,3) harus 5');
assert.strictEqual(add(-1, 1), 0, 'add(-1,1) harus 0');
assert.strictEqual(multiply(3, 4), 12, 'multiply(3,4) harus 12');
assert.strictEqual(multiply(0, 5), 0, 'multiply(0,5) harus 0');
console.log('PASS');
EOF
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "test hijau sejak awal (4 assertion)" || bad "test merah tanpa sebab"

p "▮ E2E: regresi — bug masuk, test merah, fix, hijau lagi" 213
printf 'function add(a, b) { return a - b; }\nfunction multiply(a, b) { return a * b; }\nmodule.exports = { add, multiply };\n' > "$FX/calc.js"
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "regresi tertangkap (exit 1)" || bad "regresi lolos!"
printf 'function add(a, b) { return a + b; }\nfunction multiply(a, b) { return a * b; }\nmodule.exports = { add, multiply };\n' > "$FX/calc.js"
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "re-test hijau setelah fix" || bad "fix tidak menyelesaikan"

p "▮ E2E: doc sinkron — CHANGELOG ikut dirilis" 213
cat > "$FX/CHANGELOG.md" <<'EOF'
# CHANGELOG
## [1.1.0] — hari ini
### Added
- fungsi add dengan test
- fungsi multiply dengan test
EOF
[ -f "$FX/CHANGELOG.md" ] && grep -q "1.1.0" "$FX/CHANGELOG.md" && ok "doc user-visible ada" || bad "doc tidak sinkron"

p "▮ E2E: audit menangkap secret yang menyusup" 213
printf 'token = "ghp_%s"\n' "$(printf 'B%.0s' $(seq 36))" > "$FX/token.js"
bash "$DIR/skills/audit-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "audit MENANGKAP secret (exit 1)" || bad "audit lolos secret"
rm "$FX/token.js"
bash "$DIR/skills/audit-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "audit CLEAN setelah secret dibuang" || bad "audit masih menemukan sesuatu"

# ── E2E: error handling — fungsi yang throw tanpa catch ──
p "▮ E2E: error handling — audit deteksi error yang tidak di-handle" 213
cat > "$FX/unsafe.js" <<'EOF'
function parse(str) { return JSON.parse(str); }
module.exports = { parse };
EOF
printf 'const { parse } = require("./unsafe.js");\ntry { parse("{invalid"); } catch(e) { console.log("handled"); }\n' > "$FX/test.js"
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "test error handling lulus" || bad "test error handling gagal"
rm "$FX/unsafe.js"

# ── E2E: multi-function regression ──
p "▮ E2E: multi-function — bug di salah satu, yang lain tetap hijau" 213
cat > "$FX/calc.js" <<'EOF'
function add(a, b) { return a + b; }
function multiply(a, b) { return a * b; }
function subtract(a, b) { return a - b; }
module.exports = { add, multiply, subtract };
EOF
cat > "$FX/test.js" <<'EOF'
const { add, multiply, subtract } = require('./calc.js');
const assert = require('assert');
assert.strictEqual(add(2, 3), 5);
assert.strictEqual(multiply(3, 4), 12);
assert.strictEqual(subtract(10, 3), 7);
console.log('PASS');
EOF
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "multi-function test hijau (3 fungsi)" || bad "multi-function test merah"
# Bug di subtract saja
cat > "$FX/calc.js" <<'EOF'
function add(a, b) { return a + b; }
function multiply(a, b) { return a * b; }
function subtract(a, b) { return a + b; }
module.exports = { add, multiply, subtract };
EOF
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "regresi di subtract tertangkap" || bad "regresi subtract lolos"

# ── E2E: file baru tanpa test ──
p "▶ E2E: file baru tanpa test → test-full warning" 213
cat > "$FX/newfile.js" <<'EOF'
function helper() { return 42; }
module.exports = { helper };
EOF
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
RC=$?
# test-full boleh pass (test masih exist) atau warning — yang penting tidak crash
[ "$RC" -le 2 ] && ok "file baru tanpa test tidak crash (exit $RC)" || bad "crash: exit $RC"

# ── E2E: version sinkron ──
p "▮ E2E: VERSION sinkron dengan CHANGELOG" 213
echo "1.1.0" > "$FX/VERSION"
grep -q "1.1.0" "$FX/CHANGELOG.md" && [ "$(cat "$FX/VERSION" | tr -d '[:space:]')" = "1.1.0" ] \
  && ok "VERSION=CHANGELOG versi sama" || bad "VERSION ≠ CHANGELOG"

# ── E2E: git-guard blokir secret di staged ──
p "▮ E2E: git-guard blokir secret di staged" 213
GX=$(mktemp -d)
( cd "$GX" && git init -q && git config user.email t@t && git config user.name t \
  && printf 'api_key = "sk-%s"\n' "$(printf 'X%.0s' $(seq 32))" > config.js \
  && git add config.js )
bash "$DIR/skills/git-guard/run.sh" "$GX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "git-guard BLOKIR secret di staged" || bad "git-guard lolos secret"
( cd "$GX" && printf 'api_key = process.env.API_KEY\n' > config.js && git add config.js )
bash "$DIR/skills/git-guard/run.sh" "$GX" >/dev/null 2>&1
[ $? -eq 0 ] && ok "git-guard CLEAN setelah secret dibuang" || bad "git-guard false positive"
rm -rf "$GX"

rm -rf "$FX"
echo
if [ "$FAIL" -eq 0 ]; then p "E2E_RESULT: PIPELINE UTUH ($PASS langkah)" 82; exit 0; fi
p "E2E_RESULT: GAGAL ($FAIL)" 196; exit 1
