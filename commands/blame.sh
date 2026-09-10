#!/usr/bin/env bash
# blame — show git blame for recent changes
# Usage: bash commands/blame.sh [file] [--last N]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
warn(){ p "  ⚠ $1" 214; }

p "═══ GIT BLAME ═══" 213

if ! git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  warn "Not a git repo"
  exit 1
fi

FILE="${1:-}"
LAST="${2:-10}"

if [ -n "$FILE" ] && [ "$FILE" != "--last" ]; then
  # Blame specific file
  if [ -f "$DIR/$FILE" ]; then
    p "▶ Blame: $FILE" 213
    git -C "$DIR" blame --line-porcelain "$FILE" 2>/dev/null | grep -E "^(author |[0-9a-f]{40})" | head -60
  else
    warn "File not found: $FILE"
  fi
else
  # Recent changes
  p "▶ Last $LAST commits:" 213
  git -C "$DIR" log --oneline -"$LAST" 2>/dev/null | while read -r line; do
    HASH=$(echo "$line" | awk '{print $1}')
    MSG=$(echo "$line" | cut -d' ' -f2-)
    p "  $HASH $MSG" 248
  done

  p "" 0
  p "▶ Who changed what (last $LAST commits):" 213
  git -C "$DIR" shortlog -sn -"$LAST" 2>/dev/null | while read -r line; do
    p "  $line" 248
  done
fi
