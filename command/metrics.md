---
description: METRICS — angka kesehatan project: ukuran, kompleksitas, test, utang, pipeline + putusan konkret.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill metrics — kumpulkan & baca angka.
2. Lapor format METRICS. Setiap angka harus memicu PUTUSAN konkret.
3. Ada utang menumpuk / hotspot jelas → tawarkan langsung: masukkan /backlog dengan definisi selesai?

## Usage

```
/metrics
```

- Tidak ada argument — kumpulkan semua metrik project.

## Triggers

- **skill metrics** — pengumpulan angka kesehatan
- **skill scan** — dasar pemetaan file
- **skill test-full** — angka test
- **skill audit-full** — angka temuan

## Example

```
/metrics
```

## Expected Output

```
METRICS — project health
├── SIZE: 847 file, 45,200 baris
├── COMPLEXITY: avg 12 baris/fungsi, max 89 baris (hotspot: src/parser.js)
├── TEST: 234 assertion, 89% pass rate (last run: 2026-09-10)
├── AUDIT: 2 temuan P2, 0 P0/P1
├── UTANG: 12 file tanpa test, 3 file > 200 baris
├── DEPENDENCY: 23 packages, 2 outdated, 0 vulnerable
└── PUTUSAN:
    ├── HOTSPOT: src/parser.js (89 baris) → /backlog "refactor parser"
    ├── UTANG: 12 file tanpa test → /coverage
    └── OUTDATED: 2 package → /upgrade
```

## Error Cases

- **Project kosong** → lapor "tidak ada yang diukur"
- **metrics/run.sh tidak ada** → fallback manual
- **Angka tidak valid** → lapor "data tidak lengkap"

## Related Commands

- `/coverage** — detail gap test
- `/audit** — detail temuan
- `/backlog** — utang masuk antrian
