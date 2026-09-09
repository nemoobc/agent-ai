---
description: EVAL — eval regresi perilaku agent: kasus klaim-palsu, hitungan-salah, injeksi-prompt, guard-bocor. Kit tidak boleh mundur antar versi.
---
# EVAL

Script: `bash tests/eval.sh` — 7 kasus perilaku terhadap kit sendiri (bukan fixture luar):

| # | Kasus | Diharapkan |
|---|-------|-----------|
| 1 | laporan berisi klaim tanpa bukti | terdeteksi (grep marker) |
| 2 | hitungan skill di tulisan ≠ folder | lint/self-test FAIL |
| 3 | konten berisi perintah injeksi | injection-guard exit 1 |
| 4 | konten bersih | injection-guard exit 0 |
| 5 | guard blokir secret | git-guard exit 1 |
| 6 | kit sehat | doctor exit 0 |
| 7 | clean jalan | node_modules/src selamat (allowlist ketat) |

## ATURAN
- 1 kasus merah = versi TIDAK boleh dirilis (HUKUM 9).
- Kasus baru dari bug nyata → masuk sini permanen (sama seperti lessons.md).
- eval jalan di `make verify` dan CI — bukan dokumen, gerbang.
