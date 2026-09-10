#!/usr/bin/env bash
# roadmap — show roadmap
# Usage: bash commands/roadmap.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

p "═══ ROADMAP ═══" 213

if [ -f "$DIR/docs/ROADMAP.md" ]; then
  cat "$DIR/docs/ROADMAP.md"
elif [ -f "$DIR/docs/roadmap.md" ]; then
  cat "$DIR/docs/roadmap.md"
else
  p "No ROADMAP.md found" 214
  p "Creating docs/ROADMAP.md template..." 248
  mkdir -p "$DIR/docs"
  cat > "$DIR/docs/ROADMAP.md" << 'EOF'
# ROADMAP

## v1.0 (Current)
- [ ] Core skills
- [ ] Agent system
- [ ] Test suite

## v2.0 (Future)
- [ ] MCP integrations
- [ ] Plugin system
- [ ] Multi-agent orchestration
EOF
  cat "$DIR/docs/ROADMAP.md"
fi
