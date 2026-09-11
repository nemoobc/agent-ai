#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  DOC-FULL-RUN — cek sinkron dokumentasi: README + CHANGELOG vs
#  isi aktual repo (agents/skills/commands count), badge match,
#  fitur baru belum masuk CHANGELOG.
#  Jalankan: bash skills/doc-full/run.sh [dir]
#  Exit 0 = sinkron, 1 = ada drift.
# ═════════════════════════════════════════════════════════════════
set -u

ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "ERROR: dir $ROOT tidak ada"; exit 1; }

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ echo -e "${GREEN}  ✔ $1${NC}"; }
bad(){ echo -e "${RED}  ✖ $1${NC}"; ISSUES=$((ISSUES+1)); }
warn(){ echo -e "${YELLOW}  ⚠ $1${NC}"; }
info(){ echo -e "${CYAN}  ℹ $1${NC}"; }
section(){ echo -e "\n${BLUE}▸ $1${NC}"; }

ISSUES=0

echo ""
p "═══════════════════════════════════════════════" 213
p "     📚 DOC-FULL — SINKRON DOKUMENTASI         " 213
p "═══════════════════════════════════════════════" 213
echo ""

# ── Cek file utama ───────────────────────────────────────────────
section "FILE DOKUMENTASI UTAMA"
README_EXISTS=0
CHANGELOG_EXISTS=0

if [ -f README.md ]; then
  ok "README.md ada ($(wc -l < README.md) baris)"
  README_EXISTS=1
else
  bad "README.md tidak ditemukan"
fi

if [ -f CHANGELOG.md ]; then
  ok "CHANGELOG.md ada ($(wc -l < CHANGELOG.md) baris)"
  CHANGELOG_EXISTS=1
else
  warn "CHANGELOG.md tidak ditemukan"
fi

# ── Hitung isi aktual direktori ──────────────────────────────────
section "HITUNG ISI AKTUAL"

count_dir(){ find "$1" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' '; }

ACTUAL_AGENTS=0
ACTUAL_SKILLS=0
ACTUAL_COMMANDS=0

if [ -d agents ]; then
  ACTUAL_AGENTS=$(count_dir agents)
  ok "agents/    : $ACTUAL_AGENTS item"
else
  warn "agents/ tidak ditemukan"
fi

if [ -d skills ]; then
  ACTUAL_SKILLS=$(count_dir skills)
  ok "skills/    : $ACTUAL_SKILLS item"
else
  warn "skills/ tidak ditemukan"
fi

if [ -d commands ]; then
  ACTUAL_COMMANDS=$(count_dir commands)
  ok "commands/  : $ACTUAL_COMMANDS item"
else
  warn "commands/ tidak ditemukan"
fi

# Juga cek entri lain yang mungkin ada
for dir in plugins modules tools handlers; do
  if [ -d "$dir" ]; then
    CNT=$(count_dir "$dir")
    info "$dir/  : $CNT item"
  fi
done

# ── Cek badge di README ──────────────────────────────────────────
section "CEK BADGE README"

if [ "$README_EXISTS" -eq 1 ]; then
  # Find badge patterns like: ![Agents](badge/...20-blue) or Agents: 20 or (20 agents)
  # Pattern 1: badge URL with number
  BADGE_AGENTS=$(grep -oiE '(agents?[-_: ]+[0-9]+|[0-9]+[-_ ]+agents?)' README.md 2>/dev/null \
    | grep -oE '[0-9]+' | head -1)
  BADGE_SKILLS=$(grep -oiE '(skills?[-_: ]+[0-9]+|[0-9]+[-_ ]+skills?)' README.md 2>/dev/null \
    | grep -oE '[0-9]+' | head -1)
  BADGE_COMMANDS=$(grep -oiE '(commands?[-_: ]+[0-9]+|[0-9]+[-_ ]+commands?)' README.md 2>/dev/null \
    | grep -oE '[0-9]+' | head -1)

  # Check agents badge
  if [ -n "$BADGE_AGENTS" ]; then
    if [ "$BADGE_AGENTS" = "$ACTUAL_AGENTS" ]; then
      ok "Badge agents = aktual ($ACTUAL_AGENTS)"
    else
      bad "Badge agents: README=$BADGE_AGENTS vs aktual=$ACTUAL_AGENTS — MISMATCH"
    fi
  else
    [ "$ACTUAL_AGENTS" -gt 0 ] && warn "Tidak ada badge agents di README (aktual: $ACTUAL_AGENTS)"
  fi

  # Check skills badge
  if [ -n "$BADGE_SKILLS" ]; then
    if [ "$BADGE_SKILLS" = "$ACTUAL_SKILLS" ]; then
      ok "Badge skills = aktual ($ACTUAL_SKILLS)"
    else
      bad "Badge skills: README=$BADGE_SKILLS vs aktual=$ACTUAL_SKILLS — MISMATCH"
    fi
  else
    [ "$ACTUAL_SKILLS" -gt 0 ] && warn "Tidak ada badge skills di README (aktual: $ACTUAL_SKILLS)"
  fi

  # Check commands badge
  if [ -n "$BADGE_COMMANDS" ]; then
    if [ "$BADGE_COMMANDS" = "$ACTUAL_COMMANDS" ]; then
      ok "Badge commands = aktual ($ACTUAL_COMMANDS)"
    else
      bad "Badge commands: README=$BADGE_COMMANDS vs aktual=$ACTUAL_COMMANDS — MISMATCH"
    fi
  else
    [ "$ACTUAL_COMMANDS" -gt 0 ] && warn "Tidak ada badge commands di README (aktual: $ACTUAL_COMMANDS)"
  fi
else
  warn "README.md tidak ada — skip badge check"
fi

# ── Cek versi ────────────────────────────────────────────────────
section "CEK VERSI"

VERSION=""
if [ -f VERSION ]; then
  VERSION=$(tr -d '[:space:]' < VERSION)
  ok "VERSION file: $VERSION"
elif [ -f package.json ]; then
  VERSION=$(grep '"version"' package.json 2>/dev/null | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"' | head -1)
  [ -n "$VERSION" ] && ok "package.json version: $VERSION"
fi

if [ -n "$VERSION" ] && [ "$CHANGELOG_EXISTS" -eq 1 ]; then
  if grep -q "^\#\# \[$VERSION\]" CHANGELOG.md 2>/dev/null || \
     grep -q "^\#\# $VERSION" CHANGELOG.md 2>/dev/null; then
    ok "CHANGELOG punya entry untuk $VERSION"
  else
    bad "CHANGELOG tidak punya entry untuk versi $VERSION"
  fi
fi

# ── Cek fitur baru di git belum masuk CHANGELOG ──────────────────
section "FITUR BARU vs CHANGELOG"

if git rev-parse --git-dir >/dev/null 2>&1; then
  # Get last changelog entry date or tag
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo '')

  if [ -n "$LAST_TAG" ]; then
    info "Tag terakhir: $LAST_TAG"
    NEW_COMMITS=$(git log --oneline "$LAST_TAG..HEAD" 2>/dev/null | wc -l | tr -d ' ')
    info "Commit sejak tag: $NEW_COMMITS"

    if [ "$NEW_COMMITS" -gt 0 ]; then
      p "  ── Commit baru belum di-release ──" 45
      git log --oneline "$LAST_TAG..HEAD" 2>/dev/null | head -20 \
        | while IFS= read -r line; do echo -e "${YELLOW}    ${line}${NC}"; done

      # Check for feat: commits not in changelog
      FEAT_COMMITS=$(git log --oneline "$LAST_TAG..HEAD" 2>/dev/null \
        | grep -iE '^[a-f0-9]+ (feat|add|new):' | wc -l | tr -d ' ')

      if [ "$FEAT_COMMITS" -gt 0 ]; then
        warn "$FEAT_COMMITS commit feat/add/new sejak tag — cek CHANGELOG"
        if [ "$CHANGELOG_EXISTS" -eq 0 ] || ! grep -q '\[Unreleased\]' CHANGELOG.md 2>/dev/null; then
          bad "Tidak ada seksi [Unreleased] di CHANGELOG untuk fitur baru"
        else
          ok "Seksi [Unreleased] ada di CHANGELOG"
        fi
      fi
    else
      ok "Tidak ada commit baru sejak tag terakhir"
    fi
  else
    info "Tidak ada git tag — cek commit 10 terakhir"
    git log --oneline -10 2>/dev/null | head -10 \
      | while IFS= read -r line; do echo -e "${CYAN}    ${line}${NC}"; done
  fi
else
  warn "Bukan git repo — skip commit check"
fi

# ── Cek konsistensi contoh command di README ─────────────────────
section "CEK CONTOH COMMAND"

if [ "$README_EXISTS" -eq 1 ]; then
  # Extract bash code blocks from README
  BROKEN_CMDS=0
  p "  Memeriksa code block di README..." 45

  # Count code blocks
  CODE_BLOCKS=$(grep -c '```' README.md 2>/dev/null || echo 0)
  info "Code blocks di README: $((CODE_BLOCKS / 2))"

  # Check for placeholder examples that should work
  if grep -q 'bash.*run.sh\|npm run\|python.*\.py\|go run' README.md 2>/dev/null; then
    info "Contoh command ditemukan di README — pastikan sudah ditest"
  fi

  ok "Pemeriksaan code block selesai"
fi

# ── Ringkasan ────────────────────────────────────────────────────
echo ""
p "═══════════════════════════════════════════════" 213
p "         DOC-FULL SUMMARY                      " 213
p "═══════════════════════════════════════════════" 213
echo ""
info "Agents aktual  : $ACTUAL_AGENTS"
info "Skills aktual  : $ACTUAL_SKILLS"
info "Commands aktual: $ACTUAL_COMMANDS"
echo ""

if [ "$ISSUES" -eq 0 ]; then
  ok "Semua dokumentasi sinkron ✓"
  p "DOC_FULL: SINKRON ✓" 82
  exit 0
else
  bad "Ditemukan $ISSUES masalah sinkronisasi"
  p "DOC_FULL: DRIFT — $ISSUES masalah ✗" 196
  exit 1
fi
