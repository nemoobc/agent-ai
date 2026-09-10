#!/usr/bin/env bash
# doctor — diagnose kit health
# Usage: bash commands/doctor.sh [--fix]
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

p "═══ DOCTOR ═══" 213

if [ -f "$DIR/skills/doctor/run.sh" ]; then
  bash "$DIR/skills/doctor/run.sh" . "$@"
  EXIT=$?
  exit $EXIT
else
  p "Doctor skill not found — running basic checks" 214

  # Basic health checks
  ISSUES=0
  for f in VERSION AGENTS.md Makefile; do
    [ -f "$DIR/$f" ] && p "  ✔ $f exists" 82 || { p "  ✖ $f missing" 196; ISSUES=$((ISSUES+1)); }
  done

  for d in skills agents tests memory; do
    [ -d "$DIR/$d" ] && p "  ✔ $d/ exists" 82 || { p "  ✖ $d/ missing" 196; ISSUES=$((ISSUES+1)); }
  done

  # Check executables
  NOT_EXEC=$(find "$DIR/skills" -name "run.sh" ! -perm -u+x 2>/dev/null | wc -l)
  [ "$NOT_EXEC" -gt 0 ] && { p "  ✖ $NOT_EXEC run.sh not executable" 196; ISSUES=$((ISSUES+1)); } || p "  ✔ All run.sh executable" 82

  [ "$ISSUES" -eq 0 ] && p "═══ DOCTOR: SEHAT ═══" 82 || p "═══ DOCTOR: $ISSUES MASALAH ═══" 196
  exit $ISSUES
fi
