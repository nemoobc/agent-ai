---
description: data — analisis, statistik, visualisasi data CSV/JSON/Excel via DEV
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan skill data: baca, bersihkan, analisis, visualisasi data mentah jadi insight.

## Usage

```
/data [path/file] [opsi analisis]
```

- `path/file` — path ke file CSV, JSON, atau Excel
- `opsi analisis` — summary, plot, filter, aggregate, transform

## Triggers

- **skill data** — pipeline analisis data
- **skill clean** — bersihkan data sebelum analisis

## Example

```
/data data/users.csv summary
/data data/logs.json filter "status=500"
/data data/sales.xlsx aggregate "region,total"
```

## Expected Output

```
DATA: data/users.csv (1,247 baris, 8 kolom)
├── SUMMARY: avg age=34.2, active=89%, churned=11%
├── TOP-KOL: email (123 duplikat), phone (45 missing)
├── FILTER: status=500 → 23 baris (1.8%)
└── INSIGHT: churn tertinggi di region "east" (18%)
```

## Error Cases

- **File tidak ada** → lapor path salah
- **Format tidak didukung** → lapor format yang didukung
- **File terlalu besar (>100MB)** → saran sampling

## Related Commands

- `/clean` — bersihkan data sebelum analisis
- `/metrics` — angka kesehatan project (bukan data)
