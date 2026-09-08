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
