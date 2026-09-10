#!/usr/bin/env bash
# memory — show/manage memory
# Usage: bash commands/memory.sh [show|save|clear]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
warn(){ p "  ⚠ $1" 214; }

MODE="${1:-show}"

p "═══ MEMORY ═══" 213

case "$MODE" in
  show)
    if [ -d "$DIR/memory" ]; then
      p "▶ Memory files:" 213
      for f in "$DIR/memory/"*; do
        [ -f "$f" ] || continue
        NAME=$(basename "$f")
        LINES=$(wc -l < "$f" 2>/dev/null || echo 0)
        SIZE=$(wc -c < "$f" 2>/dev/null || echo 0)
        p "  $NAME ($LINES lines, $SIZE bytes)" 248
      done
      # Global memory
      if [ -f "$HOME/.config/opencode/memory/MEMORY.md" ]; then
        p "" 0
        p "▶ Global memory:" 213
        wc -l "$HOME/.config/opencode/memory/MEMORY.md" 2>/dev/null | while read -r l; do
          p "  MEMORY.md: $l" 248
        done
      fi
    else
      warn "No memory/ directory found"
    fi
    ;;
  save)
    mkdir -p "$DIR/memory"
    SAVE_FILE="$DIR/memory/snapshot-$(date +%Y%m%d-%H%M%S).md"
    {
      echo "# Memory Snapshot — $(date)"
      echo ""
      [ -f "$DIR/VERSION" ] && echo "- Version: $(cat "$DIR/VERSION")"
      echo "- Branch: $(git -C "$DIR" branch --show-current 2>/dev/null || echo '?')"
      echo "- Last commit: $(git -C "$DIR" log -1 --pretty=%s 2>/dev/null || echo '?')"
    } > "$SAVE_FILE"
    ok "Memory saved: $SAVE_FILE"
    ;;
  clear)
    p "⚠ This only removes old snapshots (>30 days)" 214
    find "$DIR/memory" -name "snapshot-*.md" -mtime +30 -delete 2>/dev/null
    ok "Old snapshots cleared"
    ;;
  *)
    p "Usage: bash commands/memory.sh [show|save|clear]" 214
    ;;
esac
