---
description: AUTO TEST FULL — deteksi semua framework test di project (node/python/go/rust/php/make) dan jalankan semuanya. Wajib setiap selesai menulis/mengubah kode.
---
# TEST-FULL
Jalankan dari root project: (kalau terpasang di project: `bash .opencode/skill/test-full/run.sh .`)

## EXIT CODE & GERBANG
- Exit code: 0 = PASS semua, 1 = ADA GAGAL, 2 = TIDAK ADA TEST.
- GAGAL → baca output, lanjut ke agent FIXER (jangan lapor gagal dulu ke user).
- NO-TESTS → tulis test dulu via CODER sebelum dianggap selesai.
Laporkan ringkas: jumlah suite, pass, fail.
