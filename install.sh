#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#   ██████╗ ███████╗██████╗
#   ██╔══██╗██╔════╝██╔══██╗     D E V — B R A I N
#   ██║  ██║███████╗██████╔╝     agent-ai full-agent installer
#   ██║  ██║╚════██║██╔═══╝      caveman mode • permanen • ultronomatis
#   ██████╔╝███████║██║          auto: think→build→test→audit→fix
#   ╚═════╝ ╚══════╝╚═╝
# ─────────────────────────────────────────────────────────────────
# Pakai  : bash install.sh [--project DIR] [--uninstall]
# ═════════════════════════════════════════════════════════════════
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── warna ──
if [ -t 1 ]; then pc(){ printf '\033[38;5;%sm%s\033[0m\n' "$1" "$2"; }
else pc(){ printf '%s\n' "$2"; }; fi
ok(){ pc 82  "  ✔ $1"; }
inf(){ pc 45  "  ▸ $1"; }
wrn(){ pc 214 "  ⚠ $1"; }
err(){ pc 196 "  ✖ $1"; }
step(){ printf '\n'; pc 213 "══════ $1 ══════"; }

CFG="$HOME/.config/opencode"
IS_TERMUX=0
[ -n "${TERMUX_VERSION:-}" ] && IS_TERMUX=1
[ -d /data/data/com.termux ] && IS_TERMUX=1

usage(){ cat <<'X'
Pemakaian:
  bash install.sh                 install global (~/.config/opencode)
  bash install.sh --project DIR   sekalian pasang ke project (DIR/.opencode)
  bash install.sh --check         cek kesehatan instalasi (tanpa menulis)
  bash install.sh --uninstall     buang agent & doctrine (memori DIPERTAHANKAN)
X
}

# ── argumen ──
PROJECT=""; UNINSTALL=0; CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) [ $# -ge 2 ] || { err "--project butuh path folder"; exit 1; }; PROJECT="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    --check) CHECK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) wrn "arg tak dikenal: $1 (diabaikan)"; shift ;;
  esac
done

banner(){
  pc 213 '   ██████╗ ███████╗██████╗ '
  pc 177 '   ██╔══██╗██╔════╝██╔══██╗'
  pc 141 '   ██║  ██║███████╗██████╔╝'
  pc 105 '   ██║  ██║╚════██║██╔═══╝ '
  pc 69  '   ██████╔╝███████║██║     '
  pc 33  '   ╚═════╝ ╚══════╝╚═╝     B R A I N'
  echo
  pc 45 "   otak utama: DEV • caveman mode ULTRA • ultronomatis"
  [ -f "$SCRIPT_DIR/VERSION" ] && pc 45 "   versi: $(cat "$SCRIPT_DIR/VERSION" | tr -d '[:space:]')"
  pc 45 "   auto test/audit/fix ✓ • memori persisten ✓"
  echo
}

# ── uninstall ──
uninstall(){
  step "UNINSTALL DEV-BRAIN"
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command"
  rm -f "$CFG/AGENTS.md"
  BAK=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  if [ -n "${BAK:-}" ]; then mv "$BAK" "$CFG/opencode.json"; ok "opencode.json dipulihkan dari backup"
  elif [ -f "$CFG/opencode.json" ] && grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    rm -f "$CFG/opencode.json"; ok "opencode.json buatan DEV-BRAIN dihapus"
  fi
  wrn "folder memory/ DIPERTAHANKAN (isi ingatan kamu)"
  ok "uninstall selesai — DEV-BRAIN dilepas"
  exit 0
}

# ── tulis file dari script dir ke CFG ──
write_brain(){
  step "TULIS OTAK → ~/.config/opencode"
  # prune instalasi lama biar tidak ada file sisa dari versi sebelumnya
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command"
  mkdir -p "$CFG/agent" "$CFG/command" "$CFG/memory" \
    "$CFG/skill/think" "$CFG/skill/imagine" "$CFG/skill/remember" "$CFG/skill/recall" \
    "$CFG/skill/caveman" "$CFG/skill/scan" "$CFG/skill/plan" "$CFG/skill/debug" "$CFG/skill/doc-full" \
    "$CFG/skill/doctor" \
    "$CFG/skill/test-full" "$CFG/skill/audit-full" "$CFG/skill/fix-full"

  # backup config lama HANYA bila itu bukan tulisan DEV-BRAIN (marker)
  if [ -f "$CFG/opencode.json" ] && ! grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    cp "$CFG/opencode.json" "$CFG/opencode.json.bak.$(date +%s)"
  fi

  # opencode.json: izin granular — script kit & git read-only boleh,
  # command lain tetap minta konfirmasi (blast radius kecil)
  cat > "$CFG/opencode.json" <<'EOF'
{
  "devbrain": true,
  "permission": {
    "edit": "allow",
    "write": "allow",
    "webfetch": "allow",
    "bash": {
      "*skill*/run.sh*": "allow",
      "*test-full/run.sh*": "allow",
      "*audit-full/run.sh*": "allow",
      "*fix-full/run.sh*": "allow",
      "git status": "allow",
      "git diff*": "allow",
      "git log*": "allow",
      "*": "ask"
    }
  }
}
EOF

  # copy agents
  for f in "$SCRIPT_DIR/agents/"*.md; do
    [ -f "$f" ] && cp "$f" "$CFG/agent/" && ok "agent: $(basename "$f")"
  done

  # copy skills (SKILL.md + run.sh)
  for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$CFG/skill/$skill_name"
    [ -f "$skill_dir/SKILL.md" ] && cp "$skill_dir/SKILL.md" "$CFG/skill/$skill_name/"
    [ -f "$skill_dir/run.sh" ] && { cp "$skill_dir/run.sh" "$CFG/skill/$skill_name/"; chmod +x "$CFG/skill/$skill_name/run.sh"; }
    ok "skill: $skill_name"
  done

  # copy commands
  for f in "$SCRIPT_DIR/command/"*.md; do
    [ -f "$f" ] && cp "$f" "$CFG/command/" && ok "command: $(basename "$f")"
  done

  # copy AGENTS.md (doctrine)
  [ -f "$SCRIPT_DIR/AGENTS.md" ] && cp "$SCRIPT_DIR/AGENTS.md" "$CFG/" && ok "doctrine: AGENTS.md"

  # copy memory seed
  for f in "$SCRIPT_DIR/memory/"*.md; do
    [ -f "$f" ] && [ ! -f "$CFG/memory/$(basename "$f")" ] && cp "$f" "$CFG/memory/"
  done

  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  ok "total $N file otak ditulis"
}

# ── pasang ke project ──
install_project(){
  step "PASANG KE PROJECT: $PROJECT"
  if [ ! -d "$PROJECT" ]; then err "folder tidak ditemukan: $PROJECT"; return 1; fi
  # backup AGENTS.md project bila bukan tulisan DEV-BRAIN (marker)
  if [ -f "$PROJECT/AGENTS.md" ] && ! grep -q 'DEV-BRAIN (project ini)' "$PROJECT/AGENTS.md" 2>/dev/null; then
    cp "$PROJECT/AGENTS.md" "$PROJECT/AGENTS.md.bak.$(date +%s)"
    wrn "AGENTS.md project dibackup (isi asli dipertahankan di .bak)"
  fi
  # prune instalasi lama di project biar tidak ada file sisa
  rm -rf "$PROJECT/.opencode/agent" "$PROJECT/.opencode/skill" "$PROJECT/.opencode/command"
  mkdir -p "$PROJECT/.opencode/memory"
  cp -r "$CFG/agent"   "$PROJECT/.opencode/" 2>/dev/null
  cp -r "$CFG/skill"   "$PROJECT/.opencode/" 2>/dev/null
  cp -r "$CFG/command" "$PROJECT/.opencode/" 2>/dev/null
  [ -f "$PROJECT/.opencode/memory/MEMORY.md" ] || cp "$CFG/memory/MEMORY.md" "$PROJECT/.opencode/memory/"
  cat > "$PROJECT/AGENTS.md" <<'EOF'
# DEV-BRAIN (project ini)
Otak utama: DEV — caveman mode ULTRA, pipeline otomatis:
recall+scan → think → imagine+architect → plan → coder → test → audit → fix → (BUG? debug) → (DOK? doc-full) → memory → lapor.
Memori project: `.opencode/memory/`. Doctrine lengkap: `~/.config/opencode/AGENTS.md`.
Tidak perlu command manual — ketik tugas, DEV mengorkestrasi sendiri.
EOF
  ok "terpasang di $PROJECT/.opencode + AGENTS.md"
}

# ── verifikasi instalasi ──
check_install(){
  step "CHECK INSTALASI DEV-BRAIN"
  BAD=0
  [ -f "$CFG/AGENTS.md" ] || { err "doctrine hilang: $CFG/AGENTS.md"; BAD=1; }
  [ -f "$CFG/opencode.json" ] || { err "config hilang: $CFG/opencode.json"; BAD=1; }
  grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null || { wrn "opencode.json tanpa marker devbrain (bukan tulisan installer)"; }
  for d in agent command memory skill; do
    [ -d "$CFG/$d" ] || { err "folder hilang: $CFG/$d"; BAD=1; }
  done
  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${N:-0}" -ge 20 ] || { err "file otak cuma $N — install ulang"; BAD=1; }
  for s in "$CFG"/skill/*/run.sh; do
    [ -f "$s" ] || continue
    bash -n "$s" 2>/dev/null || { err "script rusak: $s"; BAD=1; }
  done
  if [ "$BAD" -eq 0 ]; then ok "instalasi sehat — $N file otak, semua script valid"; return 0; else return 1; fi
}

# ── verifikasi & banner akhir ──
finish(){
  step "VERIFIKASI"
  echo
  pc 213 '  ╔════════════════════════════════════════╗'
  pc 177 '  ║   D E V — B R A I N   O N L I N E      ║'
  pc 141 '  ╚════════════════════════════════════════╝'
  echo
  ok "7 agent • 13 skill (4 dengan bash script) • 5 command • memori persisten"
  echo
  pc 45  "  CARA PAKAI:"
  pc 45  "  1) buka folder project apa saja"
  pc 45  "  2) jalankan:  opencode"
  pc 45  "  3) DEV otomatis aktif (satu-satunya primary)"
  pc 45  "  4) ketik tugas bahasa bebas, contoh:"
  pc 213 "     \"buat halaman login, testnya sekalian, audit juga\""
  pc 45  "  5) DEV jalan: mikir→bayang→bangun→test→audit→fix→ingat"
  echo
  pc 45  "  SHORTCUT : /ship <tugas>   /fix   /memory"
  pc 214 "  API key  : jalankan  opencode auth login  bila belum"
  echo
}

# ═══ MAIN ═══
banner
[ "$UNINSTALL" -eq 1 ] && { uninstall; }
[ "$CHECK" -eq 1 ] && { check_install; exit $?; }
write_brain
[ -n "$PROJECT" ] && install_project
finish
