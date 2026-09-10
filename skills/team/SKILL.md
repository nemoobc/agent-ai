---
description: TEAM — kerja paralel: pecah kerja jadi unit tak-bergantung, antrean sub-agent, verifikasi ulang, merge hasil. Satu niat per unit. Verifikasi = wajib.
---

# TEAM

Satu antrian itu lambat. Kerja yang tak saling bergantung bisa jalan berdampingan — asal hasilnya diverifikasi ulang.

## APA YANG DILAKUKAN
Mengelola kerja paralel: memecah tugas menjadi unit independen, menugaskan ke sub-agent, memverifikasi ulang hasil gabungan. Team = parallel processing dengan quality gate.

## KAPAN WAJIB JALAN
1. **Plan punya ≥ 3 unit kerja yang TIDAK saling menunggu** — paralel lebih efisien
2. **Tugas besar dengan area berbeda** — bisa dikerjakan bersamaan
3. **User minta kecepatan** — paralel = lebih cepat

## URUTAN KERJA

### 1. PECAH
Unit per area/file. Syarat: tak ada 2 unit menyentuh file yang sama.
- Unit = area fungsional yang independen
- Satu unit = satu niat = satu laporan

### 2. ANTREAN
Lempar tiap unit ke sub-agent serentak (architect/coder).
- Satu unit per agent
- Agent tidak boleh overlap file

### 3. VERIFIKASI ULANG
Hasil paralel = dugaan sampai diverifikasi:
- skill `test-full` menyatukan semuanya
- skill `audit-full` mengecek keseluruhan

### 4. MERGE
Bentrok (2 unit ubah file sama) → pilih satu arah, unit yang kalah diredo serial.

### 5. LAPOR
Papan: unit → status → bukti.

## FORMAT PAPAN
```
U1 [SELESAI] module auth — test 4/4
U2 [SELESAI] module utils — test 3/3
U3 [JALAN  ] module UI
MERGE : test penuh 12/12, audit CLEAN
```

## GERBANG
- 2 unit menyentuh file sama = salah pecah → pecah ulang, jangan didorong paksa
- Hasil paralel tanpa verifikasi ulang penuh = DILARANG dilapor SELESAI
- Unit gagal → jangan tunda: fixer sekarang, paralel berhenti sampai aman

## INTEGRASI PIPELINE
```
PLAN → TEAM ← posisi skill ini → PARALEL (sub-agent)
                                       ↓
                              VERIFIKASI (test+audit gabungan)
                              MERGE (gabung hasil)
```
- Sebelum: plan (pecahan unit), estimate (skala per unit)
- Sesudah: verifikasi gabungan (test+audit)
- Berkaitan: `skill milestone` (serial), `skill test-full` (verifikasi), `skill audit-full` (verifikasi)

## EDGE CASE
- Unit tidak benar-benar independen → pecah ulang
- Satu unit gagal → yang lain bisa lanjut? Bila ya, fixer setelah semua selesai
- Terlalu banyak unit → batasi 5-6, lebih dari itu = overhead koordinasi
- Sub-agent tidak tersedia → serial, jangan dipaksa paralel

## ERROR HANDLING
- Unit gagal → fixer sekarang, paralel berhenti sampai aman
- Merge conflict → resolve manual, test ulang
- Verifikasi gabungan gagal → identifikasi unit yang bermasalah

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Paralel tapi overlap file → conflict terjamin
- ❌ Skip verifikasi gabungan → "sudah test masing-masing" ≠ gabungan aman
- ❌ Unit terlalu kecil → overhead koordinasi > manfaat
- ❌ Unit terlalu besar → kembali ke serial
- ❌ Tidak ada papan status → tidak tahu progress
