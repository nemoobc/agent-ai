#!/usr/bin/env bash
# context — show/compact context
# Usage: bash commands/context.sh [show|compact]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
warn(){ p "  ⚠ $1" 214; }

MODE="${1:-show}"

p "═══ CONTEXT ═══" 213

case "$MODE" in
  show)
    p "▶ Project context:" 213
    [ -f "$DIR/VERSION" ] && p "  VERSION: $(cat "$DIR/VERSION")" 248
    [ -f "$DIR/AGENTS.md" ] && p "  AGENTS.md: $(wc -l < "$DIR/AGENTS.md") lines" 248
    [ -d "$DIR/memory" ] && p "  memory/: $(ls "$DIR/memory/" 2>/dev/null | wc -l) files" 248
    [ -d "$DIR/docs" ] && p "  docs/: $(ls "$DIR/docs/" 2>/dev/null | wc -l) files" 248
    ;;
  compact)
    p "▶ Compacting context to memori..." 213
    # Save key facts to memory
    mkdir -p "$DIR/memory"
    {
      echo "# Context Snapshot — $(date +%Y-%m-%d)"
      echo ""
      [ -f "$DIR/VERSION" ] && echo "- Version: $(cat "$DIR/VERSION")"
      echo "- Skills: $(ls "$DIR/skills/" 2>/dev/null | wc -l)"
      echo "- Agents: $(ls "$DIR/agents/" 2>/dev/null | wc -l)"
      echo "- Tests: $(ls "$DIR/tests/" 2>/dev/null | wc -l)"
    } > "$DIR/memory/context-snapshot.md"
    ok "Context saved to memory/context-snapshot.md"
    ;;
  *)
    p "Usage: bash commands/context.sh [show|compact]" 214
    ;;
esac
