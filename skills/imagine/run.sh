#!/usr/bin/env bash
# imagine — desain solusi: arsitektur, data flow, edge case
# Usage: bash skills/imagine/run.sh [input_file]
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }
info(){ p "  ℹ $1" 111; }

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  bad "Tidak ada input. Gunakan: bash skills/imagine/run.sh <file_atau_string>"
  exit 1
fi

echo ""
p "═══════════════════════════════════════════" 33
p "         💡 IMAGINE — DESAIN SOLUSI         " 33
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
p "▸ BLOK 1: ARSITEKTUR" 45
info "Pola arsitektur terdeteksi:"

# Deteksi pola arsitektur
if echo "$CONTENT" | grep -qiE '(api|endpoint|route|http|rest|graphql)'; then
  ok "→ Web/API Pattern: endpoint, routing, request/response"
fi
if echo "$CONTENT" | grep -qiE '(database|db|query|sql|mongo|redis|cache)'; then
  ok "→ Data Layer: database, caching, persistence"
fi
if echo "$CONTENT" | grep -qiE '(queue|worker|job|background|async|event)'; then
  ok "→ Async Pattern: queue, worker, event-driven"
fi
if echo "$CONTENT" | grep -qiE '(config|env|setting|environment)'; then
  ok "→ Configuration: env-based config"
fi
if echo "$CONTENT" | grep -qiE '(auth|login|token|jwt|session|permission)'; then
  ok "→ Auth Pattern: authentication, authorization"
fi
if echo "$CONTENT" | grep -qiE '(log|error|debug|trace|monitor)'; then
  ok "→ Observability: logging, monitoring"
fi

echo ""
p "▸ BLOK 2: DATA FLOW" 45
info "Langkah alur data:"
ok "1. Input diterima"
ok "2. Validasi & sanitasi"
ok "3. Proses/transformasi"
ok "4. Output dikembalikan"
warn "5. Error handling di setiap tahap"

echo ""
p "▸ BLOK 3: RISIKO & EDGE CASE" 45
warn "Risiko yang perlu dipertimbangkan:"
warn "→ Race condition bila ada async/concurrent"
warn "→ Memory leak pada loop/buffer besar"
warn "→ Security: injection, XSS, SQL injection"
warn "→ Performance: N+1 query, blocking I/O"
warn "→ Error propagation: graceful degradation"

echo ""
info "=== REKOMENDASI DESAIN ==="
ok "Gunakan struktur modular dengan separation of concerns"
ok "Implement error handling di setiap layer"
ok "Tulis test sebelum implementasi (TDD)"
ok "Dokumentasikan edge case dalam spesifikasi"

echo ""
p "═══════════════════════════════════════════" 33
p "         IMAGINE SELESAI                   " 33
p "═══════════════════════════════════════════" 33
echo ""
exit 0
