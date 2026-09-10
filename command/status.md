---
description: STATUS — papan kondisi satu layar: milestone, test, audit, perubahan menggantung, risiko, langkah berikutnya.
agent: dev
---
TUGAS: $ARGUMENTS

Kumpulkan angka nyata (baca, jangan ingat-ingat):
1. `git status --short` + `git diff --stat` — perubahan menggantung.
2. Papan milestone terakhir bila ada (skill milestone) — M1..Mn + status.
3. Test terakhir & audit terakhir (exit code). Tidak ada data → jalankan skill test-full + audit-full sekarang.
4. Tampilkan papan satu layar:

```
STATUS  : <tanggal + branch>
MILEST  : M1 [SELESAI] M2 [JALAN] M3 [ANTRE]
TEST    : <PASS/FAIL + angka + kapan>
AUDIT   : <CLEAN / X temuan + kapan>
KOTOR   : <X file berubah belum dikommit / bersih>
RISIKO  : <0–3 item teratas>
NEXT    : <1–3 langkah>
```

5. Ada temuan P0/P1 atau test merah → tawarkan langsung: jalankan /fix?

## Usage

```
/status
```

- Tidak ada argument — kumpulkan semua data + tampilkan.

## Triggers

- **git status/diff** — perubahan menggantung
- **skill milestone** — status milestone
- **skill test-full** — angka test terakhir
- **skill audit-full** — angka audit terakhir

## Example

```
/status
```

## Expected Output

```
STATUS  : 2026-09-10, branch: main
MILEST  : M1 [SELESAI] M2 [JALAN] M3 [ANTRE]
TEST    : PASS (42/42) — 2026-09-10 14:00
AUDIT   : CLEAN — 2026-09-10 14:05
KOTOR   : 3 file berubah belum dikommit
RISIKO  : migration script belum di-test production
NEXT    : 1. commit  2. /release  3. /handoff
```

## Error Cases

- **Git tidak tersedia** → lapor tanpa info git
- **Test/audit belum pernah jalan** → jalankan sekarang
- **Milestone tidak ada** → skip milestone section

## Related Commands

- `/report** — laporan formal (lebih detail)
- `/roadmap** — langkah berikutnya berdasar dampak×usaha
- `/fix** — bila test merah atau audit P0/P1

