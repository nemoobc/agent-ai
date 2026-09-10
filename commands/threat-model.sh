#!/usr/bin/env bash
# threat-model — analyze security threats
# Usage: bash commands/threat-model.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
warn(){ p "  ⚠ $1" 214; }
ok(){ p "  ✔ $1" 82; }

p "═══ THREAT MODEL ═══" 213

# Check for secrets in code
p "▶ Scanning for secrets..." 213
SECRET_COUNT=0
for pattern in "api_key" "password" "secret" "token" "AWS_" "OPENAI_"; do
  FOUND=$(grep -rl "$pattern" "$DIR" --include="*.sh" --include="*.md" 2>/dev/null | grep -v ".git" | head -3)
  if [ -n "$FOUND" ]; then
    warn "Potential secret pattern '$pattern' found:"
    echo "$FOUND" | while read -r f; do
      warn "  → $f"
    done
    SECRET_COUNT=$((SECRET_COUNT+1))
  fi
done
[ "$SECRET_COUNT" -eq 0 ] && ok "No obvious secrets found"

# Check for injection vectors
p "" 0
p "▶ Injection guard:" 213
if [ -f "$DIR/skills/injection-guard/run.sh" ]; then
  bash "$DIR/skills/injection-guard/run.sh" . 2>&1 || true
else
  warn "injection-guard skill not found"
fi

# Check file permissions
p "" 0
p "▶ File permissions:" 213
PERM_WORLD=$(find "$DIR" -type f -perm -o+w -not -path "*/.git/*" 2>/dev/null | wc -l)
[ "$PERM_WORLD" -gt 0 ] && warn "$PERM_WORLD files are world-writable" || ok "No world-writable files"

p "" 0
p "Review threats above. Run full security audit for deeper analysis." 248
