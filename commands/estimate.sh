#!/usr/bin/env bash
# estimate — estimate task size
# Usage: bash commands/estimate.sh [file_count]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

FILE_COUNT="${1:-0}"
p "═══ TASK ESTIMATE ═══" 213

if [ "$FILE_COUNT" -eq 0 ]; then
  # Auto-count files in project
  FILE_COUNT=$(find "$DIR" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l)
  p "Auto-detected files: $FILE_COUNT" 248
fi

# Estimate based on file count
if [ "$FILE_COUNT" -le 5 ]; then
  SIZE="SMALL"
  DESC="< 30 menit, 1-2 agent calls"
elif [ "$FILE_COUNT" -le 15 ]; then
  SIZE="MEDIUM"
  DESC="30-60 menit, plan + build + test"
elif [ "$FILE_COUNT" -le 30 ]; then
  SIZE="LARGE"
  DESC="1-2 jam, full pipeline"
else
  SIZE="ULTRA"
  DESC="> 2 jam, milestone required"
fi

p "Estimated size: $SIZE" 213
p "Description: $DESC" 248

# Checklist
p "" 0
p "Checklist sebelum kerja:" 213
p "  1. scan → understand codebase" 248
p "  2. think → mental model" 248
p "  3. imagine → possibilities" 248
p "  4. plan → 8-block plan" 248
p "  5. test-design → test cases BEFORE coding" 248
p "  6. build → implement" 248
p "  7. test → verify" 248
p "  8. audit → check quality" 248
