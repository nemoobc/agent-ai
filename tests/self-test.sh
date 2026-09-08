#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  SELF-TEST — buktikan detektor mendeteksi, bukan cuma jalan.
#  Jalankan dari mana saja: bash tests/self-test.sh
#  Exit 0 = PASS, 1 = FAIL
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
PASS=0; FAIL=0
ok(){ p "  ✔ $1" 82; PASS=$((PASS+1)); }
bad(){ p "  ✖ $1" 196; FAIL=$((FAIL+1)); }

p "▮ SELF-TEST: syntax semua script" 213
for s in "$DIR"/install.sh "$DIR"/skills/*/run.sh; do
  bash -n "$s" 2>/dev/null && ok "bash -n $(basename "$s")" || bad "bash -n $(basename "$s")"
done

p "▮ SELF-TEST: dokumentasi skill punya command jalan" 213
for sk in audit-full test-full fix-full; do
  grep -q "skill/$sk/run.sh" "$DIR/skills/$sk/SKILL.md" \
    && ok "$sk/SKILL.md ada command" || bad "$sk/SKILL.md tanpa command"
done

p "▮ SELF-TEST: audit-full nangkep secret palsu" 213
FX=$(mktemp -d)
printf 'token = "ghp_%s"\n' "$(printf 'A%.0s' $(seq 36))" > "$FX/app.py"
bash "$DIR/skills/audit-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "audit-full exit 1 di project dengan secret" || bad "audit-full lolos secret palsu"

p "▮ SELF-TEST: test-full exit 2 di project tanpa test" 213
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 2 ] && ok "test-full NO-TESTS terdeteksi (exit 2)" || bad "test-full exit code salah"

p "▮ SELF-TEST: test-full nangkep test gagal" 213
printf '{"name":"t","version":"1.0.0","scripts":{"test":"node -e \\"process.exit(1)\\""}}\n' > "$FX/package.json"
bash "$DIR/skills/test-full/run.sh" "$FX" >/dev/null 2>&1
[ $? -eq 1 ] && ok "test-full exit 1 saat test gagal" || bad "test-full tidak menangkap test gagal"

p "▮ SELF-TEST: npm audit tidak false-positive di project sehat" 213
if ( cd "$FX" && npm audit --omit=dev >/dev/null 2>&1 ); then
  bash "$DIR/skills/audit-full/run.sh" "$FX" 2>/dev/null | grep -q "kerentanan dependensi" \
    && bad "project sehat keflag kerentanan" || ok "project sehat tidak keflag"
else
  p "  ⚠ npm audit offline/tanpa lockfile — kasus ini dilewati" 214
fi

p "▮ SELF-TEST: struktur kit lengkap" 213
NSKILL=$(ls -1d "$DIR"/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
NCMD=$(ls -1 "$DIR"/command/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$NSKILL" -eq 45 ] && ok "45 skill terdeteksi ($NSKILL)" || bad "jumlah skill = $NSKILL, harusnya 45"
[ "$NCMD" -eq 23 ] && ok "23 command terdeteksi" || bad "jumlah command = $NCMD, harusnya 23"
[ -f "$DIR/VERSION" ] && ok "VERSION ada" || bad "VERSION hilang"
[ -f "$DIR/CHANGELOG.md" ] && ok "CHANGELOG ada" || bad "CHANGELOG hilang"
[ -f "$DIR/LICENSE" ] && ok "LICENSE ada" || bad "LICENSE hilang"
for s in scan plan debug doc-full doctor review refactor cost perf explain i18n changelog caveman-warmup learn milestone test-design api-design migrate postmortem spec research red-team team autonomy metrics handoff a11y context pr git-guard env-guard backup dependency hotfix recovery convention coverage; do
  [ -f "$DIR/skills/$s/SKILL.md" ] && ok "skill $s ada" || bad "skill $s hilang"
done
[ -f "$DIR/skills/doctor/run.sh" ] && ok "doctor/run.sh ada" || bad "doctor/run.sh hilang"
[ -f "$DIR/.github/workflows/release.yml" ] && ok "release workflow ada" || bad "release workflow hilang"
[ -f "$DIR/tests/run-demo.sh" ] && ok "demo script ada" || bad "demo script hilang"
[ -f "$DIR/tests/e2e-flow.sh" ] && ok "e2e script ada" || bad "e2e script hilang"
[ -f "$DIR/docs/USAGE.md" ] && ok "docs/USAGE.md ada" || bad "docs/USAGE.md hilang"
[ -f "$DIR/docs/PLAYBOOKS.md" ] && ok "docs/PLAYBOOKS.md ada" || bad "docs/PLAYBOOKS.md hilang"
[ -f "$DIR/README.en.md" ] && ok "README.en.md ada" || bad "README.en.md hilang"
[ -f "$DIR/memory/archive.md" ] && ok "memory/archive.md ada" || bad "memory/archive.md hilang"
[ -f "$DIR/skills/git-guard/run.sh" ] && ok "git-guard/run.sh ada" || bad "git-guard/run.sh hilang"
[ -f "$DIR/skills/metrics/run.sh" ] && ok "metrics/run.sh ada" || bad "metrics/run.sh hilang"
grep -q 'HUKUM 8' "$DIR/AGENTS.md" && ok "AGENTS.md punya HUKUM 8 (konteks)" || bad "HUKUM 8 hilang"
[ -f "$DIR/tests/lint-kit.sh" ] && ok "tests/lint-kit.sh ada" || bad "tests/lint-kit.sh hilang"
[ -f "$DIR/tests/test-update.sh" ] && ok "tests/test-update.sh ada" || bad "tests/test-update.sh hilang"
[ -f "$DIR/skills/scan/run.sh" ] && ok "scan/run.sh ada" || bad "scan/run.sh hilang"
[ -f "$DIR/skills/changelog/run.sh" ] && ok "changelog/run.sh ada" || bad "changelog/run.sh hilang"
[ -f "$DIR/skills/env-guard/run.sh" ] && ok "env-guard/run.sh ada" || bad "env-guard/run.sh hilang"
[ -f "$DIR/skills/backup/run.sh" ] && ok "backup/run.sh ada" || bad "backup/run.sh hilang"
[ -f "$DIR/skills/coverage/run.sh" ] && ok "coverage/run.sh ada" || bad "coverage/run.sh hilang"
[ -f "$DIR/tests/mutation.sh" ] && ok "tests/mutation.sh ada" || bad "tests/mutation.sh hilang"
[ -f "$DIR/tests/bench.sh" ] && ok "tests/bench.sh ada" || bad "tests/bench.sh hilang"
[ -f "$DIR/Makefile" ] && ok "Makefile ada" || bad "Makefile hilang"
[ -f "$DIR/docs/ARCHITECTURE.md" ] && ok "docs/ARCHITECTURE.md ada" || bad "docs/ARCHITECTURE.md hilang"
[ -f "$DIR/docs/ROADMAP.md" ] && ok "docs/ROADMAP.md ada" || bad "docs/ROADMAP.md hilang"
grep -q 'HUKUM 9' "$DIR/AGENTS.md" && ok "AGENTS.md punya HUKUM 9 (verifikasi)" || bad "HUKUM 9 hilang"
grep -q 'HUKUM 10' "$DIR/AGENTS.md" && ok "AGENTS.md punya HUKUM 10 (konsistensi)" || bad "HUKUM 10 hilang"
grep -q 'TITIK-PUTUS' "$DIR/agents/dev.md" && ok "dev.md lapor 3 status" || bad "dev.md tanpa TITIK-PUTUS"
# lessons.md + recall/remember mengenal lessons
for s in recall remember; do
  grep -q 'lessons.md' "$DIR/skills/$s/SKILL.md" && ok "$s tahu lessons.md" || bad "$s tidak tahu lessons.md"
done
for c in roadmap report bootstrap status learn release onboard backlog handoff metrics team pr context upgrade verify hotfix coverage blame; do
  [ -f "$DIR/command/$c.md" ] && ok "command $c ada" || bad "command $c hilang"
done
[ -f "$DIR/memory/lessons.md" ] && ok "memory/lessons.md ada" || bad "memory/lessons.md hilang"
[ -f "$DIR/CONTRIBUTING.md" ] && ok "CONTRIBUTING.md ada" || bad "CONTRIBUTING.md hilang"
[ -f "$DIR/.gitignore" ] && ok ".gitignore ada" || bad ".gitignore hilang"
[ -f "$DIR/.github/PULL_REQUEST_TEMPLATE.md" ] && ok "PR template ada" || bad "PR template hilang"
[ -f "$DIR/.github/ISSUE_TEMPLATE/bug.md" ] && ok "issue template bug ada" || bad "issue template bug hilang"
[ -f "$DIR/.github/ISSUE_TEMPLATE/feature.md" ] && ok "issue template feature ada" || bad "issue template feature hilang"
[ -f "$DIR/skills/learn/SKILL.md" ] && grep -q 'lessons.md' "$DIR/skills/learn/SKILL.md" && ok "learn menunjuk lessons.md" || bad "learn tidak menunjuk lessons.md"

p "▮ SELF-TEST: badge README sinkron dengan isi repo" 213
NAGENT=$(ls -1 "$DIR"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
BSKILL=$(grep -oE 'SKILLS-[0-9]+' "$DIR/README.md" | grep -oE '[0-9]+')
BAGENT=$(grep -oE 'AGENTS-[0-9]+' "$DIR/README.md" | grep -oE '[0-9]+')
BCMD=$(grep -oE 'COMMANDS-[0-9]+' "$DIR/README.md" | grep -oE '[0-9]+')
[ "$BAGENT" = "$NAGENT" ] && ok "badge AGENTS=$BAGENT cocok" || bad "badge AGENTS=$BAGENT ≠ $NAGENT"
[ "$BSKILL" = "$NSKILL" ] && ok "badge SKILLS=$BSKILL cocok" || bad "badge SKILLS=$BSKILL ≠ $NSKILL"
[ "$BCMD" = "$NCMD" ] && ok "badge COMMANDS=$BCMD cocok" || bad "badge COMMANDS=$BCMD ≠ $NCMD"
BVER=$(grep -oE 'VERSION-[0-9.]+' "$DIR/README.md" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
VFILE=$(tr -d '[:space:]' < "$DIR/VERSION" 2>/dev/null)
[ -n "$BVER" ] && [ "$BVER" = "$VFILE" ] && ok "badge VERSION=$BVER cocok" || bad "badge VERSION=$BVER ≠ file VERSION=$VFILE"

p "▮ SELF-TEST: doctor exit code valid" 213
bash "$DIR/skills/doctor/run.sh" . >/dev/null 2>&1
[ $? -eq 0 ] && ok "doctor SEHAT di kit sendiri" || bad "doctor gagal di kit sendiri"

p "▮ SELF-TEST: mutation + bench siap jalan (tidak rekursif)" 213
# mutation menjalankan self-test pada SALINAN repo — jadi self-test tidak boleh
# memanggil mutation/bench penuh (loop tak hingga). Cukup verifikasi ada + syntax.
bash -n "$DIR/tests/mutation.sh" && bash -n "$DIR/tests/bench.sh" \
  && ok "mutation.sh + bench.sh syntax OK (dijalankan terpisah di make verify/CI)" \
  || bad "mutation.sh/bench.sh syntax rusak"

p "▮ SELF-TEST: git-guard blokir secret di staged diff" 213
GH=$(mktemp -d)
( cd "$GH" && git init -q && git config user.email t@t && git config user.name t \
  && printf 'api_key = "sk-%s"\n' "$(printf 'A%.0s' $(seq 30))" > app.py \
  && git add app.py )
bash "$DIR/skills/git-guard/run.sh" "$GH" >/dev/null 2>&1
[ $? -eq 1 ] && ok "git-guard BLOKIR secret" || bad "git-guard lolos secret"
( cd "$GH" && printf 'api_key = os.environ["K"]\n' > app.py && git add app.py )
bash "$DIR/skills/git-guard/run.sh" "$GH" >/dev/null 2>&1
[ $? -eq 0 ] && ok "git-guard CLEAN setelah secret dibuang" || bad "git-guard false positive"
rm -rf "$GH"

p "▮ SELF-TEST: metrics/run.sh jalan" 213
bash "$DIR/skills/metrics/run.sh" "$DIR" >/dev/null 2>&1
[ $? -eq 0 ] && ok "metrics/run.sh exit 0" || bad "metrics/run.sh gagal"

p "▮ SELF-TEST: backup/restore opencode.json user" 213
FH=$(mktemp -d)
mkdir -p "$FH/.config/opencode"
printf '{\n  "theme": "dark"\n}\n' > "$FH/.config/opencode/opencode.json"
# --offline: install deterministik, tanpa cek jaringan — shell agent tidak menggantung
HOME="$FH" bash "$DIR/install.sh" --offline >/dev/null 2>&1 \
  && grep -q devbrain "$FH/.config/opencode/opencode.json" \
  && ls "$FH/.config/opencode/"opencode.json.bak.* >/dev/null 2>&1 \
  && HOME="$FH" bash "$DIR/install.sh" --uninstall >/dev/null 2>&1 \
  && grep -q '"theme": "dark"' "$FH/.config/opencode/opencode.json" \
  && ok "user config dibackup lalu direstore saat uninstall" \
  || bad "backup/restore user config gagal"
rm -rf "$FH"

rm -rf "$FX"
echo
if [ "$FAIL" -eq 0 ]; then p "SELF_TEST: PASS ($PASS ok)" 82; exit 0; fi
p "SELF_TEST: FAIL ($FAIL gagal)" 196; exit 1
