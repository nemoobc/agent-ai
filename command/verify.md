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
7. `bash tests/mutation.sh`      — bukti detektor (10 perusakan tertangkap)
8. `bash tests/bench.sh`         — durasi gate di bawah hard-cap
9. `bash skills/audit-full/run.sh .` — audit kit sendiri
10. `bash skills/doctor/run.sh .`    — kesehatan kit

LAPOR 1 blok:
```
VERIFY  : <tanggal>
LINT    : LOLOS (N cek) / FAIL
SELF    : PASS (N) / FAIL
EVAL    : PASS (6/6) / FAIL
E2E     : UTUH (N) / GAGAL
DEMO    : TERBUKTI (N) / GAGAL
UPDATE  : PASS (N) / FAIL
MUTATION: PASS (10/10) / FAIL
BENCH   : PASS / FAIL
AUDIT   : CLEAN / X temuan
DOCTOR  : SEHAT / X masalah
STATUS  : SEMUA HIJAU → SELESAI boleh / ADA MERAH → fix dulu
```

GERBANG: satu merah → fix dulu (task fixer), ulangi. Tanpa /verify hijau, lapor SELESAI dilarang (HUKUM 9).