---
name: security-defensive
description: Defensive application security, secure coding, threat modeling, and remediation.
---

# security-defensive

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Auth, authorization, session, token, secret, API, upload, dependency, personal data, payment, infrastructure, atau security audit.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Terapkan least privilege, input validation, output encoding, parameterized query, secure secret handling, dan audit logging.
- Periksa OWASP risks sesuai konteks.
- Jangan log secret atau personal data sensitif.
- Gunakan secure transport dan secure cookie setting bila relevan.
- Hindari wildcard CORS, disabled TLS verification, unsafe deserialization, insecure random generator, dan authorization bypass.
- Pastikan dependency dan konfigurasi tidak memperlebar attack surface.
- Bantu hanya scope defensif dan berizin.

## Validasi

1. Periksa input boundary, authN, authZ, secret management, dan error exposure.
2. Jalankan security-oriented test atau static check bila tersedia.
3. Dokumentasikan risiko residual dan mitigasi.
4. Pastikan tidak ada secret baru di diff.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
