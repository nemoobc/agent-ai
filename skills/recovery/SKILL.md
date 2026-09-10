---
description: RECOVERY — pemulihan setelah bencana (data rusak/hilang, migrasi gagal, deploy rusak): restore dari backup, verifikasi, minimal green, postmortem. Backup = tiket pulang.
---

# RECOVERY

Bencana bukan "kalau", tapi "kapan". Recovery = jalan pulang yang sudah disiapkan sebelumnya.

## APA YANG DILAKUKAN
Memulihkan sistem/data setelah kegagalan besar: restore dari backup, verifikasi, minimal hijau, postmortem. Recovery = bedah darurat: stabilkan dulu, baru sempurnakan.

## KAPAN WAJIB JALAN
1. **Data rusak/hilang** — operasi merusak data
2. **Migrasi gagal** — migrasi tidak selesai sempurna
3. **Deploy rusak** — deploy menghasilkan service down
4. **Hotfix tidak cukup** — masalah terlalu besar untuk hotfix
5. **Produksi down total** — semua service tidak bisa diakses

## URUTAN KERJA

### 1. BERHENTI
Stop semua operasi tulis. Tidak ada yang boleh nulis lagi sebelum pemulihan selesai.

### 2. INVENTORY
Apa yang rusak, kapan rusak (garis waktu), apa yang masih utuh, backup apa yang ada (skill backup).

### 3. RESTORE
Dari backup TERDEKAT sebelum kerusakan. Restore ke lokasi/salinan dulu bila ragu (dry-run).

### 4. VERIFIKASI
Setelah restore: hitung baris/record, spot-check, test-full + audit-full. Jangan lanjut sebelum terbukti.

### 5. MINIMAL GREEN
Layanan minimal jalan dulu. Fitur bertahap setelah aman.

### 6. POSTMORTEM
Skill postmortem → lessons.md: akar, mengapa backup/guard gagal menangkap, pencegahan permanen.

## GERBANG
- Operasi tulis lanjut sebelum inventory = DILARANG
- Restore tanpa verifikasi terukur = belum pulih
- Backup tidak ada → JANGAN pura-pura: lapor ke user dengan opsi (HUKUM 7 TITIK-PUTUS), jangan menciptakan data dari ingatan
- Recovery tanpa postmortem = akan terulang. WAJIB

## FORMAT LAPORAN
```
RECOVERY: <kerusakan → sumber restore → hasil verifikasi>
BUKTI   : record/baris cocok (X/X), test N/N, audit CLEAN
POSTMORTEM: <1 baris akar + aksi pencegahan>
```

## INTEGRASI PIPELINE
```
BENCANA → RECOVERY ← posisi skill ini → VERIFIKASI → POSTMORTEM
                         ↓
                    RESTORE (dari backup)
                    TEST-FULL (verifikasi)
                    AUDIT-FULL (keamanan)
```
- Sebelum: bencana terjadi, backup tersedia
- Sesudah: verifikasi, postmortem (pelajaran)
- Berkaitan: `skill backup` (restore source), `skill hotfix` (fix cepat), `skill postmortem` (pelajaran)

## EDGE CASE
- Backup corrupt → cari backup yang lebih tua
- Tidak ada backup → lapor ke user dengan opsi (HUKUM 7)
- Restore sebagian → restore yang bisa, catat yang tidak
- Multiple failure → prioritas: data dulu, service kemudian

## ERROR HANDLING
- Restore gagal → coba backup yang lebih tua
- Verifikasi gagal → coba restore lagi atau cari sumber lain
- Postmortem tidak bisa dilakukan → tunda, tapi WAJIB dilakukan nanti

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip recovery → masalah makin parah
- ❌ Restore tanpa verifikasi → tidak tahu apakah berhasil
- ❌ Mengarang data dari ingatan → data palsu = bencana
- ❌ Skip postmortem → akan terulang
- ❌ Lanjut operasi tulis sebelum stabil → makin rusak
