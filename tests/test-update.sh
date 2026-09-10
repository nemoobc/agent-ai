#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  TEST-UPDATE — buktikan install.sh --update bekerja dua arah:
#  1) upgrade: remote lebih baru → ter-install, versi baru tercatat
#  2) anti-downgrade: remote lebih tua → ditolak, versi lama utuh
#  3) memory safety: memori tidak hilang saat update
#  4) check: instalasi sehat setelah update
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

# ── versi dinamis relatif ke VERSION lokal (HUKUM 10: jangan hardcode) ──
LOCAL_V=$(tr -d '[:space:]' < "$DIR/VERSION" 2>/dev/null)
MAJOR=$(echo "$LOCAL_V" | cut -d. -f1)
NEWER_V="$((MAJOR+1)).0.0"   # selalu lebih baru dari lokal
OLDER_V="0.1.0"              # selalu lebih tua dari lokal
p "▮ UPDATE: versi lokal = $LOCAL_V (upgrade target: $NEWER_V, downgrade target: $OLDER_V)" 213

# ── siapkan "remote master" = salinan kit ini dengan VERSION khusus ──
mk_remote(){ # $1 = versi remote — nama folder WAJIB 'agent-ai*' (installer cari dengan find -name 'agent-ai*')
  rm -rf "$T/agent-ai" "$REMOTE"; mkdir -p "$T/agent-ai" "$REMOTE"
  cp -r "$DIR/agents" "$DIR/command" "$DIR/skills" "$DIR/memory" "$DIR/docs" "$DIR/tests" "$T/agent-ai/"
  cp "$DIR/AGENTS.md" "$DIR/README.md" "$DIR/CHANGELOG.md" "$DIR/LICENSE" "$DIR/install.sh" "$T/agent-ai/"
  echo "$1" > "$T/agent-ai/VERSION"
  tar -czf "$T/remote.tgz" -C "$T" agent-ai 2>/dev/null
}

# ══ FLOW 1: upgrade naik ══
p "▮ UPDATE 1/6: upgrade — remote $NEWER_V > lokal $LOCAL_V" 213
mk_remote "$NEWER_V"
HOME="$FH" bash "$DIR/install.sh" --offline >/dev/null 2>&1 || { bad "install awal gagal"; }
DEV_BRAIN_UPDATE_URL="file://$T/remote.tgz" HOME="$FH" bash "$DIR/install.sh" --update >/dev/null 2>&1
INSTV=$(tr -d '[:space:]' < "$FH/.config/opencode/VERSION" 2>/dev/null)
[ "$INSTV" = "$NEWER_V" ] && ok "update naik: terpasang $INSTV" || bad "update tidak naik (masih $INSTV, harusnya $NEWER_V)"
[ -f "$FH/.config/opencode/skills/spec/SKILL.md" ] || [ -d "$FH/.config/opencode/skill/spec" ] && ok "file baru ikut ter-install" || bad "file baru tidak ikut"

# ══ FLOW 2: anti-downgrade ══
p "▮ UPDATE 2/6: anti-downgrade — remote $OLDER_V < lokal $NEWER_V" 213
mk_remote "$OLDER_V"
DEV_BRAIN_UPDATE_URL="file://$T/remote.tgz" HOME="$FH" bash "$DIR/install.sh" --update >/dev/null 2>&1
INSTV2=$(tr -d '[:space:]' < "$FH/.config/opencode/VERSION" 2>/dev/null)
[ "$INSTV2" = "$NEWER_V" ] && ok "anti-downgrade: tetap $INSTV2" || bad "ter-downgrade ke $INSTV2 — BUG!"

# ══ FLOW 3: offline tetap jalan ══
p "▮ UPDATE 3/6: tanpa URL override — tidak merusak offline" 213
HOME="$FH" timeout 15 bash "$DIR/install.sh" --offline >/dev/null 2>&1 && ok "install --offline tetap jalan" || bad "install --offline rusak"
HOME="$FH" bash "$DIR/install.sh" --check >/dev/null 2>&1 && ok "--check sehat setelah update" || bad "--check tidak sehat"

# ══ FLOW 4: memori tersimpan saat update ══
p "▮ UPDATE 4/6: memori tersimpan saat update" 213
mkdir -p "$FH/.config/opencode/memory"
echo "# Lessons terakhir" > "$FH/.config/opencode/memory/lessons.md"
echo "2026-09-01: test lesson" >> "$FH/.config/opencode/memory/lessons.md"
NEWER_V2="$((MAJOR+2)).0.0"
mk_remote "$NEWER_V2"
DEV_BRAIN_UPDATE_URL="file://$T/remote.tgz" HOME="$FH" bash "$DIR/install.sh" --update >/dev/null 2>&1
INSTV3=$(tr -d '[:space:]' < "$FH/.config/opencode/VERSION" 2>/dev/null)
[ "$INSTV3" = "$NEWER_V2" ] && ok "update naik ke $INSTV3" || bad "update gagal: $INSTV3"
# Memori harusnya terbackup + terrestore
[ -f "$FH/.config/opencode/memory/lessons.md" ] && ok "memory/lessons.md tersimpan" || bad "memory/lessons.md hilang setelah update"
grep -q "test lesson" "$FH/.config/opencode/memory/lessons.md" && ok "isi memory terjaga" || bad "isi memory rusak"

# ══ FLOW 5: versi sama = no-op ══
p "▮ UPDATE 5/6: versi sama — no-op" 213
CURV=$(tr -d '[:space:]' < "$FH/.config/opencode/VERSION" 2>/dev/null)
mk_remote "$CURV"
DEV_BRAIN_UPDATE_URL="file://$T/remote.tgz" HOME="$FH" bash "$DIR/install.sh" --update >/dev/null 2>&1
INSTV4=$(tr -d '[:space:]' < "$FH/.config/opencode/VERSION" 2>/dev/null)
[ "$INSTV4" = "$CURV" ] && ok "versi sama = no-op, tetap $INSTV4" || bad "versi berubah tanpa sebab: $INSTV4"

# ══ FLOW 6: reinstall setelah update ══
p "▮ UPDATE 6/6: reinstall --offline setelah update" 213
HOME="$FH" bash "$DIR/install.sh" --offline >/dev/null 2>&1
[ $? -eq 0 ] && ok "reinstall --offline setelah update berhasil" || bad "reinstall setelah update gagal"
HOME="$FH" bash "$DIR/install.sh" --check >/dev/null 2>&1
[ $? -eq 0 ] && ok "--check sehat setelah reinstall" || bad "--check gagal setelah reinstall"

rm -rf "$T"
echo
if [ "$FAIL" -eq 0 ]; then p "UPDATE_RESULT: FLOW TERBUKTI ($PASS langkah)" 82; exit 0; fi
p "UPDATE_RESULT: GAGAL ($FAIL)" 196; exit 1
