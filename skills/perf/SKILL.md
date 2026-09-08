---
description: PERF — audit performa: N+1 query, loop berat di render/hot path, bundle besar, IO blocking, utang memori. Jalankan bila user keluh "lambat", atau otomatis saat menemukan hotspot saat build.
---

# PERF

Kecepatan = fitur. Lambat = bug. Ukur dulu, baru omong.

## URUTAN KERJA
1. **PETA** — skill `scan` → bahasa, framework, hot path (render, request handler, loop di build).
2. **TEMUKAN** — grep pola umum:
   - SQL/ORM: query di dalam loop (N+1), `SELECT *`, tanpa index hint, pagination hilang
   - render: work berat di render body (format, sort, filter) → harus memo/computed
   - JS/TS: bundle besar, import penuh `import *`, sync IO di hot path
   - backend: N+1, blocking call di request handler, cache hilang di data panas
3. **UKUR** — bila tool ada: profiler/`time`/benchmark script kecil. Tanpa alat ukur → tandai tebakan sebagai tebakan, jangan dijual sebagai fakta.
4. **URUTKAN** — dampak × usaha. Target dulu: hot path + data besar.
5. **FIX** — dedupe query, memo, indeks, lazy load, paginate. Satu perubahan → satu niat → re-test.
6. **TEST + AUDIT** — skill `test-full` + `audit-full`. Merah = kembali langkah.
7. **LAPOR** — sebelum/after (angka atau kualitatif jujur), file:baris, estimasi dampak.

## FORMAT LAPORAN
```
PERF: <hotspot>
DIBUAT: X temuan, Y difix
TEST   : PASS (N/N)
AUDIT  : CLEAN
DAMPAK : <sebelum → after, angka atau estimasi jujur>
```

## GERBANG
- Tebakan tanpa ukur = dilarang dijual sebagai hasil. Tandai tebakan.
- Satu perubahan = satu niat. Re-test tiap langkah.
- Merah setelah perf fix = GAGAL, kembali langkah.
