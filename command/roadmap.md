---
description: ROADMAP — urutkan langkah berikutnya berdasar dampak × usaha. Bukan daftar keinginan — tiap item punya skor dan urutan eksekusi.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill recall + skill scan — konteks & kondisi project sekarang.
2. Kumpulkan kandidat: saran user, temuan audit/perf tersisa, gap fitur, utang teknis.
3. Skor tiap item: dampak (1–5) × usaha (1–5, dibalik). Urutkan skor tertinggi dulu.
4. Kelompokkan: NOW (langsung gas) / NEXT (setelah now) / LATER (catat).
5. Lapor gaya caveman: tabel pendek skor + urutan. Minta konfirmasi hanya untuk item berbiaya (HUKUM 5).
6. User setuju → jalankan item NOW lewat pipeline penuh.

## Usage

```
/roadmap
```

- Tidak ada argument — generate roadmap dari kondisi project.

## Triggers

- **skill recall** — memori + keputusan
- **skill scan** — pemetaan file project
- **/backlog** — sumber item kandidat

## Example

```
/roadmap
```

## Expected Output

```
ROADMAP — 2026-09-10
NOW (score ≥ 15):
├── #1 refactor auth module     — dampak:5 × usaha:3 = 15
├── #2 tambah test coverage     — dampak:4 × usaha:4 = 16
NEXT (score 10-14):
├── #3 upgrade dependencies     — dampak:3 × usaha:3 = 9
└── #4 tambah monitoring        — dampak:4 × usaha:2 = 8
LATER (score < 10):
└── #5 migrasi ke TypeScript    — dampak:5 × usaha:1 = 5

REKOMENDASI: mulai #2 (test coverage) — quick win
```

## Error Cases

- **Project tidak dikenali** → scan manual + lapor
- **Tidak ada kandidat** → minta user input
- **Semua item berbiaya** → eskalasi ke user (HUKUM 5)

## Related Commands

- `/backlog** — daftar item terperinci
- `/estimate** — estimasi ukuran setiap item
- `/plan** — rencana 8 blok untuk item NOW
