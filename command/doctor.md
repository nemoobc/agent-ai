---
description: Diagnosa DEV-BRAIN — kesehatan instalasi, dependensi, typecheck, memori. Tanpa menulis apa pun.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill doctor → laporan kesehatan lengkap (lingkungan, dependensi, project, memori)
2. Ada masalah → task fixer langsung → skill doctor ulang sampai SEHAT
3. Lapor gaya caveman: angka + status, bukan cerita

## Usage

```
/doctor
```

- Tidak ada argument — diagnosa penuh.

## Triggers

- **skill doctor** — pemeriksaan kesehatan komprehensif
- **task fixer** — perbaiki masalah yang ditemukan

## Example

```
/doctor
```

## Expected Output

```
DOCTOR: SEHAT
├── LINGKUNGAN: bash 5.x, node 20.x, git 2.43 ✓
├── DEPENDENSI: semua terpasang ✓
├── PROJECT: AGENTS.md ✓, VERSION ✓, CHANGELOG ✓
├── MEMORI: lessons.md (12 entry), decisions.md (3) ✓
├── SKILLS: 56/56 ada + syntax OK ✓
└── COMMANDS: 39/39 ada + frontmatter valid ✓
STATUS: ALL GREEN
```

## Error Cases

- **Doctor merah** → fixer dipanggil → ulang sampai sehat
- **Dev-kit tidak terpasang** → lapor "jalankan /bootstrap dulu"
- **Memory corrupt** → backup + buat baru

## Related Commands

- `/bootstrap` — pasang DEV-BRAIN dari awal
- `/upgrade` — update DEV-BRAIN
- `/verify` — verifikasi penuh (lebih luas dari doctor)

