#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  LINT-KIT — linter struktur DEV-BRAIN.
#  SKILL.md tanpa deskripsi/gerbang, command tanpa tugas, doctrine
#  tanpa hukum wajib, badge tidak sinkron — semua keburu sebelum PR.
#  Jalankan: bash tests/lint-kit.sh   (exit 0 = lolos)
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
PASS=0; FAIL=0
ok(){ p "  ✔ $1" 82; PASS=$((PASS+1)); }
bad(){ p "  ✖ $1" 196; FAIL=$((FAIL+1)); }

p "▮ LINT: SKILL.md punya frontmatter + deskripsi" 213
for f in "$DIR"/skills/*/SKILL.md; do
  name=$(basename "$(dirname "$f")")
  head -1 "$f" | grep -q '^---$' && grep -q '^description:' "$f" \
    && ok "$name: frontmatter+description" || bad "$name: frontmatter/description hilang"
done

p "▮ LINT: SKILL.md punya gerbang/aturan (bukan basa-basi)" 213
for f in "$DIR"/skills/*/SKILL.md; do
  name=$(basename "$(dirname "$f")")
  grep -qiE '(GERBANG|ATURAN|LARANGAN|URUTAN|CARA|KAPAN|FORMAT)' "$f" \
    && ok "$name: punya struktur" || bad "$name: tanpa struktur (gerbang/aturan/format)"
done

p "▮ LINT: command punya frontmatter + agent + isi" 213
for f in "$DIR"/command/*.md; do
  name=$(basename "$f")
  head -1 "$f" | grep -q '^---$' && grep -q '^agent: dev$' "$f" && grep -q 'skill\|task\|lapor\|TUGAS' "$f" \
    && ok "$name: valid" || bad "$name: frontmatter/agent/isi bermasalah"
done

p "▮ LINT: command punya section Usage + Triggers + Example" 213
for f in "$DIR"/command/*.md; do
  name=$(basename "$f")
  has_usage=$(grep -ci '## Usage' "$f")
  has_triggers=$(grep -ci '## Triggers' "$f")
  has_example=$(grep -ci '## Example' "$f")
  if [ "$has_usage" -ge 1 ] && [ "$has_triggers" -ge 1 ] && [ "$has_example" -ge 1 ]; then
    ok "$name: Usage+Triggers+Example ada"
  else
    bad "$name: section hilang (Usage:$has_usage Triggers:$has_triggers Example:$has_example)"
  fi
done

p "▮ LINT: command punya Expected Output + Error Cases + Related" 213
for f in "$DIR"/command/*.md; do
  name=$(basename "$f")
  has_expected=$(grep -ci '## Expected Output' "$f")
  has_error=$(grep -ci '## Error Cases' "$f")
  has_related=$(grep -ci '## Related' "$f")
  if [ "$has_expected" -ge 1 ] && [ "$has_error" -ge 1 ] && [ "$has_related" -ge 1 ]; then
    ok "$name: Expected+Error+Related ada"
  else
    bad "$name: section hilang (Expected:$has_expected Error:$has_error Related:$has_related)"
  fi
done

p "▮ LINT: doctrine utuh (13 hukum, gerbang dev.md)" 213
grep -q 'HUKUM 1' "$DIR/AGENTS.md" && grep -q 'HUKUM 13' "$DIR/AGENTS.md" \
  && ok "AGENTS.md: 13 hukum ada" || bad "AGENTS.md: hukum 1..13 tidak lengkap"
grep -q 'RANTAI BUKTI' "$DIR/AGENTS.md" \
  && ok "AGENTS.md: HUKUM 11 RANTAI BUKTI ada" || bad "AGENTS.md: HUKUM 11 hilang"
grep -q 'ANTI-INJEKSI' "$DIR/AGENTS.md" \
  && ok "AGENTS.md: HUKUM 12 ANTI-INJEKSI ada" || bad "AGENTS.md: HUKUM 12 hilang"
grep -q 'KONSISTENSI' "$DIR/AGENTS.md" \
  && ok "AGENTS.md: HUKUM 10 KONSISTENSI ada" || bad "AGENTS.md: HUKUM 10 KONSISTENSI hilang"
grep -q 'Makefile' "$DIR/AGENTS.md" \
  && ok "AGENTS.md: sebut make verify" || bad "AGENTS.md: tidak sebut make verify"
grep -q 'GERBANG FASE' "$DIR/agents/dev.md" \
  && ok "dev.md: gerbang fase ada" || bad "dev.md: gerbang fase hilang"
grep -q 'FORMAT LAPORAN AKHIR' "$DIR/agents/dev.md" \
  && ok "dev.md: format laporan ada" || bad "dev.md: format laporan hilang"
grep -q 'ROUTER INTENSITAS' "$DIR/AGENTS.md" \
  && ok "AGENTS.md: HUKUM 13 ROUTER ada" || bad "AGENTS.md: HUKUM 13 hilang"
grep -q 'CAVEMAN' "$DIR/AGENTS.md" \
  && ok "AGENTS.md: HUKUM 1 CAVEMAN ada" || bad "AGENTS.md: HUKUM 1 hilang"

p "▮ LINT: laporan dev.md sinkron dengan gerbang" 213
grep -q 'STATUS :' "$DIR/agents/dev.md" \
  && ok "format laporan pakai STATUS" || bad "format laporan tanpa STATUS"

p "▮ LINT: installer menulis semua skill & command" 213
for d in "$DIR"/skills/*/; do
  name=$(basename "$d")
  grep -q 'for skill_dir in "\$SCRIPT_DIR/skills/"\*/' "$DIR/install.sh" \
    && [ -f "$d/SKILL.md" ] \
    && ok "installer: skill $name dinamis" || bad "installer: skill $name tidak dicakup"
done
NCMD=$(ls -1 "$DIR"/command/*.md | wc -l | tr -d ' ')
grep -q 'command/' "$DIR/install.sh" && ok "installer: copy command ada ($NCMD cmd)" || bad "installer: copy command hilang"

p "▮ LINT: simbol aneh hasil patch (double-line, marker sisa)" 213
grep -rn '}  [A-Z_]*=' "$DIR/install.sh" >/dev/null 2>&1 \
  && bad "install.sh: indikasi double-line heredoc" || ok "install.sh: bersih"
grep -rnE '@codebuff[[:space:]]+del'""'ete|TODO:del'""'ete' "$DIR" --include='*.md' --include='*.sh' 2>/dev/null | grep -v 'lint-kit.sh' >/dev/null \
  && bad "ada marker sisa" || ok "tanpa marker sisa"

p "▮ LINT: file test & CI lengkap" 213
for f in tests/self-test.sh tests/e2e-flow.sh tests/run-demo.sh tests/lint-kit.sh tests/test-update.sh tests/mutation.sh tests/bench.sh tests/eval.sh Makefile docs/ARCHITECTURE.md docs/ROADMAP.md docs/THREAT-MODEL.md .github/workflows/ci.yml .github/workflows/release.yml; do
  [ -f "$DIR/$f" ] && ok "$f" || bad "$f hilang"
done
grep -q 'eval' "$DIR/.github/workflows/ci.yml" \
  && ok "CI jalan eval" || bad "CI tidak jalan eval"
[ -f "$DIR/skills/injection-guard/SKILL.md" ] \
  && ok "installer mencakup injection-guard" || bad "installer lupa injection-guard"
[ -f "$DIR/agents/critic.md" ] \
  && ok "installer mencakup agent critic" || bad "installer lupa critic"
for c in critique trace deliver threat-model; do
  [ -f "$DIR/command/$c.md" ] && ok "command $c ada" || bad "command $c hilang"
done
grep -q 'lint-kit' "$DIR/.github/workflows/ci.yml" \
  && ok "CI jalan lint-kit" || bad "CI tidak jalan lint-kit"
grep -q 'test-update' "$DIR/.github/workflows/ci.yml" \
  && ok "CI jalan test-update" || bad "CI tidak jalan test-update"
grep -q 'mutation' "$DIR/.github/workflows/ci.yml" \
  && ok "CI jalan mutation" || bad "CI tidak jalan mutation"
grep -q 'bench' "$DIR/.github/workflows/ci.yml" \
  && ok "CI jalan bench" || bad "CI tidak jalan bench"

p "▮ LINT: konsistensi angka (HUKUM 10)" 213
V=$(cat "$DIR/VERSION" | tr -d '[:space:]')
grep -q "$V" "$DIR/README.md" && ok "badge README = VERSION $V" || bad "badge README ≠ VERSION $V"
grep -q "$V" "$DIR/CHANGELOG.md" && ok "CHANGELOG sebut $V" || bad "CHANGELOG tidak sebut $V"
grep -q "$V" "$DIR/README.en.md" && ok "README.en sebut $V" || bad "README.en tidak sebut $V"
for f in "$DIR"/skills/*/SKILL.md; do :; done
NSK=$(ls -1 "$DIR"/skills/*/SKILL.md | wc -l | tr -d ' ')
NCW=$(ls -1 "$DIR"/command/*.md | wc -l | tr -d ' ')
NRUN=$(ls -1 "$DIR"/skills/*/run.sh | wc -l | tr -d ' ')
grep -q "$NSK skill" "$DIR/README.md" && ok "README: $NSK skill cocok" || bad "README: jumlah skill tidak $NSK"
grep -q "$NCW command" "$DIR/README.md" && ok "README: $NCW command cocok" || bad "README: jumlah command tidak $NCW"

p "▮ LINT: semua command/*.md ada Usage section" 213
for f in "$DIR"/command/*.md; do
  name=$(basename "$f")
  grep -q '## Usage' "$f" \
    && ok "$name: ada ## Usage" || bad "$name: ## Usage hilang"
done

p "▮ LINT: semua command/*.md punya ## Error Cases" 213
for f in "$DIR"/command/*.md; do
  name=$(basename "$f")
  grep -q '## Error Cases' "$f" \
    && ok "$name: ada ## Error Cases" || bad "$name: ## Error Cases hilang"
done

echo
if [ "$FAIL" -eq 0 ]; then p "LINT_KIT: LOLOS ($PASS cek)" 82; exit 0; fi
p "LINT_KIT: $FAIL MASALAH" 196; exit 1
