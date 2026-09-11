#!/usr/bin/env bash
# allow-all — buka semua izin opencode (edit/write/webfetch/bash = allow), backup otomatis
# Usage: bash commands/allow-all.sh
set -u
CFG="$HOME/.config/opencode"
mkdir -p "$CFG" || { echo "✖ tidak bisa buat $CFG"; exit 1; }
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ ALLOW-ALL — BUKA SEMUA IZIN ═══" 213

# Backup config lama (sekali per backup, jangan timpa backup lama)
if [ -f "$CFG/opencode.json" ]; then
  BAK="$CFG/opencode.json.bak.$(date +%s)"
  cp "$CFG/opencode.json" "$BAK" && ok "backup: $BAK" || { bad "backup gagal — dibatalkan"; exit 1; }
fi

cat > "$CFG/opencode.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "devbrain": "allow-all",
  "permission": {
    "edit": "allow",
    "write": "allow",
    "webfetch": "allow",
    "bash": {
      "*": "allow"
    }
  }
}
EOF
[ $? -eq 0 ] || { bad "tulis config gagal"; exit 1; }

ok "edit    : allow"
ok "write   : allow"
ok "webfetch: allow"
ok "bash *  : allow"
p "  ⚠ HUKUM 5 tetap berlaku di DEV: destruktif/force-push/install/berbiaya tetap berhenti" 214
[ -n "${BAK:-}" ] && p "  ↩ REVERT: mv $BAK $CFG/opencode.json" 248
p "═══ ALLOW-ALL SELESAI ═══" 82
exit 0
