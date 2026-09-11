---
description: HOTFIX — produksi rusak, cepat & minimal: hentikan pendarahan dulu, reproduksi, fix SEMPIT, bukti, postmortem setelah tenang. Tidak ada ruang untuk eksperimen di produksi.
---

# HOTFIX

Produksi rusak = prioritas satu. Tidak ada fitur baru. Tidak ada refactor. Satu-satunya tujuan: kembali hijau, cepat, tanpa efek samping baru.

## APA YANG DILAKUKAN
Memperbaiki masalah produksi dengan pendekatan sempit dan cepat: hentikan pendarahan, reproduksi, fix minimal, bukti, postmortem. Hotfix = operasi darurat: presisi, bukan keberanian.

## KAPAN WAJIB JALAN
1. **Produksi down** — service tidak bisa diakses
2. **Bug kritis** — mempengaruhi banyak user
3. **Data rusak** — kehilangan atau corrupt data
4. **Security breach** — akses tidak sah terdeteksi
5. **Performance crisis** — service sangat lambat

## URUTAN KERJA (dalam keadaan tenang, bukan panik)

### 1. STOP BLEEDING
Matikan/freeze fitur yang rusak (feature flag, rollback deploy cepat) bila memungkinkan. Data selamat dulu.

### 2. REPRO (skill debug)
Reproduksi deterministik (input → output salah). Tanpa repro, fix = tebak.

### 3. FIX SEMPIT
Perubahan MINIMAL ke akar masalah. Satu file bila bisa. Bukan refactor, bukan perbaikan sekalian.

### 4. BUKTI
Test yang GAGAL sebelum fix → HIJAU setelah fix (test permanen, bukan test sementara). test-full + audit-full.

### 5. GUARD (skill git-guard)
Git-guard sebelum commit hotfix (secret/marker/debug).

### 6. VERIFIKASI
/verify penuh (HUKUM 9). Hotfix yang merah = belum selesai.

### 7. POSTMORTEM (setelah tenang)
Skill postmortem → lessons.md (mengapa lolos, pencegahan permanen).

## ATURAN
- Hotfix DILARANG bawa perubahan lain. Satu niat. Sisanya = commit terpisah
- "Coba-coba di produksi" dilarang. Setiap langkah harus punya bukti
- Hotfix yang butuh > 30 menit tanpa progress → eskalasi: lapor status + bukti ke user, jangan diam
- Setelah hijau: postmortem WAJIB — hotfix tanpa pelajaran = kecelakaan yang akan terulang

## FORMAT LAPORAN
```
HOTFIX  : <gejala → akar → fix>
BUKTI   : test X MERAH sebelum → HIJAU setelah (N/N), audit CLEAN
FILE    : <file:baris yang berubah — minimal>
POSTMORTEM: lessons.md entry + aksi pencegahan
```

## INTEGRASI PIPELINE
```
INSIDEN → STOP BLEEDING → DEBUG → HOTFIX ← posisi skill ini
                                          ↓
                                    TEST-FULL → AUDIT-FULL
                                          ↓
                                    POSTMORTEM → LESSONS.MD
```
- Sebelum: insiden, stop bleeding
- Sesudah: test-full (verifikasi), audit-full (keamanan), postmortem (pelajaran)
- Berkaitan: `skill debug` (akar masalah), `skill postmortem` (pelajaran), `skill recovery` (pemulihan)

## EDGE CASE
- Hotfix tidak cukup → eskalasi ke recovery (restore dari backup)
- Hotfix menambah masalah lain → rollback + coba pendekatan lain
- Tidak ada test yang gagal → tambah test yang gagal dulu, baru fix
- Multiple hotfix berturut-turut → ada masalah fundamental, perlu postmortem mendalam

## ERROR HANDLING
- Fix tidak bisa ditemukan → eskalasi ke postmortem
- Test tetap merah setelah fix → rollback + coba pendekatan lain
- Hotfix loop > 3x → STOP, postmortem dulu

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Hotfix yang membawa perubahan lain → satu niat, satu fix
- ❌ Skip postmortem → bug akan terulang
- ❌ "Coba-coba" di produksi → setiap langkah harus berbasis bukti
- ❌ Hotfix tanpa test permanen → bug akan kembali
- ❌ Hotfix terlalu lama tanpa progress → eskalasi

## MASTERY — ALL-ROUNDER MAX
Hotfix kelas atas:
- Freeze fitur: hanya perbaikan yang jalan — fitur baru saat insiden = dua insiden
- Patch terkecil yang menghentikan pendarahan — perbaikan cantik menunggu, darah tidak
- Satu jalur: fix → test → deploy — tanpa jalan pintas "kali ini saja"
- Setelah selesai: postmortem 30 menit — hotfix tanpa pelajaran = insiden berikutnya menunggu jadwal
