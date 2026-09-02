---
name: documentation
description: Technical documentation, README, API reference, ADR, runbook, and migration guides.
---

# documentation

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- README, docs, API docs, deployment guide, ADR, changelog, runbook, atau troubleshooting.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Sesuaikan dengan audiens: developer, operator, pengguna, atau maintainer.\n- Dokumentasikan prerequisite, install, config, usage, validation, troubleshooting, dan limitation bila relevan.\n- Gunakan command yang sesuai project.\n- Jangan tulis command yang belum diverifikasi sebagai pasti berhasil.\n- Jaga dokumentasi selaras dengan code actual.\n- Hindari narasi panjang tanpa instruksi yang dapat ditindaklanjuti.

## Validasi

1. Cross-check nama file, command, environment variable, dan endpoint terhadap code.\n2. Pastikan langkah bisa diikuti berurutan.\n3. Periksa contoh tidak membocorkan secret.\n4. Perbarui docs yang terdampak behavior change.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
