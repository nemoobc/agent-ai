---
description: CLEAN — bersih-bersih otomatis artefak build/cache/log dari project (allowlist ketat, aman, terukur). --dry untuk pratinjau tanpa hapus.
agent: dev
---
TUGAS: /clean [--dry]

1. `bash skills/clean/run.sh . --dry` dulu bila ragu → tampilkan target + ukuran, tanpa hapus.
2. Yakin → jalankan REAL (tanpa --dry) → lapor byte dibebaskan per target + total.
3. Lapor blok [CLEAN] gaya caveman.

GERBANG: node_modules/.git/.env/kode sumber TIDAK PERNAH disentuh — allowlist di script, bukan keputusan momen. Project tanpa git + hapus besar → minta konfirmasi (HUKUM 5).

## Usage

```
/clean [--dry]
```

- `--dry` — pratinjau file yang akan dihapus tanpa menghapus apa pun.

## Triggers

- **bash skills/clean/run.sh** — executor bersih-bersih dengan allowlist

## Example

```
/clean --dry
/clean
```

## Expected Output

```
CLEAN: PRATINJAU (--dry)
├── dist/              → 12.4 MB
├── .next/cache/       → 8.7 MB
├── *.log              → 0.3 MB
└── TOTAL: 21.4 MB akan dibebaskan

CLEAN: SELESAI — 21.4 MB dibebaskan
├── dist/              → 12.4 MB ✓
├── .next/cache/       → 8.7 MB ✓
├── *.log              → 0.3 MB ✓
└── AMAN: node_modules/.git/.env/src tidak disentuh
```

## Error Cases

- **node_modules/.git/.env terdeteksi sebagai target** → BATAL, allowlist dilanggar
- **Project tanpa git + hapus > 10MB** → minta konfirmasi (HUKUM 5)
- **clean/run.sh tidak ada** → fallback manual, lapor

## Related Commands

- `/verify` — clean masuk pipeline verify
- `/ship` — clean bisa jadi bagian pipeline
