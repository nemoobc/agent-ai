---
name: devops-platform
description: Containers, CI/CD, Linux, deployment, infrastructure, reliability, and rollback.
---

# devops-platform

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Docker, Compose, Kubernetes, GitHub Actions, GitLab CI, deployment, server, cloud, reverse proxy, TLS, environment, atau infrastructure.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Buat konfigurasi reproducible.\n- Gunakan environment variable dan secret manager bila tersedia.\n- Tambahkan health check.\n- Terapkan least privilege dan minimalkan port terbuka.\n- Jangan embed secret di image atau repository.\n- Jelaskan persistent storage, migration, backup, dan rollback.\n- Hindari command production destruktif tanpa konfirmasi.\n- Optimalkan image secara wajar tanpa mengorbankan debugability.

## Validasi

1. Validasi syntax Docker/CI/IaC.\n2. Build image atau jalankan config validation bila tersedia.\n3. Periksa environment variable, volume, port, health check, dan rollback.\n4. Pastikan command tidak menghapus data tanpa konfirmasi.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
