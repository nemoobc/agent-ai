---
description: CLEAN — bersih-bersih otomatis artefak build/cache/log dari project (allowlist ketat, aman, terukur). --dry untuk pratinjau tanpa hapus.
agent: dev
---
TUGAS: /clean [--dry]

1. `bash skills/clean/run.sh . --dry` dulu bila ragu → tampilkan target + ukuran, tanpa hapus.
2. Yakin → jalankan REAL (tanpa --dry) → lapor byte dibebaskan per target + total.
3. Lapor blok [CLEAN] gaya caveman.

GERBANG: node_modules/.git/.env/kode sumber TIDAK PERNAH disentuh — allowlist di script, bukan keputusan momen. Project tanpa git + hapus besar → minta konfirmasi (HUKUM 5).
