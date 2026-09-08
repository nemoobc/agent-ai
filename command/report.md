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
