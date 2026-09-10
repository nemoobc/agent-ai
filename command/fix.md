---
description: Auto repair — test, temukan gagal, perbaiki, ulang sampai hijau
agent: dev
---
TUGAS: $ARGUMENTS

Mode perbaikan penuh:
1. skill test-full → kumpulkan semua kegagalan
2. skill audit-full → kumpulkan semua temuan
3. task fixer → benahi semuanya, loop sampai HIJAU (maks 5 putaran)
4. lapor: apa yang diperbaiki + status akhir test

## Usage

```
/fix
```

- Tidak ada argument — perbaiki semua yang gagal.

## Triggers

- **skill test-full** — kumpulkan kegagalan test
- **skill audit-full** — kumpulkan temuan audit
- **task fixer** — perbaiki kode secara otomatis
- **Loop** — maks 5 putaran sampai hijau

## Example

```
/fix
```

## Expected Output

```
FIX: 3 putaran
├── PUTARAN 1: 3 test gagal → fixer benahi → 1 test gagal
├── PUTARAN 2: 1 test gagal → fixer benahi → 0 test gagal
├── PUTARAN 3: audit 1 temuan → fixer benahi → CLEAN
├── TEST: PASS (42/42)
├── AUDIT: CLEAN
└── YANG DIPERBAIKI:
    ├── src/auth.js:32 — null check tambahan
    ├── src/api.js:18 — error handler
    └── utils/parse.js:45 — encoding fix
```

## Error Cases

- **5 putaran tidak cukup** → lapor status + rekomendasi manual
- **Fixer tidak tersedia** → lapor temuan + saran fix manual
- **Bug di luar scope** → lapor "out of scope, minta user arahkan"

## Related Commands

- `/build` — bangun fitur baru (fix = perbaikan)
- `/hotfix** — fix darurat produksi
- `/audit** — cari masalah sebelum fix
