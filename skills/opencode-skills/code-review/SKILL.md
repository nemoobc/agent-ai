---
name: code-review
description: Risk-focused code review for defects, security, regressions, and missing validation.
---

# code-review

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Pengguna meminta review, audit kode, PR review, atau pemeriksaan perubahan.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Utamakan bug, data integrity, security, performance, regression, dan test gap.\n- Bandingkan perubahan dengan behavior yang diharapkan.\n- Gunakan severity yang jelas: critical, high, medium, low.\n- Sertakan lokasi file dan line bila tersedia.\n- Jelaskan impact dan remediation praktis.\n- Jangan menghabiskan review untuk pujian atau style minor.

## Validasi

1. Baca diff dan konteks pemanggil.\n2. Periksa test yang ada.\n3. Periksa failure path dan backward compatibility.\n4. Jika tidak ada temuan, nyatakan residual risk atau test gap.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
