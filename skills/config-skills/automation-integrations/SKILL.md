---
name: automation-integrations
description: Scripts, schedules, webhooks, API integrations, ETL, and reliable batch automation.
---

# automation-integrations

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Script, CLI, cron, scheduler, webhook, API integration, batch process, ETL, atau file processing.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Konfirmasi authorization untuk sistem eksternal.\n- Validasi input dan output.\n- Gunakan dry-run bila praktis.\n- Buat operasi idempotent bila memungkinkan.\n- Tambahkan retry dengan limit dan backoff untuk failure transient.\n- Buat logging berguna tanpa secret.\n- Hindari aksi irreversible secara default.\n- Dokumentasikan configuration, schedule, dan failure handling.

## Validasi

1. Jalankan dry-run atau sample data bila tersedia.\n2. Uji retry, duplicate input, invalid input, dan partial failure.\n3. Periksa secret management.\n4. Pastikan output dan log dapat diaudit.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
