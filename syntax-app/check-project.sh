#!/usr/bin/env bash
# check-project.sh — verifikasi struktur project Syntax (jalan di Termux, tanpa Android SDK)
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
PASS=0; FAIL=0

ok()   { PASS=$((PASS+1)); echo "PASS $1"; }
bad()  { FAIL=$((FAIL+1)); echo "FAIL $1"; }

check_file() { [ -f "$ROOT/$1" ] && ok "file: $1" || bad "file hilang: $1"; }

# ── file inti ──
for f in \
  settings.gradle.kts build.gradle.kts gradle.properties \
  gradle/libs.versions.toml gradle/wrapper/gradle-wrapper.properties \
  app/build.gradle.kts app/proguard-rules.pro README.md .gitignore \
  app/src/main/AndroidManifest.xml \
  app/src/main/assets/bip39-english.txt \
  app/src/test/resources/bip39-english.txt; do
  check_file "$f"
done

# ── source Kotlin ──
KOTLIN=$(find "$ROOT/app/src/main/java" -name '*.kt' 2>/dev/null | wc -l)
TESTS=$(find "$ROOT/app/src/test/java" -name '*Test.kt' 2>/dev/null | wc -l)
[ "$KOTLIN" -ge 15 ] && ok "kotlin main >= 15 ($KOTLIN)" || bad "kotlin main terlalu sedikit ($KOTLIN)"
[ "$TESTS" -ge 6 ] && ok "test >= 6 ($TESTS)" || bad "test terlalu sedikit ($TESTS)"

# ── icon vector custom ──
ICONS=$(find "$ROOT/app/src/main/res/drawable" -name 'ic_*.xml' 2>/dev/null | wc -l)
[ "$ICONS" -ge 12 ] && ok "icon vector >= 12 ($ICONS)" || bad "icon vector kurang ($ICONS)"
[ -f "$ROOT/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml" ] && ok "adaptive icon" || bad "adaptive icon hilang"

# ── wordlist resmi ──
WL="$ROOT/app/src/main/assets/bip39-english.txt"
WL_LINES=$(grep -c . "$WL" 2>/dev/null || echo 0)
WL_UNIQ=$(sort -u "$WL" 2>/dev/null | grep -c . || echo 0)
sort -c "$WL" 2>/dev/null && ok "wordlist terurut" || bad "wordlist tidak terurut"
[ "$WL_LINES" = "2048" ] && ok "wordlist 2048" || bad "wordlist $WL_LINES != 2048"
[ "$WL_UNIQ" = "2048" ] && ok "wordlist unik" || bad "wordlist duplikat"
cmp -s "$WL" "$ROOT/app/src/test/resources/bip39-english.txt" \
  && ok "wordlist test resources identik" || bad "wordlist test beda"

# ── konstanta kripto benar (bug P pendek pernah terjadi) ──
P_REAL="fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f"
if grep -q "\"$P_REAL\"" "$ROOT/app/src/main/java/com/syntax/wallet/crypto/Secp256k1.kt"; then
  ok "konstanta P 64-char benar"
else
  bad "konstanta P salah/pendek di Secp256k1.kt"
fi
# pastikan tidak ada varian 56-char
if grep -q '"fffffffffffffffffffffffffffffffffffffffffffffffefffffc2f"' "$ROOT/app/src/main/java/com/syntax/wallet/crypto/Secp256k1.kt"; then
  bad "konstanta P 56-char (bug lama) masih ada"
else
  ok "tidak ada varian P 56-char"
fi
# Bip32 data 37 byte (bug 33 pernah terjadi)
if grep -q 'val data = ByteArray(37)' "$ROOT/app/src/main/java/com/syntax/wallet/crypto/Bip32.kt"; then
  ok "Bip32 data ByteArray(37)"
else
  bad "Bip32 data bukan 37 byte"
fi
if grep -q 'multiply((x2 - x1).modInverse(P))' "$ROOT/app/src/main/java/com/syntax/wallet/crypto/Secp256k1.kt"; then
  ok "add(): inverse hanya penyebut"
else
  bad "add(): inverse product (bug lama)"
fi

# ── tanpa emoji di source ──
if grep -rP '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]' "$ROOT/app/src/main/java" "$ROOT/app/src/main/res/drawable" >/dev/null 2>&1; then
  bad "emoji ditemukan di source"
else
  ok "tanpa emoji di source"
fi

# ── XML well-formed ──
if command -v python3 >/dev/null 2>&1; then
  XML_BAD=0
  while IFS= read -r x; do
    python3 -c "import xml.dom.minidom,sys; xml.dom.minidom.parse(sys.argv[1])" "$x" 2>/dev/null || { XML_BAD=1; echo "  xml rusak: $x"; }
  done < <(find "$ROOT/app/src/main/res" -name '*.xml'; echo "$ROOT/app/src/main/AndroidManifest.xml")
  [ "$XML_BAD" = "0" ] && ok "semua XML well-formed" || bad "ada XML rusak"
else
  echo "SKIP xml check (python3 tidak ada)"
fi

# ── balance kurung Kotlin (strip komentar/string/char dulu — deteksi file terpotong) ──
if command -v python3 >/dev/null 2>&1; then
  TMP=$(mktemp)
  if python3 - "$ROOT" >"$TMP" 2>&1 <<'PYEOF'
import sys, os
root = sys.argv[1]
bad = 0
for dirpath, _, files in os.walk(os.path.join(root, 'app', 'src')):
    for f in files:
        if not f.endswith('.kt'):
            continue
        p = os.path.join(dirpath, f)
        src = open(p).read()
        out, i, n = [], 0, len(src)
        while i < n:
            c = src[i]
            if c == '/' and i+1 < n and src[i+1] == '/':
                while i < n and src[i] != '\n':
                    i += 1
            elif c == '/' and i+1 < n and src[i+1] == '*':
                i += 2
                while i+1 < n and not (src[i] == '*' and src[i+1] == '/'):
                    i += 1
                i += 2
            elif c == '"':
                i += 1
                while i < n and src[i] != '"':
                    if src[i] == '\\':
                        i += 1
                    i += 1
                i += 1
                out.append('S')
            elif c == "'":
                i += 1
                while i < n and src[i] != "'":
                    if src[i] == '\\':
                        i += 1
                    i += 1
                i += 1
                out.append('C')
            else:
                out.append(c)
                i += 1
        stripped = ''.join(out)
        if stripped.count('{') != stripped.count('}'):
            bad += 1
            print('  kurung timpang: ' + p)
sys.exit(1 if bad else 0)
PYEOF
  then ok "kurung Kotlin seimbang semua (parser sadar string)"
  else bad "ada file kt kurung timpang"; cat "$TMP"; fi
  rm -f "$TMP"
else
  echo "SKIP balance kurung (python3 tidak ada)"
fi

# ── tanpa TODO/FIXME ──
if grep -rn 'TODO\|FIXME' "$ROOT/app/src/main/java" >/dev/null 2>&1; then
  bad "ada TODO/FIXME tertinggal"
else
  ok "tanpa TODO/FIXME"
fi

# ── drawable yang direferensikan ada ──
MISSING=0
for d in $(grep -rhoE 'R\.drawable\.ic_[a-z_]+' "$ROOT/app/src/main/java" | sort -u | sed 's/R.drawable.//'); do
  [ -f "$ROOT/app/src/main/res/drawable/$d.xml" ] || { MISSING=$((MISSING+1)); echo "  hilang: $d"; }
done
[ "$MISSING" = "0" ] && ok "semua icon terpakai tersedia" || bad "$MISSING icon hilang"

echo
echo "══════════════════════════"
echo "PASS: $PASS   FAIL: $FAIL"
[ "$FAIL" = "0" ] || exit 1
