---
description: REFACTOR — ubah struktur kode tanpa mengubah perilaku. Beda dari fix (perbaiki perilaku) dan perf (kejar cepat). Niat: kode lebih jelas, tanpa regresi.
---

# REFACTOR

Perilaku sama. Struktur lebih baik. Bukti = test hijau sebelum & sesudah.

## APA YANG DILAKUKAN
Mengubah struktur kode tanpa mengubah perilaku yang terlihat oleh user. Refactor = menata ulang rumah: isi sama, tapi lebih rapi dan mudah dirawat.

## KAPAN WAJIB JALAN
1. **Kode sulit dibaca** — terlalu panjang, terlalu nested
2. **Duplikasi kode** — fungsi sama di beberapa tempat
3. **Kode mati** — tidak dipakai tapi masih ada
4. **Magic number** — angka tanpa nama
5. **User/kode minta refactor** — "perjelas kode ini"

## URUTAN KERJA

### 1. REKAM
`git status`, `git diff --stat` — ukur titik nol.

### 2. REKAM TEST (skill test-full)
Baseline hijau. Merah sebelum refactor? STOP: bug dulu (skill debug), refactor belakangan.

### 3. PETA
Skill `scan` + map dependensi. Cari: duplikasi, kode mati, fungsi panjang, nesting dalam.

### 4. GERAK
Langkah kecil. Ekstrak fungsi/const. Buang kode mati. Ganti magic number → named const.

### 5. REKAM PERUBAHAN
Tiap langkah: `git diff --stat`. Drift = berhenti, periksa.

### 6. TEST (skill test-full)
Merah = kembali langkah sebelumnya, periksa, ulangi.

### 7. AUDIT (skill audit-full)
Temuan = fix dulu, lanjut.

### 8. LAPOR
File berubah, baris hilang, test tetap hijau, audit CLEAN.

## GERBANG
- Tanpa test baseline hijau → refactor DILARANG. Tulis test dulu
- Satu langkah = satu niat. Bukan 3 file sekaligus, bukan refactor + feature campur
- Perilaku berubah? Bukan refactor — jalankan pipeline dev.md penuh
- Audit P0/P1 tersisa → GAGAL. Lanjut fixer

## FORMAT LAPORAN
```
STATUS : SELESAI/GAGAL
PINDAH : X file diubah, Y baris bersih
TEST   : PASS sebelum & sesudah (N/N)
AUDIT  : CLEAN
```

## INTEGRASI PIPELINE
```
TEST-FULL (baseline) → REFACTOR ← posisi skill ini → TEST-FULL (verifikasi)
                                                         ↓
                                                    AUDIT-FULL
```
- Sebelum: test-full (baseline hijau), scan (peta kode)
- Sesudah: test-full (verifikasi tidak berubah), audit-full
- Berkaitan: `skill debug` (fix bug dulu bila ada), `skill metrics` (ukur dampak)

## EDGE CASE
- Refactor besar → pecah ke beberapa langkah kecil
- Refactor yang mempengaruhi API → harus sinkron dengan doc
- Refactor yang mempengaruhi test → update test, jangan skip test
- Tidak ada test → tulis test dulu, baru refactor

## ERROR HANDLING
- Refactor merusak test → rollback + coba pendekatan lain
- Refactor loop > 5 langkah → STOP, postmortem
- Tidak yakin perilaku sama → verifikasi dengan test

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Refactor tanpa test → bisa merusak tanpa disadari
- ❌ Refactor + fitur campur → satu niat, satu commit
- ❌ Refactor besar sekaligus → pecah ke langkah kecil
- ❌ Skip audit → refactor bisa menambah masalah baru
- ❌ Refactor yang mengubah perilaku → itu bukan refactor
