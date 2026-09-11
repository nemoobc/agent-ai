---
description: ESTIMATE — pecah tugas jadi item kerja ber-skala S/M/L/XL dari angka file nyata (scan), plus rentang best/worst. Masuk plan & milestone — plan tanpa angka = tebakan.
---

# ESTIMATE (SKALA SEBELUM KERJA)

Plan tanpa angka = tebakan dengan format rapi. Ukur dulu.

## APA YANG DILAKUKAN
Membedah tugas menjadi item kerja dengan skala terukur (S/M/L/XL) berdasarkan data nyata dari scan. Estimate = fondasi realistis sebelum rencana dibuat.

## KAPAN WAJIB JALAN
1. **Tugas > 5 file** — perlu estimasi agar realistis
2. **Sebelum milestone** — milestone tanpa estimasi = mileston tanpa jarak tempuh
3. **User minta estimasi** — berikan angka, bukan perasaan
4. **Sebelum plan** — plan butuh data estimasi

## URUTAN

### 1. SCAN → METRICS
skill `scan` → file/folder yang disentuh; butuh detail → skill `metrics`

### 2. PECAH TUGAS → ITEM KERJA (maks 8)
Tiap item: file target + skala:
- **S** ≤2 file / 1 fase — bisa selesai < 30 menit
- **M** 3–6 file — beberapa jam, butuh koordinasi
- **L** 7–15 file / banyak edge — satu sesi penuh
- **XL** >15 file / sentuh data·schema·publish — perlu milestone

### 3. FAKTOR RISIKO
Risiko menaikkan skala:
- Auth/pembayaran → +1 tingkat
- Data user/migrasi → +1 tingkat
- Integrasi system → +1 tingkat

### 4. TOTAL + RENTANG
Total gabungan + rentang (best → worst, dalam sesi kerja)
→ masuk plan blok URUTAN + milestone (skill `milestone`)

## FORMAT
```
[ESTIMATE] <tugas>
 1. <item> — <S/M/L/XL> — <alasan 3 kata>
 TOTAL   : <skala gabungan> (<n> item, ±<x> file)
 RENTANG : best <a> sesi — worst <b> sesi
 RISIKO  : <0–3 faktor>
```

## GERBANG
- Item tanpa file target = tebakan → scan dulu, DILARANG menebak
- XL tanpa milestone = DILARANG mulai (HUKUM 2, skill `milestone`)
- Dasar "biasanya sih" = DILARANG — dasarnya file nyata + angka scan
- Estimasi bukan janji tempo — itu keputusan user; kamu kasih angka + dasarnya

## INTEGRASI PIPELINE
```
SCAN → METRICS → ESTIMATE ← posisi skill ini → PLAN → MILESTONE → BANGUN
```
- Sebelum: scan (peta project), metrics (ukuran project)
- Sesudah: plan (rencana 8 blok), milestone (pecahan tugas)
- Berkaitan: `skill metrics` (ukuran detail), `skill milestone` (pecahan XL)

## EDGE CASE
- Tugas ambigu → estimasi dengan asumsi eksplisit
- Tugas yang belum pernah dilakukan → estimasi lebih longgar (+50%)
- Tugas di area familiar → estimasi lebih ketat
- Dependensi external → tambah buffer untuk waiting time

## ERROR HANDLING
- Tidak ada file yang teridentifikasi → estimasi minimal S
- File yang terpengaruh lebih banyak dari perkiraan → update estimasi
- Estimasi meleset besar → catat di lessons.md untuk referensi masa depan

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Estimasi tanpa data → "biasanya 2 jam" tanpa dasar = tebakan
- ❌ Over-engineering estimasi → cukup 8 item, jangan 20
- ❌ Mengabaikan risiko → auth harus +1 tingkat, selalu
- ❌ Estimasi = janji → estimasi = data untuk keputusan user
- ❌ Tidak update estimasi → estimasi berubah, update juga

## MASTERY — ALL-ROUNDER MAX
Estimasi kelas atas:
- Skala dari angka nyata: hitung file/tugas/test yang disentuh — bukan feeling
- Buffer risiko: +30% lintas-sistem baru, +50% ada data migrasi — kompleksitas tidak linier
- Estimasi rentang (S: 1-2 jam) bukan angka tunggal — satu angka = janji palsu
- Meleset >2x = pelajaran wajib ke lessons.md — kalibrasi diri itu keterampilan
