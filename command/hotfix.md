---
description: HOTFIX — produksi rusak, prioritas satu: stop bleeding → repro → fix sempit → bukti → verify → postmortem. Tanpa eksperimen.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill hotfix — jalankan urutan krisis: STOP BLEEDING → REPRO (debug) → FIX SEMPIT → BUKTI (test merah→hijau) → git-guard → /verify.
2. Satu niat saja. Perubahan lain = commit terpisah, DILARANG dibawa.
3. Setelah hijau: postmortem → lessons.md (mengapa lolos, pencegahan).
4. Lapor format HOTFIX. Bila > 30 menit tanpa progress → lapor status + bukti ke user.

## Usage

```
/hotfix [deskripsi bug produksi]
```

- `deskripsi bug produksi` — apa yang rusak di produksi

## Triggers

- **skill hotfix** — urutan krisis
- **skill debug** — cari akar masalah
- **task fixer** — perbaiki sempit
- **skill verify** — pastikan tidak regresi
- **skill postmortem** — evaluasi setelah selesai

## Example

```
/hotfix login endpoint return 500 untuk semua user
/hotfix memory leak di worker process
```

## Expected Output

```
HOTFIX: SELESAI (12 menit)
├── STOP: rollback feature flag X (1 menit)
├── REPRO: rate-limit di middleware yang baru (3 menit)
├── FIX: tambah null check di middleware/rate-limit.js:42 (2 menit)
├── BUKTI: test merah→hijau (4 menit)
├── VERIFY: PASS (2 menit)
├── COMMIT: hotfix: null check rate limit (satu niat)
└── POSTMORTEM: pencegahan = tambah test edge case null
```

## Error Cases

- **Bug tidak bisa direpro** → lapor status + minta info tambahan
- **Fix menambah scope** → BATAL, satu niat saja
- **>30 menit tanpa progress** → lapor status + bukti
- **Regresi saat fix** → revert, coba approach lain

## Related Commands

- `/fix** — fix non-darurat (lebih santai)
- `/debug** — debugging tanpa urgensi produksi
- `/postmortem** — evaluasi pasca-incident
