#!/usr/bin/env bash
# i18n — internasionalisasi: deteksi hard-coded strings → rekomendasikan externalization
# Usage: bash skills/i18n/run.sh [directory_or_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-.}")
echo ""
p "═══════════════════════════════════════════" 33
p "         🌍 I18N — INTERNASIONALISASI       " 33
p "═══════════════════════════════════════════" 33
echo ""

# Tentukan target
if [ -f "$INPUT" ]; then
  FILES="$INPUT"
  info "Memindai file: $INPUT"
elif [ -d "$INPUT" ]; then
  FILES=$(find "$INPUT" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.py" -o -name "*.rb" -o -name "*.php" \) 2>/dev/null | head -50)
  info "Memindai direktori: $INPUT"
else
  bad "Input tidak valid: $INPUT"
  exit 1
fi

echo ""
p "▸ SCAN HARD-CODED STRINGS" 45
echo ""

HARD_CODED=0
PATTERNS=(
  'console\.log\(["'"'"'][^"'"'"']*["'"'"']\)'
  'print\(["'"'"'][^"'"'"']*["'"'"']\)'
  'alert\(["'"'"'][^"'"'"']*["'"'"']\)'
  'innerHTML\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
  '>\s*[A-Z][a-zA-Z ]*\s*<'
  'placeholder=["'"'"'][^"'"'"']*["'"'"']'
  'title=["'"'"'][^"'"'"']*["'"'"']'
  'label=["'"'"'][^"'"'"']*["'"'"']'
  'error:\s*["'"'"'][^"'"'"']*["'"'"']'
  'message:\s*["'"'"'][^"'"'"']*["'"'"']'
)

for file in $FILES; do
  if [ -f "$file" ]; then
    for pattern in "${PATTERNS[@]}"; do
      MATCHES=$(grep -nE "$pattern" "$file" 2>/dev/null | head -5)
      if [ -n "$MATCHES" ]; then
        warn "File: $file"
        echo "$MATCHES" | while read -r match; do
          HARD_CODED=$((HARD_CODED + 1))
          info "  → $match"
        done
      fi
    done
  fi
done

echo ""
p "▸ REKOMENDASI I18N" 45
ok "1. Buat locale files (en.json, id.json, dll)"
ok "2. Ganti hard-coded string dengan t keys"
ok "3. Gunakan i18n library (react-i18next, vue-i18n, gettext)"
ok "4. Pisahkan UI strings dari kode logic"
ok "5. Test dengan multiple locales"

echo ""
p "▸ CONTOH TRANSFORMASI" 45
info "Sebelum:"
info '  <button>Submit</button>'
info '  console.log("Error occurred")'
info ""
info "Sesudah:"
info '  <button>{t("submit")}</button>'
info '  console.log(t("error occurred"))'

echo ""
info "=== STATUS ==="
if [ $HARD_CODED -gt 0 ]; then
  warn "Ditemukan $HARD_CODED potensi hard-coded strings"
  ok "Prioritas: High — externalize untuk i18n support"
else
  ok "Tidak ada hard-coded strings signifikan"
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         I18N SELESAI                      " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
