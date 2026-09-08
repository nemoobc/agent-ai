---
name: debugging
description: Evidence-based debugging, root cause analysis, repair, and regression prevention.
---

# debugging

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Error runtime, stack trace, test failure, build failure, bug, regression, atau performance issue.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Mulai dari bukti: error, log, stack trace, test, reproduction step.
- Reproduksi masalah bila memungkinkan.
- Cari root cause terkecil yang menjelaskan gejala.
- Uji hipotesis secara sempit.
- Perbaiki penyebab, bukan hanya gejala.
- Tambahkan regression test bila cocok.
- Jangan menebak jika bukti dapat diinspeksi.

## Validasi

1. Reproduksi ulang atau jalankan test gagal.
2. Jalankan test setelah perbaikan.
3. Verifikasi edge case yang menyebabkan masalah.
4. Catat root cause, fix, dan status validasi.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
