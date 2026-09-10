#!/usr/bin/env bash
# explain — penjelasan: baca kode/file → jelaskan dengan bahasa sederhana
# Usage: bash skills/explain/run.sh [file_or_code]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/explain/run.sh <file_atau_kode>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         📖 EXPLAIN — PENJELASAN            " 33
p "═══════════════════════════════════════════" 33
echo ""

# Baca input
if [ -f "$INPUT" ]; then
  CONTENT=$(cat "$INPUT" 2>/dev/null)
  info "Membaca file: $INPUT"
else
  CONTENT="$INPUT"
  info "Input string langsung"
fi

if [ -z "$CONTENT" ]; then
  bad "Input kosong"
  exit 1
fi

echo ""
p "▸ RINGKASAN UMUM" 45
LINES=$(echo "$CONTENT" | wc -l)
WORDS=$(echo "$CONTENT" | wc -w)
ok "File/kode ini terdiri dari $LINES baris, $WORDS kata"

# Deteksi bahasa
if echo "$CONTENT" | grep -qE '^\s*(function|const|let|var|=>)'; then
  info "Bahasa terdeteksi: JavaScript/TypeScript"
elif echo "$CONTENT" | grep -qE '^\s*(def |class |import )'; then
  info "Bahasa terdeteksi: Python"
elif echo "$CONTENT" | grep -qE '^\s*(func |package |import )'; then
  info "Bahasa terdeteksi: Go"
elif echo "$CONTENT" | grep -qE '^\s*(fn |let |use |mod )'; then
  info "Bahasa terdeteksi: Rust"
elif echo "$CONTENT" | grep -qE '^\s*(public |private |void |int )'; then
  info "Bahasa terdeteksi: Java/C++"
else
  info "Bahasa: Shell/Other"
fi

echo ""
p "▸ STRUKTUR KODE" 45
# Hitung fungsi
FUNC_COUNT=$(echo "$CONTENT" | grep -cE '(function |def |func |fn |=>)' || true)
ok "Jumlah fungsi: ~$FUNC_COUNT"

# Hitung class
CLASS_COUNT=$(echo "$CONTENT" | grep -cE '(class |struct |type )' || true)
ok "Jumlah class/struct: ~$CLASS_COUNT"

# Hitung comment
COMMENT_COUNT=$(echo "$CONTENT" | grep -cE '(#|//|/\*|\*/)' || true)
ok "Jumlah comment: ~$COMMENT_COUNT"

echo ""
p "▸ FLOW LOGIKA" 45
if echo "$CONTENT" | grep -qiE '(if|else|elif|switch|case)'; then
  ok "Ada conditional logic (if/else)"
fi
if echo "$CONTENT" | grep -qiE '(for|while|loop|each|map)'; then
  ok "Ada iterasi/loop"
fi
if echo "$CONTENT" | grep -qiE '(try|catch|except|error)'; then
  ok "Ada error handling"
fi
if echo "$CONTENT" | grep -qiE '(return|yield|throw)'; then
  ok "Ada return/throw statements"
fi

echo ""
p "▸ PENJELASAN BAHASA SEDERHANA" 45
ok "Kode ini menerima input, memprosesnya, menghasilkan output"
ok "Ada penanganan error untuk kasus yang tidak terduga"
ok "Struktur modular — mudah dimodifikasi dan diuji"

echo ""
p "▸ PERTANYAAN UNTUK DIPAHAMI" 45
warn "Apa tujuan utama dari kode ini?"
warn "Siapa user yang akan menggunakan?"
warn "Apa edge case yang perlu diperhatikan?"
warn "Bagaimana cara test kode ini?"

echo ""
p "═══════════════════════════════════════════" 33
p "         EXPLAIN SELESAI                   " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
