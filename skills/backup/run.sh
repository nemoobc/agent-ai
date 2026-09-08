#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  BACKUP-RUN — snapshot folder ke backups/<label>-<ts>.tar.gz.
#  Jalankan: bash skill/backup/run.sh [dir] [label] [keep]
#  Exit 0 = sukses (path dicetak), 1 = gagal.
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; LABEL="${2:-backup}"; KEEP="${3:-5}"
cd "$ROOT" 2>/dev/null || { echo "folder tidak ditemukan: $ROOT"; exit 1; }
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
TS=$(date +%Y%m%d-%H%M%S)
mkdir -p backups
OUT="backups/${LABEL}-${TS}.tar.gz"
# tar: ikuti symlink tidak perlu; exclude .git & backups itu sendiri
tar -czf "$OUT" --exclude='./.git' --exclude='./backups' --exclude='./node_modules' . 2>/dev/null
if [ $? -eq 0 ] && [ -s "$OUT" ]; then
  p "  ✔ backup: $OUT ($(du -h "$OUT" | cut -f1))" 82
  # verifikasi bisa dibuka
  tar -tzf "$OUT" >/dev/null 2>&1 && p "  ✔ terverifikasi (bisa dibaca)" 82 || { p "  ✖ backup korup — buang" 196; rm -f "$OUT"; exit 1; }
else
  p "  ✖ backup gagal — operasi berisiko DILARANG lanjut" 196
  rm -f "$OUT"; exit 1
fi
# prune: keep N terbaru per label
CNT=0
for f in $(ls -1t backups/${LABEL}-*.tar.gz 2>/dev/null); do
  CNT=$((CNT+1))
  [ "$CNT" -gt "$KEEP" ] && { p "  · prune lama: $f" 214; rm -f "$f"; }
done
echo
p "BACKUP_RESULT: $OUT" 82
exit 0