#!/usr/bin/env bash
# release — bump versi + CHANGELOG + tag
# Usage: bash commands/release.sh [major|minor|patch]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }

p "═══ RELEASE ═══" 213

BUMP="${1:-patch}"
OLD_VER=$(cat "$DIR/VERSION" 2>/dev/null || echo "0.0.1")
IFS='.' read -r MAJOR MINOR PATCH <<< "$OLD_VER"

case "$BUMP" in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
  *) bad "Unknown bump type: $BUMP (use major/minor/patch)"; exit 1 ;;
esac

NEW_VER="$MAJOR.$MINOR.$PATCH"
echo "$NEW_VER" > "$DIR/VERSION"
ok "VERSION: $OLD_VER → $NEW_VER"

# CHANGELOG entry
TODAY=$(date +%Y-%m-%d)
if [ -f "$DIR/CHANGELOG.md" ]; then
  # Insert after first heading
  sed -i "/^# /a\\
\\
## [$NEW_VER] - $TODAY\\
\\
- Release $NEW_VER" "$DIR/CHANGELOG.md"
  ok "CHANGELOG.md updated"
else
  echo "# Changelog" > "$DIR/CHANGELOG.md"
  echo "" >> "$DIR/CHANGELOG.md"
  echo "## [$NEW_VER] - $TODAY" >> "$DIR/CHANGELOG.md"
  echo "" >> "$DIR/CHANGELOG.md"
  echo "- Release $NEW_VER" >> "$DIR/CHANGELOG.md"
  ok "CHANGELOG.md created"
fi

# Git tag
if git rev-parse --git-dir > /dev/null 2>&1; then
  git tag -a "v$NEW_VER" -m "Release $NEW_VER" 2>/dev/null && ok "Tag v$NEW_VER created" || ok "Tag v$NEW_VER already exists"
fi

p "═══ RELEASE $NEW_VER SELESAI ═══" 82
