---
description: REPORT — ringkasan sesi: perubahan, test, audit, memori, langkah berikutnya. Untuk handoff atau laporan ke tim/manajer.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill recall — ingatan sesi.
2. `git status --short`, `git diff --stat` (staged + unstaged) — daftar perubahan nyata.
3. Hasil terakhir: test (angka), audit (temuan), memori tersimpan.
4. FORMAT LAPOR:
   SESI   : <tanggal + tugas utama>
   DIBUAT : <perubahan, maks 5 baris>
   TEST   : PASS/FAIL + angka
   AUDIT  : CLEAN / X temuan
   RISIKO : <yang perlu diawas>
   NEXT   : <1–3 langkah berikutnya>
5. Bila user minta file: simpan ke `docs/REPORT-<tanggal>.md`, tanpa mengubah kode.

## Usage

```
/report [file/opsional]
```

- `file` — opsional, simpan ke file. Kosong = tampilkan ke user.

## Triggers

- **skill recall** — ingatan sesi
- **git status/diff** — perubahan nyata
- **test/audit terakhir** — angka terkini

## Example

```
/report
/report docs/REPORT-2026-09-10.md
```

## Expected Output

```
REPORT — 2026-09-10
SESI   : auth module enhancement
DIBUAT : src/auth.js (+45 -12), src/middleware.js (+23), tests/auth.test.js (+67)
TEST   : PASS (42/42, +8 baru)
AUDIT  : CLEAN
RISIKO : migration script belum di-test di production
NEXT   : 1. /test-update  2. /release  3. /handoff
```

## Error Cases

- **Tidak ada perubahan** → lapor "sesi kosong, tidak ada yang dilaporkan"
- **File tidak bisa ditulis** → tampilkan ke user saja
- **Git tidak tersedia** → lapor tanpa info git

## Related Commands

- `/handoff** — kemas konteks (ringkas, bukan formal)
- `/status** — papan kondisi real-time
- `/backlog** — langkah berikutnya dari backlog
