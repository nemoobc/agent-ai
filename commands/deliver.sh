#!/usr/bin/env bash
# deliver — deliver zip + upload
# Usage: bash commands/deliver.sh [output_dir]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ DELIVER ═══" 213

# Check deliver skill
if [ -f "$DIR/skills/deliver/run.sh" ]; then
  bash "$DIR/skills/deliver/run.sh" . "$@"
  EXIT=$?
  exit $EXIT
fi

# Manual delivery
OUTPUT_DIR="${1:-.}"
VER=$(cat "$DIR/VERSION" 2>/dev/null || echo "unknown")
ZIP_FILE="$OUTPUT_DIR/dev-brain-$VER.zip"

p "▶ Creating delivery zip..." 213

# Create zip excluding .git
if command -v zip > /dev/null 2>&1; then
  cd "$DIR" && zip -r "$ZIP_FILE" . -x ".git/*" -x "node_modules/*" -x "*.tmp" 2>/dev/null
  if [ -f "$ZIP_FILE" ]; then
    SIZE=$(wc -c < "$ZIP_FILE" 2>/dev/null || echo "?")
    ok "Delivery zip: $ZIP_FILE ($SIZE bytes)"
  else
    bad "Failed to create zip"
    exit 1
  fi
elif command -v tar > /dev/null 2>&1; then
  TAR_FILE="$OUTPUT_DIR/dev-brain-$VER.tar.gz"
  cd "$DIR" && tar czf "$TAR_FILE" --exclude=".git" --exclude="node_modules" . 2>/dev/null
  if [ -f "$TAR_FILE" ]; then
    ok "Delivery tar: $TAR_FILE"
  else
    bad "Failed to create tar"
    exit 1
  fi
else
  bad "Neither zip nor tar available"
  exit 1
fi

p "" 0
p "═══ DELIVER SELESAI ═══" 82
