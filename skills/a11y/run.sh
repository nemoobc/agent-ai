#!/usr/bin/env bash
# a11y — aksesibilitas: cek WCAG compliance → rekomendasi perbaikan
# Usage: bash skills/a11y/run.sh [directory_or_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-.}"
echo ""
p "═══════════════════════════════════════════" 33
p "         ♿ A11Y — AKSESIBILITAS            " 33
p "═══════════════════════════════════════════" 33
echo ""

# Tentukan target
if [ -f "$INPUT" ]; then
  FILES="$INPUT"
  info "Memindai file: $INPUT"
elif [ -d "$INPUT" ]; then
  FILES=$(find "$INPUT" -type f \( -name "*.html" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) 2>/dev/null | head -50)
  info "Memindai direktori: $INPUT"
else
  bad "Input tidak valid: $INPUT"
  exit 1
fi

echo ""
p "▸ WCAG 2.1 COMPLIANCE CHECK" 45
echo ""

ISSUES=0

# Periksa setiap file
for file in $FILES; do
  if [ -f "$file" ]; then
    info "File: $file"
    
    # 1. Alt text pada images
    IMAGES_WITHOUT_ALT=$(grep -c '<img[^>]*[^>]alt=' "$file" 2>/dev/null | head -1 || echo 0)
    IMAGES_TOTAL=$(grep -c '<img' "$file" 2>/dev/null | head -1 || echo 0)
    if [ "$IMAGES_TOTAL" -gt 0 ]; then
      if [ "$IMAGES_WITHOUT_ALT" -gt 0 ]; then
        bad "WCAG 1.1.1: $IMAGES_WITHOUT_ALT images tanpa alt text"
        ISSUES=$((ISSUES + IMAGES_WITHOUT_ALT))
      else
        ok "WCAG 1.1.1: Semua images punya alt text"
      fi
    fi
    
    # 2. Form labels
    INPUTS_WITHOUT_LABEL=$(grep -c '<input[^>]*[^>]id=' "$file" 2>/dev/null | head -1 || echo 0)
    LABELS_TOTAL=$(grep -c '<label' "$file" 2>/dev/null | head -1 || echo 0)
    if [ "$INPUTS_WITHOUT_LABEL" -gt "$LABELS_TOTAL" ]; then
      bad "WCAG 1.3.1: Input tanpa label"
      ISSUES=$((ISSUES + 1))
    fi
    
    # 3. Heading hierarchy
    H1_COUNT=$(grep -c '<h1' "$file" 2>/dev/null | head -1 || echo 0)
    if [ "$H1_COUNT" -gt 1 ]; then
      warn "WCAG 1.3.1: Multiple h1 tags ($H1_COUNT)"
      ISSUES=$((ISSUES + 1))
    fi
    
    # 4. Color contrast (basic check)
    if grep -qiE 'color:\s*#[0-9a-fA-F]+' "$file" 2>/dev/null; then
      warn "WCAG 1.4.3: Periksa color contrast manual"
      ISSUES=$((ISSUES + 1))
    fi
    
    # 5. Keyboard navigation
    if grep -qiE 'onclick|onkeydown|onkeypress' "$file" 2>/dev/null; then
      if ! grep -qiE 'onkeydown|onkeypress|tabindex' "$file" 2>/dev/null; then
        warn "WCAG 2.1.1: Event handler tanpa keyboard support"
        ISSUES=$((ISSUES + 1))
      fi
    fi
    
    # 6. ARIA attributes
    if grep -qiE 'role=' "$file" 2>/dev/null; then
      ok "WCAG 4.1.2: ARIA roles digunakan"
    fi
    
    # 7. Language attribute
    if grep -qiE '<html[^>]*lang=' "$file" 2>/dev/null; then
      ok "WCAG 3.1.1: Language attribute ada"
    else
      warn "WCAG 3.1.1: html lang attribute hilang"
      ISSUES=$((ISSUES + 1))
    fi
  fi
done

echo ""
p "▸ REKOMENDASI PERBAIKAN" 45
ok "1. Tambah alt text deskriptif pada semua images"
ok "2. Gunakan <label> untuk semua form inputs"
ok "3. Pastikan heading hierarchy benar (h1 → h2 → h3)"
ok "4. Test color contrast dengan工具 (min 4.5:1 untuk teks)"
ok "5. Pastikan semua interaksi bisa diakses dengan keyboard"
ok "6. Gunakan ARIA landmarks dan roles"
ok "7. Test dengan screen reader (NVDA, VoiceOver)"

echo ""
info "=== RINGKASAN ==="
ok "Standar: WCAG 2.1 Level AA"
if [ $ISSUES -eq 0 ]; then
  ok "Tidak ada masalah signifikan terdeteksi"
else
  warn "Ditemukan $ISSUES masalah aksesibilitas"
  ok "Prioritas: Fix yang CRITICAL/HIGH terlebih dahulu"
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         A11Y SELESAI                      " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
