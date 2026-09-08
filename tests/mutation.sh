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
    *)       return 1 ;;
  esac
}

expect_caught(){ # $1=nama $2=gate $3=alasan
  if run_gate "$2" "$MUT/repo"; then ok "$1 → gate $2 MENANGKAP ($3)"; PASS=$((PASS+1)); else bad "$1 → gate $2 LOLOS — detektor palsu!"; FAIL=$((FAIL+1)); fi
}

p "▮ MUTASI 1/6 — frontmatter skill hilang → lint" 213
rm -f "$MUT/repo/skills/think/SKILL.md"
printf '# THINK\nbasa-basi\n' > "$MUT/repo/skills/think/SKILL.md"
expect_caught "frontmatter skill hilang" lint "lint cek frontmatter"

p "▮ MUTASI 2/6 — badge SKILLS di README tua → self-test" 213
cp -r "$DIR"/. "$MUT/repo2" 2>/dev/null
rm -rf "$MUT/repo2/.git"
sed -i 's/SKILLS-[0-9]*/SKILLS-1/' "$MUT/repo2/README.md"
( cd "$MUT/repo2" && bash tests/self-test.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "badge SKILLS tua → self-test MENANGKAP"; PASS=$((PASS+1)); } || { bad "badge SKILLS tua → self-test LOLOS"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo2"

p "▮ MUTASI 3/6 — HUKUM 10 dihapus dari AGENTS.md → lint" 213
cp -r "$DIR"/. "$MUT/repo3" 2>/dev/null
rm -rf "$MUT/repo3/.git"
grep -v 'HUKUM 10' "$MUT/repo3/AGENTS.md" > "$MUT/agents.tmp" && mv "$MUT/agents.tmp" "$MUT/repo3/AGENTS.md"
expect_caught "HUKUM 10 dihapus" lint "lint cek 10 hukum"

p "▮ MUTASI 4/6 — hitungan self-test ngaco (45→9) → self-test" 213
cp -r "$DIR"/. "$MUT/repo4" 2>/dev/null
rm -rf "$MUT/repo4/.git"
sed -i 's/-eq 45 ]/-eq 9 ]/' "$MUT/repo4/tests/self-test.sh"
( cd "$MUT/repo4" && bash tests/self-test.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "hitungan 45→9 → self-test MENANGKAP"; PASS=$((PASS+1)); } || { bad "hitungan 45→9 → self-test LOLOS"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo4"

p "▮ MUTASI 5/6 — command tanpa frontmatter agent → lint" 213
cp -r "$DIR"/. "$MUT/repo5" 2>/dev/null
rm -rf "$MUT/repo5/.git"
printf '# PALSU\nTugas: jalan saja.\n' > "$MUT/repo5/command/palsu.md"
expect_caught "command tanpa frontmatter" lint "lint cek command valid"

p "▮ MUTASI 6/6 — VERSION ≠ badge README → self-test" 213
cp -r "$DIR"/. "$MUT/repo6" 2>/dev/null
rm -rf "$MUT/repo6/.git"
printf '99.9.9\n' > "$MUT/repo6/VERSION"
( cd "$MUT/repo6" && bash tests/self-test.sh ) >/dev/null 2>&1
[ $? -ne 0 ] && { ok "VERSION 99.9.9 ≠ badge → self-test MENANGKAP"; PASS=$((PASS+1)); } || { bad "VERSION nyasar → self-test LOLOS"; FAIL=$((FAIL+1)); }
rm -rf "$MUT/repo6"

rm -rf "$MUT"
echo
if [ "$FAIL" -eq 0 ]; then p "MUTATION: PASS — 6/6 perusakan ditangkap ($PASS)" 82; exit 0; fi
p "MUTATION: FAIL — $FAIL perusakan lolos gate (gate palsu!)" 196; exit 1