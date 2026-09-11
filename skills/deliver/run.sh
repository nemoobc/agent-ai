#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  DELIVER run.sh — zip + upload tmpfiles.org (serah kerja tanpa git).
#  Pemakaian: bash run.sh [jam_hidup]   (default 24; max 72 di tmpfiles)
#  Exit: 0 = link jadi, 1 = gagal, 2 = dibatalkan guard.
# ═════════════════════════════════════════════════════════════════
set -u
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$(cd "$DIR/.." && pwd)"
V="$(tr -d '[:space:]' < "$PROJECT/VERSION" 2>/dev/null || echo dev)"
HOURS="${1:-24}"; echo "$HOURS" | grep -qE '^[0-9]+$' || HOURS=24
[ "$HOURS" -gt 72 ] && HOURS=72

command -v curl >/dev/null 2>&1 || { p "  ✖ curl tidak ada" 196; exit 1; }

p "▮ DELIVER — guard secret dulu" 213
if bash "$DIR/git-guard/run.sh" "$PROJECT" >/dev/null 2>&1; then
  p "  ✔ git-guard CLEAN" 82
else
  p "  ✖ guard merah — zip DIBATALKAN. Perbaiki secret/marker dulu." 196
  exit 2
fi

p "▮ DELIVER — zip" 213
TMPZ="$(mktemp -d)"
ZIP="$TMPZ/dev-brain-v$V.zip"
SCAN="$TMPZ/scan"
mkdir -p "$SCAN"
( cd "$PROJECT" && git ls-files -z --cached --others --exclude-standard 2>/dev/null \
  | grep -zvE '(^|/)(\.env|\.env\..*|.*\.pem|.*\.key|.*credentials.*)$' \
  | xargs -0 zip -rq "$ZIP" 2>/dev/null ) \
  || ( cd "$PROJECT" && find . -type f -not -path './.git/*' \
    -not -name '.env' -not -name '.env.*' -not -name '*.pem' -not -name '*.key' \
    -print0 | xargs -0 zip -rq "$ZIP" ) \
  || { p "  ✖ zip gagal" 196; exit 1; }
SIZE=$(du -h "$ZIP" | cut -f1)
NFILES=$(unzip -l "$ZIP" 2>/dev/null | tail -1 | awk '{print $2}')
p "  ✔ $ZIP ($SIZE, $NFILES file)" 82
unzip -q "$ZIP" -d "$SCAN" 2>/dev/null || { p "  ✖ arsip tidak bisa dibaca" 196; exit 1; }
if ! bash "$DIR/audit-full/run.sh" "$SCAN" >/dev/null 2>&1; then
  p "  ✖ arsip mengandung temuan secret — upload dibatalkan" 196
  rm -rf "$TMPZ"
  exit 2
fi
p "  ✔ isi arsip lolos audit secret" 82

p "▮ DELIVER — upload tmpfiles.org" 213
LINK=$(curl -fsSL --connect-timeout 5 --max-time 120 -F "file=@$ZIP" "https://tmpfiles.org/api/v1/upload?expiry=$HOURS" 2>/dev/null \
  | grep -oE 'https://tmpfiles[^"]*' | head -1)
if [ -n "${LINK:-}" ]; then
  # API balas domain /dl/ untuk unduh langsung
  DLINK=$(echo "$LINK" | sed 's|tmpfiles.org/|tmpfiles.org/dl/|')
  p "  ✔ link unduh: $DLINK" 82
  p "  ▸ hidup ${HOURS}jam — hapus manual bila perlu" 214
  echo "$DLINK" > "$PROJECT/.deliver-last-url" 2>/dev/null || true
  rm -rf "$TMPZ"
  exit 0
fi
rm -rf "$TMPZ"
p "  ✖ upload gagal — cek koneksi, atau zip ada di laporan" 196
exit 1
