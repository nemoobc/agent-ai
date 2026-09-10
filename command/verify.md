---
description: VERIFY — satu tombol semua gerbang: lint-kit + self-test + e2e + demo + test-update + audit-full + doctor. Wajib sebelum lapor SELESAI (HUKUM 9).
agent: dev
---
TUGAS: $ARGUMENTS

Jalankan BERURUTAN dari root kit/repo ini (skip yang tidak ada, catat):
1. `bash tests/lint-kit.sh`      — struktur kit
2. `bash tests/self-test.sh`     — detektor & badge
3. `bash tests/eval.sh`          — eval regresi perilaku (klaim palsu, injeksi, guard)
4. `bash tests/e2e-flow.sh`      — alur agent penuh
5. `bash tests/run-demo.sh`      — demo pipeline hidup
6. `bash tests/test-update.sh`   — update flow (upgrade + anti-downgrade)
7. `bash tests/mutation.sh`      — bukti detektor (15 perusakan tertangkap)
8. `bash tests/bench.sh`         — durasi gate di bawah hard-cap
9. `bash skills/audit-full/run.sh .` — audit kit sendiri
10. `bash skills/doctor/run.sh .`    — kesehatan kit

LAPOR 1 blok:
```
VERIFY  : <tanggal>
LINT    : LOLOS (N cek) / FAIL
SELF    : PASS (N) / FAIL
EVAL    : PASS (10/10) / FAIL
E2E     : UTUH (N) / GAGAL
DEMO    : TERBUKTI (N) / GAGAL
UPDATE  : PASS (N) / FAIL
MUTATION: PASS (15/15) / FAIL
BENCH   : PASS / FAIL
AUDIT   : CLEAN / X temuan
DOCTOR  : SEHAT / X masalah
STATUS  : SEMUA HIJAU → SELESAI boleh / ADA MERAH → fix dulu
```

GERBANG: satu merah → fix dulu (task fixer), ulangi. Tanpa /verify hijau, lapor SELESAI dilarang (HUKUM 9).

## Usage

```
/verify
```

- Tidak ada argument — jalankan semua 10 gerbang.

## Triggers

- **bash tests/lint-kit.sh** — struktur kit
- **bash tests/self-test.sh** — detektor & badge
- **bash tests/eval.sh** — eval regresi perilaku
- **bash tests/e2e-flow.sh** — alur agent penuh
- **bash tests/run-demo.sh** — demo pipeline
- **bash tests/test-update.sh** — update flow
- **bash tests/mutation.sh** — bukti detektor
- **bash tests/bench.sh** — durasi gate
- **bash skills/audit-full/run.sh** — audit kit
- **bash skills/doctor/run.sh** — kesehatan kit

## Example

```
/verify
```

## Expected Output

```
VERIFY  : 2026-09-10
LINT    : LOLOS (24 cek)
SELF    : PASS (56 cek)
EVAL    : PASS (8/8)
E2E     : UTUH (5 langkah)
DEMO    : TERBUKTI (4 langkah)
UPDATE  : PASS (3 langkah)
MUTATION: PASS (12/12)
BENCH   : PASS (6 gate)
AUDIT   : CLEAN
DOCTOR  : SEHAT
STATUS  : SEMUA HIJAU → SELESAI boleh
```

## Error Cases

- **Satu gerbang merah** → fix dulu, ulangi dari awal
- **Script tidak ada** → skip + catat "tidak ada"
- **Timeout** → lapor gerbang yang timeout

## Related Commands

- `/doctor** — diagnosa lebih ringan
- `/audit** — audit kode (bukan kit)
- `/build** — bangun fitur (verify setelah build)

