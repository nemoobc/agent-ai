---
description: ESTIMATE — pecah tugas jadi item kerja S/M/L/XL dengan angka nyata dari scan. Hasil masuk plan & milestone, bukan dokumen terpisah.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill scan — basis file nyata (jangan ingat-ingat).
2. skill estimate — pecah item, skala S/M/L/XL, total, rentang best/worst, risiko.
3. Masukkan hasil ke skill plan (blok URUTAN) + skill milestone bila XL.
4. Lapor blok [ESTIMATE] singkat.

GERBANG: estimate tanpa angka file nyata = ditolak; XL tanpa milestone = kerja DILARANG mulai.

## Usage

```
/estimate [deskripsi tugas]
```

- `deskripsi tugas` — apa yang harus di-estimate

## Triggers

- **skill scan** — pemetaan file nyata
- **skill estimate** — perhitungan skala + risiko
- **skill plan** — masukkan ke rencana 8 blok
- **skill milestone** — untuk item XL

## Example

```
/estimate migrasi database dari MongoDB ke PostgreSQL
/estimate tambah autentikasi OAuth2
```

## Expected Output

```
ESTIMATE: "migrasi MongoDB → PostgreSQL"
├── SCAN: 12 file, 3,400 baris terpengaruh
├── S (3): config migration (1-2 hari)
├── M (4): schema migration script (3-5 hari)
├── L (2): data migration pipeline (1-2 minggu)
├── XL (1): testing + cutover (2-3 minggu)
├── TOTAL: 3-6 minggu
├── RISIKO: data loss saat migrasi (high)
└── REKOMENDASI: milestone untuk XL, plan 8 blok sekarang
```

## Error Cases

- **Tidak ada deskripsi tugas** → minta user isi
- **File tidak terdeteksi** → lapor "scan tidak menemukan file terkait"
- **XL tanpa milestone** → blokir mulai

## Related Commands

- `/plan` — susun rencana 8 blok dari estimate
- `/backlog** — estimate masuk backlog
- `/milestone** — pecah XL jadi milestone
