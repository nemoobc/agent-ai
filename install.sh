#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#   ██████╗ ███████╗██████╗
#   ██╔══██╗██╔════╝██╔══██╗     A G E N T   A I
#   ██║  ██║███████╗██████╔╝     agent-ai full-agent installer
#   ██║  ██║╚════██║██╔═══╝      caveman mode • permanen • ultronomatis
#   ██████╔╝███████║██║          auto: think→build→test→audit→fix
#   ╚═════╝ ╚══════╝╚═╝
# ─────────────────────────────────────────────────────────────────
# Pakai  : bash install.sh [--project DIR] [--uninstall]
# ═════════════════════════════════════════════════════════════════
clear
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
  bash install.sh --update        update ke versi terbaru dari GitHub (memori aman)
  bash install.sh --version       tampilkan versi
  bash install.sh --uninstall     buang agent & doctrine (memori DIPERTAHANKAN)
  bash install.sh --offline       tanpa cek jaringan (offline/CI aman, tanpa menunggu)
  bash install.sh --hook          pasang pre-commit hook git-guard ke project ini (.git/hooks)
  bash install.sh --lint          jalankan lint-kit + self-test setelah install (verifikasi)
  env DEV_BRAIN_UPDATE_URL=...    override URL update (untuk tes/file://)

Di dalam opencode (tanpa install global di project ini):
  /bootstrap                      pasang AGENT AI ke project ini (.opencode/)
X
}
PROJECT=""; UNINSTALL=0; CHECK=0; UPDATE=0; SHOWVER=0; OFFLINE=0; HOOK=0; LINT=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) [ $# -ge 2 ] || { err "--project butuh path folder"; exit 1; }; PROJECT="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    --check) CHECK=1; shift ;;
    --update) UPDATE=1; shift ;;
    --version) SHOWVER=1; shift ;;
    --offline) OFFLINE=1; shift ;;
    --hook) HOOK=1; shift ;;
    --lint) LINT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) wrn "arg tak dikenal: $1 (diabaikan)"; shift ;;
  esac
done

banner(){
  local v=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')
  echo
  pc 32 '  ╔═══════════════════════════════════╗'
  pc 32 '  ║                                   ║'
  pc 31 '  ║       A G E N T   A I             ║'
  pc 32 '  ║                                   ║'
  pc 32 '  ╚═══════════════════════════════════╝'
  echo
  pc 45 "   otak utama: DEV • caveman mode ULTRA • ultronomatis"
  [ -n "$v" ] && pc 45 "   versi: $v"
  pc 45 "   auto test/audit/fix ✓ • memori persisten ✓"
  echo
  echo
}

loading(){
  local msg="${1:-Memuat}"
  local i=0
  local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  while true; do
    printf "\r  ${chars:i++%${#chars}:1} $msg"
    sleep 0.1
  done
}

# ── update dari GitHub ──
REPO="nemoobc/agent-ai"
# URL override: untuk tes lokal (file://) — set DEV_BRAIN_UPDATE_URL
UPDATE_URL="${DEV_BRAIN_UPDATE_URL:-https://codeload.github.com/$REPO/tar.gz/refs/heads/master}"
update(){
  step "UPDATE AGENT AI"
  command -v curl >/dev/null 2>&1 || { err "curl tidak ada — update manual: git clone $REPO"; exit 1; }
  TMP=$(mktemp -d)
  inf "unduh master terbaru…"
  # timeout wajib: connect 5s, total 60s — offline/nyangkut tetap selesai, tidak menggantung shell agent
  curl -fsSL --connect-timeout 5 --max-time 60 "$UPDATE_URL" -o "$TMP/kit.tgz" \
    || { err "unduh gagal — cek koneksi"; rm -rf "$TMP"; exit 1; }
  tar -xzf "$TMP/kit.tgz" -C "$TMP" || { err "ekstrak gagal"; rm -rf "$TMP"; exit 1; }
  SRC=$(find "$TMP" -maxdepth 1 -type d -name 'agent-ai*' | head -1)
  [ -f "$SRC/install.sh" ] || { err "paket tidak valid"; rm -rf "$TMP"; exit 1; }
  NEWV=$(tr -d '[:space:]' < "$SRC/VERSION" 2>/dev/null)
  OLDV=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  inf "terpasang: ${OLDV:-?} → tersedia: ${NEWV:-?}"
  # anti-downgrade: hanya update bila remote LEBIH BARU (semver compare)
  OLDER=$(printf '%s\n%s\n' "${OLDV:-0}" "${NEWV:-0}" | sort -V | head -1)
  if [ -n "$OLDV" ] && [ "$OLDER" != "$OLDV" ]; then
    ok "remote ($NEWV) tidak lebih baru dari terpasang ($OLDV) — skip"
    rm -rf "$TMP"; exit 0
  fi
  if [ "$NEWV" = "$OLDV" ]; then ok "sudah versi terbaru"; rm -rf "$TMP"; exit 0; fi
  if bash "$SRC/install.sh" --offline; then ok "update ke $NEWV selesai — memori tetap aman"; else err "update gagal di tengah — instalasi lama utuh"; fi
  rm -rf "$TMP"
  # penting: jangan lanjut write_brain ulang — inner install sudah menulis semuanya
  exit 0
}

# ── cek versi remote (non-blokir, offline aman) ──
check_remote_version(){
  [ "$OFFLINE" -eq 1 ] && return 0
  command -v curl >/dev/null 2>&1 || return 0
  REMOTE=$(curl -fsSL --connect-timeout 2 --max-time 3 "https://raw.githubusercontent.com/$REPO/master/VERSION" 2>/dev/null | tr -d '[:space:]')
  [ -n "$REMOTE" ] || return 0
  LOCALV=$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null)
  # Simple semver compare: only warn if REMOTE is actually newer
  if [ -n "$LOCALV" ] && [ "$REMOTE" != "$LOCALV" ]; then
    # Compare major.minor.patch numerically
    LOCAL_MAJOR=$(echo "$LOCALV" | cut -d. -f1); REMOTE_MAJOR=$(echo "$REMOTE" | cut -d. -f1)
    LOCAL_MINOR=$(echo "$LOCALV" | cut -d. -f2); REMOTE_MINOR=$(echo "$REMOTE" | cut -d. -f2)
    LOCAL_PATCH=$(echo "$LOCALV" | cut -d. -f3); REMOTE_PATCH=$(echo "$REMOTE" | cut -d. -f3)
    if [ "${REMOTE_MAJOR:-0}" -gt "${LOCAL_MAJOR:-0}" ] 2>/dev/null || \
       { [ "${REMOTE_MAJOR:-0}" -eq "${LOCAL_MAJOR:-0}" ] 2>/dev/null && [ "${REMOTE_MINOR:-0}" -gt "${LOCAL_MINOR:-0}" ] 2>/dev/null; } || \
       { [ "${REMOTE_MAJOR:-0}" -eq "${LOCAL_MAJOR:-0}" ] 2>/dev/null && [ "${REMOTE_MINOR:-0}" -eq "${LOCAL_MINOR:-0}" ] 2>/dev/null && [ "${REMOTE_PATCH:-0}" -gt "${LOCAL_PATCH:-0}" ] 2>/dev/null; }; then
      wrn "versi baru tersedia: $REMOTE (lokal $LOCALV) — update: bash install.sh --update"
    fi
  fi
}

# ── uninstall ──
uninstall(){
  step "UNINSTALL AGENT AI"
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command" "$CFG/docs"
  rm -f "$CFG/AGENTS.md"
  BAK=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  if [ -n "${BAK:-}" ]; then mv "$BAK" "$CFG/opencode.json"; ok "opencode.json dipulihkan dari backup"
  elif [ -f "$CFG/opencode.json" ] && grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    rm -f "$CFG/opencode.json"; ok "opencode.json buatan AGENT AI dihapus"
  fi
  wrn "folder memory/ DIPERTAHANKAN (isi ingatan kamu)"
  ok "uninstall selesai — AGENT AI dilepas"
  exit 0
}

# ── tulis file dari script dir ke CFG ──
write_brain(){
  step "TULIS OTAK → ~/.config/opencode"
  # prune instalasi lama biar tidak ada file sisa dari versi sebelumnya
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command"
  mkdir -p "$CFG/agent" "$CFG/command" "$CFG/memory" \
    "$CFG/skill/think" "$CFG/skill/imagine" "$CFG/skill/remember" "$CFG/skill/recall" \
    "$CFG/skill/caveman" "$CFG/skill/caveman-warmup" "$CFG/skill/scan" "$CFG/skill/plan" \
    "$CFG/skill/debug" "$CFG/skill/doc-full" \
    "$CFG/skill/doctor" "$CFG/skill/review" "$CFG/skill/refactor" "$CFG/skill/cost" \
    "$CFG/skill/perf" "$CFG/skill/explain" "$CFG/skill/i18n" "$CFG/skill/changelog" \
    "$CFG/skill/learn" "$CFG/skill/milestone" "$CFG/skill/test-design" "$CFG/skill/api-design" \
    "$CFG/skill/migrate" "$CFG/skill/postmortem" "$CFG/skill/spec" "$CFG/skill/research" \
    "$CFG/skill/red-team" "$CFG/skill/team" "$CFG/skill/autonomy" "$CFG/skill/metrics" \
    "$CFG/skill/handoff" "$CFG/skill/a11y"    "$CFG/skill/context" "$CFG/skill/pr" \
    "$CFG/skill/git-guard" "$CFG/skill/env-guard" "$CFG/skill/backup" "$CFG/skill/dependency" \
    "$CFG/skill/hotfix" "$CFG/skill/recovery" "$CFG/skill/convention" "$CFG/skill/coverage" \
    "$CFG/skill/budget" "$CFG/skill/clean" "$CFG/skill/critique" "$CFG/skill/deliver" \
    "$CFG/skill/estimate" "$CFG/skill/eval" "$CFG/skill/injection-guard" "$CFG/skill/profile" \
    "$CFG/skill/threat-model" "$CFG/skill/trace" \
    "$CFG/skill/test-full" "$CFG/skill/audit-full" "$CFG/skill/fix-full"

  # spinner
  local sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  (while true; do printf "\r  ${sp:i++%${#sp}:1} menyalin file otak..."; sleep 0.08; done) &
  SPID=$!

  # backup config lama HANYA bila itu bukan tulisan AGENT AI (marker)
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
    [ -f "$f" ] && cp "$f" "$CFG/agent/"
  done
  local agent_count=$(ls "$CFG/agent/"*.md 2>/dev/null | wc -l)

  # copy skills (SKILL.md + run.sh)
  for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$CFG/skill/$skill_name"
    [ -f "$skill_dir/SKILL.md" ] && cp "$skill_dir/SKILL.md" "$CFG/skill/$skill_name/"
    [ -f "$skill_dir/run.sh" ] && { cp "$skill_dir/run.sh" "$CFG/skill/$skill_name/"; chmod +x "$CFG/skill/$skill_name/run.sh"; }
  done
  local skill_count=$(ls -d "$CFG/skill/"*/ 2>/dev/null | wc -l)

  # copy commands
  for f in "$SCRIPT_DIR/command/"*.md; do
    [ -f "$f" ] && cp "$f" "$CFG/command/"
  done
  local cmd_count=$(ls "$CFG/command/"*.md 2>/dev/null | wc -l)

  # stop spinner
  kill $SPID 2>/dev/null; wait $SPID 2>/dev/null
  printf "\r\033[K"
  ok "agent: $agent_count file"
  ok "skill: $skill_count folder"
  ok "command: $cmd_count file"

  # copy AGENTS.md (doctrine)
  [ -f "$SCRIPT_DIR/AGENTS.md" ] && cp "$SCRIPT_DIR/AGENTS.md" "$CFG/" && ok "doctrine: AGENTS.md"

  # copy panduan lengkap
  mkdir -p "$CFG/docs"
  [ -f "$SCRIPT_DIR/docs/USAGE.md" ] && cp "$SCRIPT_DIR/docs/USAGE.md" "$CFG/docs/" && ok "panduan: docs/USAGE.md"
  [ -f "$SCRIPT_DIR/docs/PLAYBOOKS.md" ] && cp "$SCRIPT_DIR/docs/PLAYBOOKS.md" "$CFG/docs/" && ok "playbook: docs/PLAYBOOKS.md"
  [ -f "$SCRIPT_DIR/docs/ARCHITECTURE.md" ] && cp "$SCRIPT_DIR/docs/ARCHITECTURE.md" "$CFG/docs/" && ok "arsitektur: docs/ARCHITECTURE.md"
  [ -f "$SCRIPT_DIR/docs/ROADMAP.md" ] && cp "$SCRIPT_DIR/docs/ROADMAP.md" "$CFG/docs/" && ok "roadmap: docs/ROADMAP.md"

  # copy memory seed
  for f in "$SCRIPT_DIR/memory/"*.md; do
    [ -f "$f" ] && [ ! -f "$CFG/memory/$(basename "$f")" ] && cp "$f" "$CFG/memory/"
  done

  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  ok "total $N file otak ditulis"
  # catat versi terpasang (dipakai --check, doctor, --update)
  [ -f "$SCRIPT_DIR/VERSION" ] && cp "$SCRIPT_DIR/VERSION" "$CFG/VERSION"
}

# ── pasang ke project ──
install_project(){
  step "PASANG KE PROJECT: $PROJECT"
  if [ ! -d "$PROJECT" ]; then err "folder tidak ditemukan: $PROJECT"; return 1; fi
  # backup AGENTS.md project bila bukan tulisan AGENT AI (marker)
  if [ -f "$PROJECT/AGENTS.md" ] && ! grep -q 'AGENT AI (project ini)' "$PROJECT/AGENTS.md" 2>/dev/null; then
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
# AGENT AI (project ini)
Otak utama: DEV — caveman mode ULTRA, pipeline otomatis:
recall+scan → think → imagine+architect → plan (rencana 8 blok TAMPIL dulu) → coder → test → audit → fix → (BUG? debug) → (DOK? doc-full) → (MAHAL? cost) → memory → lapor.
Memori project: `.opencode/memory/`. Doctrine lengkap: `~/.config/opencode/AGENTS.md`.
Tidak perlu command manual — ketik tugas, DEV mengorkestrasi sendiri.
EOF
  ok "terpasang di $PROJECT/.opencode + AGENTS.md"
}

# ── verifikasi instalasi ──
check_install(){
  step "CHECK INSTALASI AGENT AI"
  BAD=0
  [ -f "$CFG/AGENTS.md" ] || { err "doctrine hilang: $CFG/AGENTS.md"; BAD=1; }
  [ -f "$CFG/opencode.json" ] || { err "config hilang: $CFG/opencode.json"; BAD=1; }
  grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null || { wrn "opencode.json tanpa marker devbrain (bukan tulisan installer)"; }
  for d in agent command memory skill; do
    [ -d "$CFG/$d" ] || { err "folder hilang: $CFG/$d"; BAD=1; }
  done
  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${N:-0}" -ge 20 ] || { err "file otak cuma $N — install ulang"; BAD=1; }
  V=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  if [ -n "$V" ]; then ok "versi terpasang: $V"; else wrn "versi tidak tercatat (install lama) — update disarankan"; fi
  for s in "$CFG"/skill/*/run.sh; do
    [ -f "$s" ] || continue
    bash -n "$s" 2>/dev/null || { err "script rusak: $s"; BAD=1; }
  done
  if [ "$BAD" -eq 0 ]; then ok "instalasi sehat — $N file otak, semua script valid"; return 0; else return 1; fi
}

# ── pasang pre-commit hook git-guard ──
install_hook(){
  step "HOOK GIT-GUARD"
  [ -d .git ] || { err "bukan git repo — jalankan dari root project"; return 1; }
  mkdir -p .git/hooks
  if [ -f .git/hooks/pre-commit ] && ! grep -q 'devbrain' .git/hooks/pre-commit 2>/dev/null; then
    cp .git/hooks/pre-commit ".git/hooks/pre-commit.bak.$(date +%s)"
    wrn "pre-commit lama dibackup (.bak)"
  fi
  cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# AGENT AI git-guard (marker: devbrain) — blokir secret/marker/debug di staged diff
GUARD="$HOME/.config/opencode/skill/git-guard/run.sh"
[ -f "$GUARD" ] && exec bash "$GUARD"
EOF
  chmod +x .git/hooks/pre-commit
  ok "pre-commit → git-guard terpasang (setiap commit otomatis di-scan)"
}

# ── verifikasi & banner akhir ──
finish(){
  echo
  pc 33 '  ╔═══════════════════════════════╗'
  pc 33 '  ║                               ║'
  pc 33 '  ║         S U K S E S           ║'
  pc 33 '  ║                               ║'
  pc 33 '  ╚═══════════════════════════════╝'
  echo
}

# ═══ MAIN ═══
banner
[ "$SHOWVER" -eq 1 ] && { pc 45 "AGENT AI v$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo '?')"; exit 0; }
[ "$UNINSTALL" -eq 1 ] && { uninstall; }
[ "$CHECK" -eq 1 ] && { check_install; exit $?; }
[ "$UPDATE" -eq 1 ] && { update; }
check_remote_version
write_brain
[ -n "$PROJECT" ] && install_project
[ "$HOOK" -eq 1 ] && install_hook
finish
if [ "$LINT" -eq 1 ] && [ -f "$SCRIPT_DIR/tests/lint-kit.sh" ]; then
  step "LINT VERIFIKASI"
  bash "$SCRIPT_DIR/tests/lint-kit.sh" && bash "$SCRIPT_DIR/tests/self-test.sh"
  echo
fi
exit 0
