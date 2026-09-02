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

- Mulai dari bukti: error, log, stack trace, test, reproduction step.\n- Reproduksi masalah bila memungkinkan.\n- Cari root cause terkecil yang menjelaskan gejala.\n- Uji hipotesis secara sempit.\n- Perbaiki penyebab, bukan hanya gejala.\n- Tambahkan regression test bila cocok.\n- Jangan menebak jika bukti dapat diinspeksi.

## Validasi

1. Reproduksi ulang atau jalankan test gagal.\n2. Jalankan test setelah perbaikan.\n3. Verifikasi edge case yang menyebabkan masalah.\n4. Catat root cause, fix, dan status validasi.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
