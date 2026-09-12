#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  MUTATION — buktikan DETEKTOR mendeteksi perusakan.
#  Setiap perusakan disengaja → gate yang tepat WAJIB menangkap.
#  Gate yang tidak bisa menangkap perusakan = gate palsu (HUKUM 9/10).
#  Deterministik: tiap mutasi pakai SALINAN repo, repo asli tidak disentuh.
#  Jalankan: bash tests/mutation.sh   (exit 0 = semua perusakan tertangkap)
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
PASS=0; FAIL=0

MUT=$(mktemp -d)
cp -r "$DIR"/. "$MUT/repo" 2>/dev/null || cp -r "$DIR" "$MUT/repo"
rm -rf "$MUT/repo/.git"

run_gate(){ # $1=gate $2=dir; exit 0 kalau gate MENGANGGAP ada masalah
  case "$1" in
    lint)    (cd "$2" && bash tests/lint-kit.sh) >/dev/null 2>&1; [ $? -ne 0 ] ;;
    self)    (cd "$2" && bash tests/self-test.sh) >/dev/null 2>&1; [ $? -ne 0 ] ;;
    eval)    (cd "$2" && bash tests/eval.sh) >/dev/null 2>&1; [ $? -ne 0 ] ;;
    *)       return 1 ;;
  esac
}

expect_caught(){ # $1=nama $2=gate $3=alasan
  if run_gate "$2" "$MUT/repo"; then ok "$1 → gate $2 MENANGKAP ($3)"; PASS=$((PASS+1)); else bad "$1 → gate $2 LOLOS — detektor palsu!"; FAIL=$((FAIL+1)); fi
}

# ══ MUTASI 1-4: struktur kit ══
p "▮ MUTASI 1/15 — frontmatter skill hilang → lint" 213
rm -f "$MUT/repo/skills/think/SKILL.md"
printf '# THINK\nbasa-basi\n' > "$MUT/repo/skills/think/SKILL.md"
expect_caught "frontmatter skill hilang" lint "lint cek frontmatter"

p "▮ MUTASI 2/15 — badge SKILLS di README tua → self-test" 213
cp -r "$DIR"/. "$MUT/repo2" 2>/dev/null
rm -rf "$MUT/repo2/.git"
sed -i 's/SKILLS-[0-9]*/SKILLS-1/' "$MUT/repo2/README.md"
( cd "$MUT/repo2" && bash tests/self-test.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "badge SKILLS tua → self-test MENANGKAP"; PASS=$((PASS+1)); } || { bad "badge SKILLS tua → self-test LOLOS"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo2"

p "▮ MUTASI 3/15 — HUKUM 10 dihapus dari AGENTS.md → lint" 213
cp -r "$DIR"/. "$MUT/repo3" 2>/dev/null
rm -rf "$MUT/repo3/.git"
grep -v 'HUKUM 10' "$MUT/repo3/AGENTS.md" > "$MUT/agents.tmp" && mv "$MUT/agents.tmp" "$MUT/repo3/AGENTS.md"
expect_caught "HUKUM 10 dihapus" lint "lint cek 10 hukum"

p "▮ MUTASI 4/15 — hitungan self-test ngaco (63→9) → self-test" 213
cp -r "$DIR"/. "$MUT/repo4" 2>/dev/null
rm -rf "$MUT/repo4/.git"
sed -i 's/-eq 63 ]/-eq 9 ]/' "$MUT/repo4/tests/self-test.sh"
( cd "$MUT/repo4" && bash tests/self-test.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "hitungan 63→9 → self-test MENANGKAP"; PASS=$((PASS+1)); } || { bad "hitungan 63→9 → self-test LOLOS"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo4"

# ══ MUTASI 5-8: agent + command ══
p "▮ MUTASI 5/15 — command tanpa frontmatter agent → lint" 213
cp -r "$DIR"/. "$MUT/repo5" 2>/dev/null
rm -rf "$MUT/repo5/.git"
printf '# PALSU\nTugas: jalan saja.\n' > "$MUT/repo5/command/palsu.md"
expect_caught "command tanpa frontmatter" lint "lint cek command valid"

p "▮ MUTASI 6/15 — VERSION ≠ badge README → self-test" 213
cp -r "$DIR"/. "$MUT/repo6" 2>/dev/null
rm -rf "$MUT/repo6/.git"
printf '99.9.9\n' > "$MUT/repo6/VERSION"
( cd "$MUT/repo6" && bash tests/self-test.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "VERSION 99.9.9 ≠ badge → self-test MENANGKAP"; PASS=$((PASS+1)); } || { bad "VERSION nyasar → self-test LOLOS"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo6"

p "▮ MUTASI 7/15 — HUKUM 11 (rantai bukti) dihapus → lint" 213
cp -r "$DIR"/. "$MUT/repo7" 2>/dev/null; rm -rf "$MUT/repo7/.git"
grep -v 'RANTAI BUKTI' "$MUT/repo7/AGENTS.md" > "$MUT/a7" && mv "$MUT/a7" "$MUT/repo7/AGENTS.md"
expect_caught "HUKUM 11 dihapus" lint "lint cek rantai bukti"

p "▮ MUTASI 8/15 — HUKUM 12 (anti-injeksi) dihapus → lint" 213
cp -r "$DIR"/. "$MUT/repo8" 2>/dev/null; rm -rf "$MUT/repo8/.git"
grep -v 'ANTI-INJEKSI' "$MUT/repo8/AGENTS.md" > "$MUT/a8" && mv "$MUT/a8" "$MUT/repo8/AGENTS.md"
expect_caught "HUKUM 12 dihapus" lint "lint cek anti-injeksi"

# ══ MUTASI 9-12: skills kritis ══
p "▮ MUTASI 9/15 — injection-guard dibutakan (pola dihapus) → eval" 213
cp -r "$DIR"/. "$MUT/repo9" 2>/dev/null; rm -rf "$MUT/repo9/.git"
printf '#!/usr/bin/env bash\n# dibutakan\nexit 0\n' > "$MUT/repo9/skills/injection-guard/run.sh"
( cd "$MUT/repo9" && bash tests/eval.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "injection-guard buta → eval MENANGKAP"; PASS=$((PASS+1)); } || { bad "injection-guard buta lolos eval"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo9"

p "▮ MUTASI 10/15 — agent critic dihapus → lint" 213
cp -r "$DIR"/. "$MUT/repo10" 2>/dev/null; rm -rf "$MUT/repo10/.git"
rm -f "$MUT/repo10/agents/critic.md"
( cd "$MUT/repo10" && bash tests/self-test.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "agent critic dihapus → self-test MENANGKAP"; PASS=$((PASS+1)); } || { bad "critic dihapus lolos"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo10"

p "▮ MUTASI 11/15 — clean dibuat berbahaya (allowlist dibuang) → eval" 213
cp -r "$DIR"/. "$MUT/repo11" 2>/dev/null; rm -rf "$MUT/repo11/.git"
printf '#!/usr/bin/env bash\nrm -rf "${1:-.}"\nexit 0\n' > "$MUT/repo11/skills/clean/run.sh"
( cd "$MUT/repo11" && bash tests/eval.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "clean berbahaya → eval MENANGKAP"; PASS=$((PASS+1)); } || { bad "clean berbahaya lolos eval"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo11"

p "▮ MUTASI 12/15 — route dibikin selalu ULTRA (prompt biasa kena boros) → eval" 213
cp -r "$DIR"/. "$MUT/repo12" 2>/dev/null; rm -rf "$MUT/repo12/.git"
sed -i 's/^has_ultra=0$/has_ultra=1/' "$MUT/repo12/skills/route/run.sh"
grep -q 'has_ultra=1' "$MUT/repo12/skills/route/run.sh" || { echo "sabotase tak menempel" >&2; exit 2; }
( cd "$MUT/repo12" && bash tests/eval.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "route selalu-ULTRA → eval MENANGKAP"; PASS=$((PASS+1)); } || { bad "route selalu-ULTRA lolos eval (gate palsu)"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo12"

# ══ MUTASI 13-15: tambahan baru ══
p "▮ MUTASI 13/15 — doctor dibuat selalu merah (exit 1) → eval" 213
cp -r "$DIR"/. "$MUT/repo13" 2>/dev/null; rm -rf "$MUT/repo13/.git"
printf '#!/usr/bin/env bash\n# doctor palsu — selalu sakit\necho "SAKIT"\nexit 1\n' > "$MUT/repo13/skills/doctor/run.sh"
( cd "$MUT/repo13" && bash tests/eval.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "doctor selalu-merah → eval MENANGKAP"; PASS=$((PASS+1)); } || { bad "doctor selalu-merah lolos eval"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo13"

p "▮ MUTASI 14/15 — git-guard dibuat selalu exit 0 → eval" 213
cp -r "$DIR"/. "$MUT/repo14" 2>/dev/null; rm -rf "$MUT/repo14/.git"
printf '#!/usr/bin/env bash\n# git-guard palsu — selalu lolos\necho "CLEAN"\nexit 0\n' > "$MUT/repo14/skills/git-guard/run.sh"
( cd "$MUT/repo14" && bash tests/eval.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "git-guard palsu → eval MENANGKAP"; PASS=$((PASS+1)); } || { bad "git-guard palsu lolos eval"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo14"

p "▮ MUTASI 15/15 — HUKUM 13 (router intensitas) dihapus → lint" 213
cp -r "$DIR"/. "$MUT/repo15" 2>/dev/null; rm -rf "$MUT/repo15/.git"
grep -v 'ROUTER INTENSITAS' "$MUT/repo15/AGENTS.md" > "$MUT/a15" && mv "$MUT/a15" "$MUT/repo15/AGENTS.md"
expect_caught "HUKUM 13 dihapus" lint "lint cek router intensitas"

rm -rf "$MUT"
echo
if [ "$FAIL" -eq 0 ]; then p "MUTATION: PASS — 15/15 perusakan ditangkap ($PASS)" 82; exit 0; fi
p "MUTATION: FAIL — $FAIL perusakan lolos gate (gate palsu!)" 196; exit 1
