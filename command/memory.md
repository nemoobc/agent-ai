---
description: Tampilkan ingatan DEV-BRAIN (memori global + project)
agent: dev
---
Muat dan tampilkan ingatan: skill recall dulu, lalu rangkum ke user — keputusan penting, pembelajaran terakhir, log sesi terakhir. Gaya caveman: blok pendek.

## Usage

```
/memory [topik]
```

- `topik` — filter ingatan berdasar topik. Kosong = semua.

## Triggers

- **skill recall** — muat memori global + project
- **skill remember** — opsional, tambah ingatan baru
- **memory/lessons.md** — pelajaran terbukti
- **memory/decisions.md** — keputusan penting

## Example

```
/memory
/memory auth
/memory "decision: pakai bcrypt"
```

## Expected Output

```
MEMORY — DEV-BRAIN
KEPUTUSAN:
├── pakai bcrypt (2026-03-15) — alasan: compat
├── jangan pakai npm audit tanpa lockfile (2026-09-10) — alasan: false positive
└── hotfix freeze scope (2026-08-01) — alasan: prevent scope creep
PELAJARAN (5 terbaru):
├── npm audit false-positive → jangan pakai tanpa lockfile
├── race condition → pakai mutex di concurrent update
└── ...
LOG SESI (3 terbaru):
├── 2026-09-10: auth module — SELESAI (24 test, audit CLEAN)
├── 2026-09-09: payment integration — SELESAI (12 test, audit CLEAN)
└── ...
```

## Error Cases

- **Memori tidak ada** → lapor "memori bersih, mulai dari /scan"
- **Memori corrupt** → backup + buat baru
- **Topik tidak ditemukan** → tampilkan semua, saran topik yang tersedia

## Related Commands

- `/learn** — tambah pelajaran baru
- `/handoff** — kemas konteks + ingatan
- `/recall** — muat memori secara eksplisit
