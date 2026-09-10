#!/usr/bin/env bash
# bootstrap — inisialisasi project baru (buat struktur dasar: AGENTS.md, VERSION, memory/, tests/, skills/)
# Usage: bash commands/bootstrap.sh [project_dir]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
PROJECT="${1:-.}"
cd "$PROJECT" || { bad "cannot cd to $PROJECT"; exit 1; }

p "═══ BOOTSTRAP ═══" 213

# Check if DEV-BRAIN installed globally
if [ -d "$HOME/.config/opencode/skills" ]; then
  ok "DEV-BRAIN global detected"
else
  p "DEV-BRAIN not found globally — run install.sh first" 214
  [ -f "$DIR/install.sh" ] && bash "$DIR/install.sh" || { bad "install.sh not found"; exit 1; }
fi

# Create project-level structure
for d in memory tests skills .opencode; do
  mkdir -p "$d" && ok "dir: $d/"
done

# AGENTS.md project-level if missing
if [ ! -f AGENTS.md ]; then
  cat > AGENTS.md << 'EOF'
# Project DEV-BRAIN Config
EOF
  ok "AGENTS.md created"
else
  ok "AGENTS.md exists"
fi

# VERSION if missing
if [ ! -f VERSION ]; then
  echo "0.0.1" > VERSION
  ok "VERSION created (0.0.1)"
else
  ok "VERSION exists"
fi

# Run project install
if [ -f "$DIR/install.sh" ]; then
  bash "$DIR/install.sh" --project . 2>/dev/null && ok "project install done" || ok "project install skipped"
fi

p "═══ BOOTSTRAP SELESAI ═══" 82
p "Buka opencode di folder ini untuk mulai kerja." 248
