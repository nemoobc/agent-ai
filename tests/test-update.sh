#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  TEST-UPDATE — buktikan install.sh --update bekerja dua arah:
#  1) upgrade: remote lebih baru → ter-install, versi baru tercatat
#  2) anti-downgrade: remote lebih tua → ditolak, versi lama utuh
#  Pakai tarball LOKAL (tanpa jaringan) via DEV_BRAIN_UPDATE_URL.
#  Jalankan: bash tests/test-update.sh   (exit 0 = PASS)
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
PASS=0; FAIL=0
ok(){ p "  ✔ $1" 82; PASS=$((PASS+1)); }
bad(){ p "  ✖ $1" 196; FAIL=$((FAIL+1)); }

T=$(mktemp -d)
FH="$T/home"; REMOTE="$T/remote"; mkdir -p "$FH" "$REMOTE"

# ── siapkan "remote master" = salinan kit ini dengan VERSION khusus ──
mk_remote(){ # $1 = versi remote — nama folder WAJIB 'agent-ai*' (installer cari dengan find -name 'agent-ai*')
  rm -rf "$T/agent-ai" "$REMOTE"; mkdir -p "$T/agent-ai" "$REMOTE"
  cp -r "$DIR/agents" "$DIR/command" "$DIR/skills" "$DIR/memory" "$DIR/docs" "$DIR/tests" "$T/agent-ai/"
  cp "$DIR/AGENTS.md" "$DIR/README.md" "$DIR/CHANGELOG.md" "$DIR/LICENSE" "$DIR/install.sh" "$T/agent-ai/"
  echo "$1" > "$T/agent-ai/VERSION"
  tar -czf "$T/remote.tgz" -C "$T" agent-ai 2>/dev/null
}

p "▮ UPDATE: upgrade — remote 9.9.9 > lokal" 213
mk_remote "9.9.9"
HOME="$FH" bash "$DIR/install.sh" --offline >/dev/null 2>&1 || { bad "install awal gagal"; }
DEV_BRAIN_UPDATE_URL="file://$T/remote.tgz" HOME="$FH" bash "$DIR/install.sh" --update >/dev/null 2>&1
INSTV=$(tr -d '[:space:]' < "$FH/.config/opencode/VERSION" 2>/dev/null)
[ "$INSTV" = "9.9.9" ] && ok "update naik: terpasang $INSTV" || bad "update tidak naik (masih $INSTV, harusnya 9.9.9)"
[ -f "$FH/.config/opencode/skills/spec/SKILL.md" ] || [ -d "$FH/.config/opencode/skill/spec" ] && ok "file baru ikut ter-install" || bad "file baru tidak ikut"

p "▮ UPDATE: anti-downgrade — remote 0.1.0 < lokal 9.9.9" 213
mk_remote "0.1.0"
DEV_BRAIN_UPDATE_URL="file://$T/remote.tgz" HOME="$FH" bash "$DIR/install.sh" --update >/dev/null 2>&1
INSTV2=$(tr -d '[:space:]' < "$FH/.config/opencode/VERSION" 2>/dev/null)
[ "$INSTV2" = "9.9.9" ] && ok "anti-downgrade: tetap $INSTV2" || bad "ter-downgrade ke $INSTV2 — BUG!"

p "▮ UPDATE: tanpa URL override — tidak merusak offline" 213
HOME="$FH" timeout 15 bash "$DIR/install.sh" --offline >/dev/null 2>&1 && ok "install --offline tetap jalan" || bad "install --offline rusak"
HOME="$FH" bash "$DIR/install.sh" --check >/dev/null 2>&1 && ok "--check sehat setelah update" || bad "--check tidak sehat"

rm -rf "$T"
echo
if [ "$FAIL" -eq 0 ]; then p "UPDATE_RESULT: FLOW TERBUKTI ($PASS langkah)" 82; exit 0; fi
p "UPDATE_RESULT: GAGAL ($FAIL)" 196; exit 1