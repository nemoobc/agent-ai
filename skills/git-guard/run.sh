#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  GIT-GUARD — gerbang commit: scan staged diff.
#  Exit 0 = CLEAN (aman di-commit), 1 = BLOKIR.
#  Jalankan sebelum commit: bash skills/git-guard/run.sh [dir]
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ISSUES=0
fail(){ p "  ✖ $1" 196; ISSUES=$((ISSUES+1)); }

if [ ! -d .git ]; then p "GIT_GUARD: bukan git repo — skip" 214; exit 0; fi

STAGED=$(git diff --cached 2>/dev/null)
if [ -z "$STAGED" ]; then p "GIT_GUARD: tidak ada staged changes — aman" 214; exit 0; fi

p "▮ GIT-GUARD: scan staged diff" 213

# Baris TAMBAHAN (minus header penanda file). WAJIB pola BRE literal '+' —
# `grep -E '^\+\+\+'` SALAH: pada ERE `\+` = kuantor `+` sehingga polanya
# justru mencocokkan SEMUA baris berawalan '+' dan menyisakan nol baris;
# gate debug/marker jadi mati senyap (regresi ini pernah nyata di repo).
ADDED=$(printf '%s' "$STAGED" | grep '^+' | grep -v '^+++')

# 1. secret
if printf '%s' "$STAGED" | grep -qE 'AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|gho_[A-Za-z0-9]{30,}|ghs_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|ya29\.[0-9A-Za-z_-]{20,}|glpat-[A-Za-z0-9_-]{16,}|dop_v1_[a-f0-9]{32,}|npm_[A-Za-z0-9]{30,}|BEGIN [A-Z ]*PRIVATE KEY'; then
  fail "pola secret di staged diff"
fi

# 2. merge marker — pada diff mentah setiap baris berawalan +/-/spasi, jadi
#    pola `^(<<<<<<<` TIDAK PERNAH match. Scan baris tambahan yang sudah
#    dipotong prefiks '+' agar gate benar-benar bisa menyala.
if printf '%s' "$ADDED" | grep -qE '^\+(<{7}|[|]{7}|={7}|>{7})'; then
  fail "merge conflict marker tersisa"
fi

# 3. debug yang DITAMBAHKAN (baris +) — per-file, pengecualian TERDOKUMENTASI:
#    file GERBANG / test (tests/, __tests__/, *.test.*, *.spec.*, *.e2e.mjs) + git-guard sendiri.
#    Di sana console.log BUKAN debug tersisa — itu output gerbang itu sendiri;
#    skrip yang tidak mencetak apa pun tidak bisa jadi bukti. Kode aplikasi
#    (src/, js/, app) tetap diperiksa penuh — di sanalah debug sungguhan.
#    Per-file, bukan satu diff digabung: baris `+` tidak membawa nama file-nya,
#    jadi penyaringan harus tahu file mana yang sedang dibaca.
DEBUG_HITS=""
while IFS= read -r f; do
  case "$f" in
    tests/*|*/tests/*|__tests__/*|*/__tests__/*|*.test.*|*.spec.*|*.e2e.mjs) continue ;;
    # file gate ini sendiri memuat pola debug sebagai DEFINISI gate — bukan debug tersisa
    skills/git-guard/run.sh) continue ;;
  esac
  [ -f "$f" ] || continue
  file_added=$(git diff --cached -U0 -- "$f" 2>/dev/null | grep '^+' | grep -v '^+++')
  if printf '%s' "$file_added" | grep -qE 'console[.]log[(]|print[(]|var_dump[(]|pdb[.]|debugger'; then
    DEBUG_HITS="$DEBUG_HITS $f"
  fi
done <<EOF
$(git diff --cached --name-only 2>/dev/null)
EOF
if [ -n "$DEBUG_HITS" ]; then
  fail "debug statement ditambahkan di:${DEBUG_HITS}"
fi

# 4. diff raksasa — dua pengecualian false-positive (dokumentasi, bukan bypass):
#    (a) lockfile mesin (bun.lock dkk) memang >1500 baris bawaan generator;
#    (b) ambang 1000 → 1500: aturan asal untuk delta komit inkremental, tapi
#        menghantam file sumber SAH pada import proyek awal (file ~1240 baris
#        mustahil dipecah per commit). 1500 tetap menangkap dump raksasa —
#        file tunggal >1500 baris hampir selalu artefak/generate/saltempel.
#        Scan secret/marker/debug TETAP jalan di file besar.
BIG=$(git diff --cached --numstat 2>/dev/null | awk '
  $1 ~ /^[0-9]+$/ && $1 > 1500 &&
  $3 !~ /(^|\/)(bun\.lock|package-lock\.json|pnpm-lock\.yaml|yarn\.lock)$/ {
    print $3 " (" $1 " baris baru)" }' | head -1)
if [ -n "$BIG" ]; then
  fail "file besar di commit: $BIG — pecah commit"
fi

echo
if [ "$ISSUES" -eq 0 ]; then p "GIT_GUARD: CLEAN — aman di-commit ✓" 82; exit 0; fi
p "GIT_GUARD: BLOKIR — perbaiki dulu, jangan paksa commit" 196; exit 1
