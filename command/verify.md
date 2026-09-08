---
description: VERIFY — satu tombol semua gerbang: lint-kit + self-test + e2e + demo + test-update + audit-full + doctor. Wajib sebelum lapor SELESAI (HUKUM 9).
agent: dev
---
TUGAS: $ARGUMENTS

Jalankan BERURUTAN dari root kit/repo ini (skip yang tidak ada, catat):
1. `bash tests/lint-kit.sh`      — struktur kit (147+ cek)
2. `bash tests/self-test.sh`     — detektor & badge (94+ cek)
3. `bash tests/e2e-flow.sh`      — alur agent penuh
4. `bash tests/run-demo.sh`      — demo pipeline hidup
5. `bash tests/test-update.sh`   — update flow (upgrade + anti-downgrade)
6. `bash skills/audit-full/run.sh .` — audit kit sendiri
7. `bash skills/doctor/run.sh .`     — kesehatan kit

LAPOR 1 blok:
```
VERIFY  : <tanggal>
LINT    : LOLOS (N cek) / FAIL
SELF    : PASS (N) / FAIL
E2E     : UTUH (N) / GAGAL
DEMO    : TERBUKTI (N) / GAGAL
UPDATE  : PASS (N) / FAIL
AUDIT   : CLEAN / X temuan
DOCTOR  : SEHAT / X masalah
STATUS  : SEMUA HIJAU → SELESAI boleh / ADA MERAH → fix dulu
```

GERBANG: satu merah → fix dulu (task fixer), ulangi. Tanpa /verify hijau, lapor SELESAI dilarang (HUKUM 9).