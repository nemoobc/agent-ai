#!/usr/bin/env bash
# metrics — show project metrics (loc, files, skills, agents)
# Usage: bash commands/metrics.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

p "═══ PROJECT METRICS ═══" 213

# LOC (shell scripts)
LOC=0
for f in $(find "$DIR" -name "*.sh" -not -path "*/node_modules/*" 2>/dev/null); do
  LINES=$(wc -l < "$f" 2>/dev/null || echo 0)
  LOC=$((LOC + LINES))
done
p "LOC (shell):   $LOC" 248

# Files
TOTAL_FILES=$(find "$DIR" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l)
p "Total files:   $TOTAL_FILES" 248

# Skills
SKILLS=$(ls "$DIR/skills/" 2>/dev/null | wc -l)
p "Skills:        $SKILLS" 248

# Agents
AGENTS=$(ls "$DIR/agents/" 2>/dev/null | wc -l)
p "Agents:        $AGENTS" 248

# Tests
TESTS=$(ls "$DIR/tests/" 2>/dev/null | wc -l)
p "Tests:         $TESTS" 248

# Commands
COMMANDS=$(ls "$DIR/commands/" 2>/dev/null | wc -l)
p "Commands:      $COMMANDS" 248

# Version
[ -f "$DIR/VERSION" ] && p "Version:       $(cat "$DIR/VERSION")" 82 || p "Version:       ?" 214
