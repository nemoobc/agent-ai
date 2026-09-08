---
description: HOTFIX — produksi rusak, cepat & minimal: hentikan pendarahan dulu, reproduksi, fix SEMPIT, bukti, postmortem setelah tenang. Tidak ada ruang untuk eksperimen di produksi.
---

# HOTFIX

Produksi rusak = prioritas satu. Tidak ada fitur baru. Tidak ada refactor. Satu-satunya tujuan: kembali hijau, cepat, tanpa efek samping baru.

## URUTAN KERJA (dalam keadaan tenang, bukan panik)
1. **STOP BLEEDING** — matikan/freeze fitur yang rusak (feature flag, rollback deploy cepat) bila memungkinkan. Data selamat dulu.
2. **REPRO** — skill `debug`: reproduksi deterministik (input → output salah). Tanpa repro, fix = tebak.
3. **FIX SEMPIT** — perubahan MINIMAL ke akar masalah. Satu file bila bisa. Bukan refactor, bukan perbaikan sekalian.
4. **BUKTI** — test yang GAGAL sebelum fix → HIJAU setelah fix (test permanen, bukan test sementara). test-full + audit-full.
5. **GUARD** — git-guard sebelum commit hotfix (secret/marker/debug).
6. **VERIFIKASI** — /verify penuh (HUKUM 9). Hotfix yang merah = belum selesai.
7. **POSTMORTEM** — setelah tenang: skill postmortem → lessons.md (mengapa lolos, pencegahan permanen).

## ATURAN
- Hotfix DILARANG bawa perubahan lain. Satu niat. Sisanya = commit terpisah.
- "Coba-coba di produksi" dilarang. Setiap langkah harus punya bukti.
- Hotfix yang butuh > 30 menit tanpa progress → eskalasi: lapor status + bukti ke user, jangan diam.
- Setelah hijau: postmortem WAJIB — hotfix tanpa pelajaran = kecelakaan yang akan terulang.

## FORMAT LAPORAN
```
HOTFIX  : <gejala → akar → fix>
BUKTI   : test X MERAH sebelum → HIJAU setelah (N/N), audit CLEAN
FILE    : <file:baris yang berubah — minimal>
POSTMORTEM: lessons.md entry + aksi pencegahan
```