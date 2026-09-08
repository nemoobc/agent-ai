---
name: testing-qa
description: Unit, integration, E2E, regression testing, quality checks, and validation.
---

# testing-qa

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Perubahan perilaku kode.
- Permintaan test, QA, coverage, regression, lint, typecheck, build, atau E2E.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Pilih level test paling sempit yang membuktikan perilaku.
- Test public behavior, error case, dan edge case.
- Hindari mock yang membuat test tidak bermakna.
- Jaga test deterministik dan terisolasi.
- Tambahkan regression test untuk bug yang diperbaiki.
- Jangan mengklaim coverage atau test result tanpa menjalankannya.

## Validasi

1. Jalankan test yang relevan.
2. Jalankan lint dan typecheck bila tersedia.
3. Jalankan build untuk perubahan yang memengaruhi artifact.
4. Laporkan passed, failed, not run, dan alasan secara jujur.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
