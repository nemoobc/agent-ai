---
name: software-engineering
description: Production-quality implementation, refactoring, architecture, and maintenance.
---

# software-engineering

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Menambah, mengubah, atau memperbaiki kode.
- Mendesain modul, service, library, CLI, atau feature.
- Refactor yang diminta.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Pilih solusi paling kecil yang lengkap.
- Ikuti style, struktur, dan dependency project.
- Validasi input serta tangani failure case.
- Gunakan tipe bila ekosistem mendukung.
- Hindari abstraction prematur.
- Jangan hardcode secret atau konfigurasi environment.
- Tambahkan test jika perilaku berubah dan test infrastructure tersedia.
- Jangan melakukan refactor tidak terkait.

## Validasi

1. Inspeksi diff.
2. Jalankan test paling relevan.
3. Jalankan lint, typecheck, dan build jika tersedia serta relevan.
4. Periksa error handling dan edge case.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
