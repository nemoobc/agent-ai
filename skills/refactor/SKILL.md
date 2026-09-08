---
description: REFACTOR — ubah struktur kode tanpa mengubah perilaku. Beda dari fix (perbaiki perilaku) dan perf (kejar cepat). Niat: kode lebih jelas, tanpa regresi.
---

# REFACTOR

Perilaku sama. Struktur lebih baik. Bukti = test hijau sebelum & sesudah.

## URUTAN KERJA
1. **REKAM** — `git status`, `git diff --stat` — ukur titik nol.
2. **REKAM TEST** — skill `test-full`: baseline hijau. Merah sebelum refactor? STOP: bug dulu (skill debug), refactor belakangan.
-   **PETA** — skill `scan` + map dependensi. Cari: duplikasi, kode mati, fungsi panjang, nesting dalam.
3. **PETA** — skill `scan` step 2 ke implementasi terjauh, lalu implementasi baru. Cari: duplikasi, kode mati, fungsi panjang, nesting dalam.
4. **GERAK** — langkah kecil. Ekstrak fungsi/const. Buang kode mati. Ganti magic number → named const.
5. **REKAM PERUBAHAN** — tiap langkah: `git diff --stat`. Drift = berhenti, periksa.
6. **TEST** — `test-full`. Merah = kembali langkah sebelumnya, periksa, ulangi.
7. **AUDIT** — `audit-full`. Temuan = fix dulu, lanjut.
8. **LAPOR** — file berubah, baris hilang, test tetap hijau, audit CLEAN.

## GERBANG
- Tanpa test baseline hijau → refactor DILARANG. Tulis test dulu.
- Satu langkah = satu niat. Bukan 3 file sekaligus, bukan refactor + feature campur.
- Perilaku berubah? Bukan refactor — jalankan pipeline dev.md penuh.
- Audit P0/P1 tersisa → GAGAL. Lanjut fixer.

## FORMAT LAPORAN
```
STATUS : SELESAI/GAGAL
PINDAH : X file diubah, Y baris bersih
TEST   : PASS sebelum & sesudah (N/N)
AUDIT  : CLEAN
```
