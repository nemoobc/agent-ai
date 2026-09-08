---
name: backend-api
description: Backend services, APIs, authentication, authorization, and integrations.
---

# backend-api

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- REST, GraphQL, gRPC, webhook, service layer, auth, queue, atau server-side logic.
- Endpoint baru atau perubahan kontrak API.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Definisikan request, response, error, dan authorization contract.
- Validasi input pada boundary.
- Jangan bocorkan stack trace, secret, atau detail internal.
- Gunakan status code dan format error yang konsisten.
- Terapkan pagination pada collection yang dapat tumbuh tanpa batas.
- Gunakan idempotency untuk endpoint atau webhook yang membutuhkan.
- Tambahkan rate limit atau abuse protection bila relevan.
- Tambahkan structured logging tanpa secret.
- Dokumentasikan environment variable dan dependency eksternal.

## Validasi

1. Jalankan test endpoint atau integration test.
2. Uji input invalid, unauthorized, forbidden, not found, dan failure dependency.
3. Periksa kontrak response dan backward compatibility.
4. Jalankan typecheck/build bila relevan.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
