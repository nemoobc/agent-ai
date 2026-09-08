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
[ "$NSKILL" -eq 12 ] && ok "12 skill terdeteksi ($NSKILL)" || bad "jumlah skill = $NSKILL, harusnya 12"
[ "$NCMD" -eq 4 ] && ok "4 command terdeteksi" || bad "jumlah command = $NCMD, harusnya 4"
[ -f "$DIR/VERSION" ] && ok "VERSION ada" || bad "VERSION hilang"
[ -f "$DIR/CHANGELOG.md" ] && ok "CHANGELOG ada" || bad "CHANGELOG hilang"
[ -f "$DIR/LICENSE" ] && ok "LICENSE ada" || bad "LICENSE hilang"
for s in scan plan debug doc-full; do
  [ -f "$DIR/skills/$s/SKILL.md" ] && ok "skill $s ada" || bad "skill $s hilang"
done

p "▮ SELF-TEST: badge README sinkron dengan isi repo" 213
NAGENT=$(ls -1 "$DIR"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
BSKILL=$(grep -oE 'SKILLS-[0-9]+' "$DIR/README.md" | grep -oE '[0-9]+')
BAGENT=$(grep -oE 'AGENTS-[0-9]+' "$DIR/README.md" | grep -oE '[0-9]+')
BCMD=$(grep -oE 'COMMANDS-[0-9]+' "$DIR/README.md" | grep -oE '[0-9]+')
[ "$BAGENT" = "$NAGENT" ] && ok "badge AGENTS=$BAGENT cocok" || bad "badge AGENTS=$BAGENT ≠ $NAGENT"
[ "$BSKILL" = "$NSKILL" ] && ok "badge SKILLS=$BSKILL cocok" || bad "badge SKILLS=$BSKILL ≠ $NSKILL"
[ "$BCMD" = "$NCMD" ] && ok "badge COMMANDS=$BCMD cocok" || bad "badge COMMANDS=$BCMD ≠ $NCMD"

p "▮ SELF-TEST: backup/restore opencode.json user" 213
FH=$(mktemp -d)
mkdir -p "$FH/.config/opencode"
printf '{\n  "theme": "dark"\n}\n' > "$FH/.config/opencode/opencode.json"
HOME="$FH" bash "$DIR/install.sh" >/dev/null 2>&1 \
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
