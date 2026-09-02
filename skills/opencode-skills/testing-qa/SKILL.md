---
name: testing-qa
description: Unit, integration, E2E, regression testing, quality checks, and validation.
---

# testing-qa

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Perubahan perilaku kode.\n- Permintaan test, QA, coverage, regression, lint, typecheck, build, atau E2E.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Pilih level test paling sempit yang membuktikan perilaku.\n- Test public behavior, error case, dan edge case.\n- Hindari mock yang membuat test tidak bermakna.\n- Jaga test deterministik dan terisolasi.\n- Tambahkan regression test untuk bug yang diperbaiki.\n- Jangan mengklaim coverage atau test result tanpa menjalankannya.

## Validasi

1. Jalankan test yang relevan.\n2. Jalankan lint dan typecheck bila tersedia.\n3. Jalankan build untuk perubahan yang memengaruhi artifact.\n4. Laporkan passed, failed, not run, dan alasan secara jujur.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
