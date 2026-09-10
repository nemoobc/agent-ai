---
description: EVAL — eval regresi perilaku agent: kasus klaim-palsu, hitungan-salah, injeksi-prompt, guard-bocor. Kit tidak boleh mundur antar versi.
---

# EVAL

## APA YANG DILAKUKAN
Menguji regresi perilaku agent kit sendiri: apakah capability agent masih berfungsi dengan benar? Eval = uji kualitas internal kit, bukan uji aplikasi user.

## SCRIPT
`bash tests/eval.sh` — 7 kasus perilaku terhadap kit sendiri (bukan fixture luar):

| # | Kasus | Diharapkan | Verification |
|---|-------|-----------|-------------|
| 1 | Laporan berisi klaim tanpa bukti | Terdeteksi | grep marker |
| 2 | Hitungan skill di tulisan ≠ folder | Lint/self-test FAIL | Angka cocok |
| 3 | Konten berisi perintah injeksi | injection-guard exit 1 | Pola terdeteksi |
| 4 | Konten bersih | injection-guard exit 0 | Tidak ada pola |
| 5 | Guard blokir secret | git-guard exit 1 | Secret terdeteksi |
| 6 | Kit sehat | doctor exit 0 | Semua cek pass |
| 7 | Clean jalan | node_modules/src selamat | Allowlist ketat |

## KAPAN JALAN
1. **Sebelum rilis** — pastikan tidak ada regresi capability
2. **Setelah perubahan skill/script** — pastikan tidak merusak yang sudah ada
3. **Saat CI/CD** — automated check di pipeline
4. **Setelah upgrade dependencies** — pastikan tidak merusak kit

## CARA KERJA
1. Jalankan `bash tests/eval.sh`
2. Periksa exit code: 0 = semua pass, 1 = ada gagal
3. Baca output detail per kasus
4. Kasus merah → investigasi, fix, ulang eval

## ATURAN
- 1 kasus merah = versi TIDAK boleh dirilis (HUKUM 9)
- Kasus baru dari bug nyata → masuk sini permanen (sama seperti lessons.md)
- eval jalan di `make verify` dan CI — bukan dokumen, gerbang

## GERBANG
- Satu kasus merah = BLOCKED, tidak bisa lapor SELESAI
- Kasus tidak dijalankan = dianggap gagal
- Evaluasi harus dilakukan SEBELUM final report

## INTEGRASI PIPELINE
```
PERUBAHAN KODE → EVAL ← posisi skill ini → RILIS / DELIVER
                     ↓
               FIX (bila ada gagal)
               VERIFY (make verify)
```
- Sebelum: perubahan skill/script, update dependencies
- Sesudah: rilis, deliver, final report
- Berkaitan: `skill self-test` (test kit), `skill doctor` (health check)

## EDGE CASE
- Eval gagal karena dependensi hilang → install dulu, ulang
- Eval timeout → tingkatkan timeout, atau pecah kasus
- Kasus baru belum ada test → tambah ke eval.sh

## ERROR HANDLING
- Script eval tidak ada → fallback: jalankan kasus secara manual
- Kasus tidak bisa dieksekusi → skip dengan alasan, catat
- Semua kasus gagal → masalah fundamental, postmortem

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip eval → "biasanya aman" = tidak ada bukti
- ❌ Menganggap eval = test → eval = regresi capability, test = kualitas kode
- ❌ Kasus merah diabaikan → BLOCKED sampai fix
- ❌ Tidak menambah kasus baru dari bug → pelajaran hilang
- ❌ Eval hanya di local → harus juga di CI/CD
