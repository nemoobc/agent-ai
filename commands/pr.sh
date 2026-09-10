#!/usr/bin/env bash
# pr — create pull request
# Usage: bash commands/pr.sh [title]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
warn(){ p "  ⚠ $1" 214; }

p "═══ PULL REQUEST ═══" 213

if ! git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  bad "Not a git repo"
  exit 1
fi

# Check for changes
CHANGES=$(git -C "$DIR" status --porcelain 2>/dev/null | wc -l)
if [ "$CHANGES" -eq 0 ]; then
  warn "No changes to commit"
  exit 0
fi

# Check branch
BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null || echo "?")
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  warn "You're on $BRANCH — consider creating a feature branch first"
fi

TITLE="${1:-Update from $(date +%Y-%m-%d)}"

p "▶ Branch: $BRANCH" 248
p "▶ Title: $TITLE" 248
p "▶ Changes: $CHANGES files" 248

# Check if gh is available
if command -v gh > /dev/null 2>&1; then
  p "▶ Creating PR with gh..." 213
  git -C "$DIR" add -A 2>/dev/null
  git -C "$DIR" commit -m "$TITLE" 2>/dev/null
  PR_URL=$(gh pr create --title "$TITLE" --body "Auto-generated PR from commands/pr.sh" 2>/dev/null)
  if [ -n "$PR_URL" ]; then
    ok "PR created: $PR_URL"
  else
    bad "Failed to create PR"
  fi
else
  warn "gh CLI not found — do it manually"
  p "Steps:" 213
  p "  1. git add -A" 248
  p "  2. git commit -m \"$TITLE\"" 248
  p "  3. git push" 248
  p "  4. Create PR on GitHub" 248
fi
