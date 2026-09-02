---
name: codebase-discovery
description: Repository discovery, conventions, dependencies, and change-scope analysis.
---

# codebase-discovery

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Memulai pekerjaan pada repository baru.\n- Mencari struktur, entry point, command, convention, atau file terkait.\n- Sebelum perubahan lintas modul.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Gunakan `rg --files` dan `rg` untuk menemukan file.\n- Baca manifest, konfigurasi, test, dan dokumentasi.\n- Identifikasi package manager, runtime, command validasi, dan batas ownership modul.\n- Periksa `git status --short` sebelum edit signifikan.\n- Perlakukan perubahan yang sudah ada sebagai milik pengguna.

## Validasi

1. Pastikan file yang diedit benar-benar relevan.\n2. Pastikan instruksi lokal sudah dibaca.\n3. Nyatakan asumsi jika struktur atau command tidak tersedia.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
