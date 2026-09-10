#!/usr/bin/env bash
# hotfix — emergency fix mode (freeze fitur, patch terkecil)
# Usage: bash commands/hotfix.sh [description]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }

p "═══ HOTFIX MODE ═══" 196
DESC="${1:-emergency fix}"
warn "FREEZE FITUR — hanya patch terkecil diperbolehkan"

# Check git
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  ok "Current branch: $BRANCH"
  warn "PASTIKAN: checkout hotfix branch dulu!"
fi

# Show what changed
if git rev-parse --git-dir > /dev/null 2>&1; then
  p "▶ Uncommitted changes:" 213
  git status --short 2>/dev/null
fi

p "" 0
p "HOTFIX RULES:" 196
p "1. Patch SEKECIL mungkin" 248
p "2. TIDAK ada fitur baru" 248
p "3. TIDAK ada refactor" 248
p "4. Test wajib jalan" 248
p "5. Deploy sesegera mungkin" 248

p "═══ HOTFIX: $DESC ═══" 214
