#!/usr/bin/env bash
# clean — clean build artifacts
# Usage: bash commands/clean.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }

p "═══ CLEAN ═══" 213

# Clean common artifact patterns
for pattern in "*.tmp" "*.bak" "*.swp" "*~" "*.log" "*.zip" "*.tar.gz"; do
  FOUND=$(find "$DIR" -name "$pattern" -not -path "*/.git/*" 2>/dev/null)
  if [ -n "$FOUND" ]; then
    echo "$FOUND" | while read -r f; do
      rm -f "$f" && ok "removed: $(basename "$f")"
    done
  fi
done

# Clean empty dirs
find "$DIR" -type d -empty -not -path "*/.git/*" 2>/dev/null | while read -r d; do
  rmdir "$d" 2>/dev/null && ok "removed empty dir: $d"
done

# Clean memory snapshots older than 30 days
find "$DIR/memory" -name "context-snapshot-*.md" -mtime +30 2>/dev/null | while read -r f; do
  rm -f "$f" && ok "removed old snapshot: $(basename "$f")"
done

p "" 0
p "═══ CLEAN SELESAI ═══" 82
