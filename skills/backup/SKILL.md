---
description: BACKUP — snapshot data/folder sebelum operasi berisiko (migrate, hapus, rewrite): run.sh buat tarball bertanggal, keep N terbaru. Tanpa backup = operasi berisiko dilarang.
---

# BACKUP

Snapshot = tiket pulang. Operasi berisiko tanpa snapshot = berjudi dengan data orang.

## JALANKAN SEBELUM
- skill migrate (sebelum up-migration), refactor besar, hapus folder, rewrite data, update schema.
- User minta operasi yang bisa menghancurkan data.

## CARA
```bash
bash ~/.config/opencode/skill/backup/run.sh [dir] [label]
```
- Bikin `backups/<nama>-<label>-<timestamp>.tar.gz` (di dalam project, di gitignore-kan).
- Default keep: 5 backup terakhir, sisanya dihapus (bisa diubah argumen).
- Exit 0 = backup sukses (path dicetak), 1 = gagal.

## SETELAH BACKUP
- Catat path di laporan + di plan (blok RISIKO) — siap dipakai untuk rollback.
- Operasi jalan → verifikasi → bila gagal: restore dari backup, lapor ke user, baru ulang.

## GERBANG
- Operasi berisiko data TANPA backup yang sukses → DILARANG mulai (dua-duanya: skill migrate & backup).
- Backup tanpa verifikasi bisa dibuka (`tar -tzf`) = backup dianggap gagal.
- Path backup WAJIB dicatat di laporan akhir.