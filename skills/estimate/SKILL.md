---
description: ESTIMATE — pecah tugas jadi item kerja ber-skala S/M/L/XL dari angka file nyata (scan), plus rentang best/worst. Masuk plan & milestone — plan tanpa angka = tebakan.
---
# ESTIMATE (SKALA SEBELUM KERJA)

Plan tanpa angka = tebakan dengan format rapi. Ukur dulu.

## URUTAN
1. skill `scan` → file/folder yang disentuh; butuh detail → skill `metrics`.
2. Pecah tugas → item kerja (maks 8). Tiap item: file target + skala:
   - **S** ≤2 file / 1 fase · **M** 3–6 file · **L** 7–15 file / banyak edge · **XL** >15 file / sentuh data·schema·publish
3. Faktor risiko menaikkan skala: auth/pembayaran/data user/migrasi = +1 tingkat.
4. Total + rentang (best → worst, dalam sesi kerja) → masuk plan blok URUTAN + milestone (skill `milestone`).

## FORMAT
```
[ESTIMATE] <tugas>
 1. <item> — <S/M/L/XL> — <alasan 3 kata>
 TOTAL   : <skala gabungan> (<n> item, ±<x> file)
 RENTANG : best <a> sesi — worst <b> sesi
 RISIKO  : <0–3 faktor>
```

## GERBANG
- Item tanpa file target = tebakan → scan dulu, DILARANG menebak.
- XL tanpa milestone = DILARANG mulai (HUKUM 2, skill `milestone`).
- Dasar "biasanya sih" = DILARANG — dasarnya file nyata + angka scan.
- Estimasi bukan janji tempo — itu keputusan user; kamu kasih angka + dasarnya.
