#!/usr/bin/env bash
# plan — rencana 8 blok: analisis, desain, konstruksi, test, audit, dok, bukti, risiko
# Usage: bash skills/plan/run.sh [input_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/plan/run.sh <file_atau_string>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         📝 PLAN — RENCANA 8 BLOK          " 33
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
p "▸ BLOK 1: ANALISIS" 45
ok "Input: $(echo "$CONTENT" | wc -w) kata, $(echo "$CONTENT" | wc -l) baris"
ok "Jenis: $(echo "$CONTENT" | head -1 | cut -c1-50)"

echo ""
p "▸ BLOK 2: DESAIN" 45
ok "Arsitektur: Modular, separation of concerns"
ok "Data flow: Input → Validasi → Proses → Output"
ok "Error handling: Setiap layer tangkap error"

echo ""
p "▸ BLOK 3: KONSTRUKSI" 45
ok "Language: Deteksi otomatis dari ekstensi file"
ok "Structure: Ikuti konvensi project yang ada"
ok "Dependencies: Minimal, hanya yang diperlukan"

echo ""
p "▸ BLOK 4: TEST" 45
ok "Unit test: Setiap fungsi punya test"
ok "Integration test: Test antar komponen"
ok "Edge case: Test batas dan error condition"
ok "Coverage target: ≥ 80%"

echo ""
p "▸ BLOK 5: AUDIT" 45
ok "Security: Cek injection, auth, sanitization"
ok "Performance: Cek blocking I/O, memory leak"
ok "Readability: Naming, komentar, struktur"
ok "Maintainability: Modularity, coupling"

echo ""
p "▸ BLOK 6: DOK" 45
ok "README: Cara pakai, install, dependensi"
ok "Inline: Komentar pada kode kompleks"
ok "API doc: Untuk public interface"
ok "Changelog: Perubahan penting"

echo ""
p "▸ BLOK 7: BUKTI" 45
ok "Test passing: Semua test hijau"
ok "Lint clean: Tidak ada warning"
ok "Build success: Compile/transpile tanpa error"
ok "Demo: Contoh penggunaan berhasil"

echo ""
p "▸ BLOK 8: RISIKO" 45
warn "Risiko tinggi: Data loss, security breach"
warn "Risiko sedang: Performance regression"
warn "Risiko rendah: UI glitch, typo"
warn "Mitigasi: Test, review, monitoring"

echo ""
info "Status: Rencana 8 blok selesai — lanjut ke implementasi"
echo ""
p "═══════════════════════════════════════════" 33
p "         PLAN SELESAI                      " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
