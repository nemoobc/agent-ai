---
name: database
description: Database schema design, migrations, SQL safety, performance, and data integrity.
---

# database

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- SQL, ORM, migration, schema, query, index, transaction, PostgreSQL, MySQL, SQLite, MongoDB, Redis.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Gunakan tipe data, constraint, primary key, foreign key, unique constraint, dan check constraint yang sesuai.
- Parameterize query.
- Gunakan transaction ketika perubahan multi-step wajib atomik.
- Tambahkan index berdasarkan query path nyata.
- Hindari N+1 query.
- Rancang migration agar reversible bila praktis.
- Jangan menghapus data atau kolom produksi tanpa persetujuan eksplisit.
- Jangan menyimpan secret atau data sensitif tanpa perlindungan yang tepat.

## Validasi

1. Periksa migration secara manual.
2. Jalankan migration pada environment aman bila tersedia.
3. Jalankan test query atau integration test.
4. Periksa efek pada data existing, rollback, constraint, dan performance path.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
