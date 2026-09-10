---
description: BACKUP — snapshot data/folder sebelum operasi berisiko (migrate, hapus, rewrite): run.sh buat tarball bertanggal, keep N terbaru. Tanpa backup = operasi berisiko dilarang.
---

# BACKUP

Snapshot = tiket pulang. Operasi berisiko tanpa snapshot = berjudi dengan data orang.

## APA YANG DILAKUKAN
Membuat salinan keamanan (snapshot) dari data/project sebelum operasi berisiko dijalankan. Backup = asuransi: berharap tidak perlu, tapi bersyukur bila ada.

## KAPAN WAJIB JALAN
1. **Sebelum migrasi** — up-migration, schema change, data transform
2. **Sebelum refactor besar** — perubahan struktur yang bisa merusak
3. **Sebelum hapus folder/file penting** — termasuk git reset --hard
4. **Sebelum rewrite data** — konfigurasi, database, file besar
5. **User minta operasi yang bisa menghancurkan data**

## JALANKAN
```bash
bash ~/.config/opencode/skill/backup/run.sh [dir] [label]
```
- Bikin `backups/<nama>-<label>-<timestamp>.tar.gz` (di dalam project, di gitignore-kan)
- Default keep: 5 backup terakhir, sisanya dihapus (bisa diubah argumen)
- Exit 0 = backup sukses (path dicetak), 1 = gagal

## URUTAN KERJA
1. **IDENTIFIKASI** — data apa yang akan terpengaruh? (file, folder, database)
2. **BACKUP** — jalankan script, pastikan exit 0
3. **VERIFIKASI** — `tar -tzf backup.tar.gz` pastikan bisa dibuka
4. **CATAT** — path backup di laporan + di plan (blok RISIKO)
5. **EKSEKUSI** — jalankan operasi berisiko
6. **VERIFY POST** — setelah operasi, verifikasi hasil
7. **ROLLBACK BILA PERLU** — bila gagal: restore dari backup, lapor ke user

## SETELAH BACKUP
- Catat path di laporan + di plan (blok RISIKO) — siap dipakai untuk rollback
- Operasi jalan → verifikasi → bila gagal: restore dari backup, lapor ke user, baru ulang
- Path backup WAJIB dicatat di laporan akhir

## GERBANG
- Operasi berisiko data TANPA backup yang sukses → DILARANG mulai (dua-duanya: skill migrate & backup)
- Backup tanpa verifikasi bisa dibuka (`tar -tzf`) = backup dianggap gagal
- Path backup WAJIB dicatat di laporan akhir

## INTEGRASI PIPELINE
```
BACKUP ← posisi skill ini → MIGRATE / REFACTOR / DELETE
   ↓
ROLLBACK (bila operasi gagal)
```
- Sebelum: identifikasi risiko
- Sesudah: operasi berisiko, verifikasi
- Berkaitan: `skill recovery` (pulihkan dari backup), `skill migrate` (operasi berisiko)

## EDGE CASE
- Project terlalu besar untuk full backup → backup subset yang terpengaruh
- Database → dump, bukan file copy
- Backup gagal karena disk penuh → cleanup dulu, baru backup
- Tidak ada git → backup extra penting karena tidak ada undo

## ERROR HANDLING
- Backup gagal → jangan mulai operasi. Fix backup dulu
- Disk space tidak cukup → kompres atau backup subset
- Permission denied → jalankan dengan hak akses yang benar
- Corrupt backup → buat ulang, verifikasi dengan checksum

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip backup → "biasanya aman" = judi dengan data
- ❌ Backup tanpa verifikasi → backup corrupt = backup palsu
- ❌ Tidak catat path backup → backup ada tapi tidak tahu di mana
- ❌ Backup lama tidak dirotasi → disk penuh, backup baru gagal
- ❌ Menganggap git = backup → git bisa di-reset, backup fisik lebih aman
