---
description: DEBUG sistematis — reproduksi → isolasi → hipotesis → bukti → fix → re-test. Wajib sebelum memperbaiki bug apa pun, dilarang menebak.
---
# DEBUG

Dilarang menebak. Dilarang fix sebelum akar masalah ketemu. Urutan WAJIB:

1. **REPRODUKSI** — buktikan bug muncul dengan command/langkah pasti. Tidak bisa direproduksi? Catat itu, jangan karang cerita.
2. **ISOLASI** — persempit: file → fungsi → baris. Pakai log sementara, `git bisect`, atau eliminasi variabel.
3. **HIPOTESIS** — 1–2 dugaan penyebab. Tulis singkat. Masing-masing harus bisa dibuktikan salah.
4. **BUKTI** — tes hipotesis dengan eksperimen terkecil. Hasilnya menang atas opini.
5. **FIX** — perbaiki akar masalah, bukan gejala. Tambah test yang gagal dulu, lalu lulus, bila mungkin.
6. **RE-TEST** — jalankan test-full. Bug sama muncul lagi? Kembali ke langkah 2.

Output wajib: root cause + `file:baris` + test pembuktian.
Log sementara untuk debugging HAPUS sebelum selesai.
