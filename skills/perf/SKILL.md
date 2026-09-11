---
description: PERF — audit performa: N+1 query, loop berat di render/hot path, bundle besar, IO blocking, utang memori. Jalankan bila user keluh "lambat", atau otomatis saat menemukan hotspot saat build.
---

# PERF

Kecepatan = fitur. Lambat = bug. Ukur dulu, baru omong.

## APA YANG DILAKUKAN
Mengidentifikasi dan memperbaiki bottleneck performa: query lambat, render berat, bundle besar, blocking IO. Perf = optimization berbasis data, bukan tebakan.

## KAPAN WAJIB JALAN
1. **User keluh "lambat"** — ada masalah performa
2. **Response time naik** — monitoring menunjukkan peningkatan
3. **Bundle size naik** — build output membesar
4. **Memory usage naik** — utang memori
5. **Sebelum release** — pastikan performa memadai

## URUTAN KERJA

### 1. PETA (skill scan)
Bahasa, framework, hot path (render, request handler, loop di build).

### 2. TEMUKAN
Grep pola umum:
- **SQL/ORM**: query di dalam loop (N+1), `SELECT *`, tanpa index hint, pagination hilang
- **Render**: work berat di render body (format, sort, filter) → harus memo/computed
- **JS/TS**: bundle besar, import penuh `import *`, sync IO di hot path
- **Backend**: N+1, blocking call di request handler, cache hilang di data panas

### 3. UKUR
Bila tool ada: profiler/`time`/benchmark script kecil.
Tanpa alat ukur → tandai tebakan sebagai tebakan, jangan dijual sebagai fakta.

### 4. URUTKAN
Dampak × usaha. Target dulu: hot path + data besar.

### 5. FIX
Dedupe query, memo, indeks, lazy load, paginate. Satu perubahan → satu niat → re-test.

### 6. TEST + AUDIT
skill `test-full` + `audit-full`. Merah = kembali langkah.

## FORMAT LAPORAN
```
PERF: <hotspot>
DIBUAT: X temuan, Y difix
TEST   : PASS (N/N)
AUDIT  : CLEAN
DAMPAK : <sebelum → after, angka atau estimasi jujur>
```

## GERBANG
- Tebakan tanpa ukur = dilarang dijual sebagai hasil. Tandai tebakan
- Satu perubahan = satu niat. Re-test tiap langkah
- Merah setelah perf fix = GAGAL, kembali langkah

## INTEGRASI PIPELINE
```
PERF ← posisi skill ini → TEST-FULL (verifikasi)
                              ↓
                         AUDIT-FULL (keamanan)
                         METRICS (ukur dampak)
```
- Sebelum: scan (identifikasi hotspot), user report
- Sesudah: test-full (verifikasi tidak merusak), audit-full (keamanan)
- Berkaitan: `skill metrics` (ukuran project), `skill test-full` (verifikasi)

## EDGE CASE
- Tidak ada profiler → manual benchmark dengan timer
- Perf improvement tidak bisa diukur → catat sebagai estimasi
- Trade-off: performa vs readability → dokumentasi pilihan
- Third-party bottleneck → workaround atau ganti library

## ERROR HANDLING
- Profiler tidak ada → fallback ke manual measurement
- Benchmark tidak konsisten → run 3x, ambil median
- Fix performance merusak fitur → rollback, coba pendekatan lain

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Tebakan tanpa ukuran → "kayaknya lambat di sini" bukan data
- ❌ Over-optimization → optimalkan yang paling berdampak dulu
- ❌ Skip test setelah perf fix → perf fix bisa merusak
- ❌ Tanpa baseline → tidak tahu apakah membaik
- ❌ Optimasi premature → pastikan ada masalah dulu

## MASTERY — ALL-ROUNDER MAX
Perf kelas atas:
- Ukur DULU (profil/flamegraph), optimasi KEMUDIAN — intuisi performa itu pembohong yang fasih
- Optimasi hot path 20% yang makan 80% waktu — sisanya jangan disentuh sebelum bukti
- Target angka (P95 < 200ms) bukan "terasa lebih cepat" — perasaan tak bisa diregresi-test
- Trade-off jujur: memori vs CPU vs latensi vs kompleksitas — optimasi gratis biasanya pinjam dari tempat lain
