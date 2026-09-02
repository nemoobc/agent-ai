---
name: observability
description: Logging, metrics, tracing, health checks, alerts, and operational diagnostics.
---

# observability

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Log, monitor, metric, trace, health check, dashboard, alert, reliability, atau incident diagnosis.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Gunakan structured logs dengan request/correlation ID bila relevan.\n- Jangan log secret, token, password, atau data pribadi sensitif.\n- Tambahkan health/readiness check yang bermakna.\n- Pilih metric dari user impact, error rate, latency, throughput, saturation, dan dependency health.\n- Buat alert actionable dan hindari alert noise.\n- Dokumentasikan cara diagnosis dan recovery.

## Validasi

1. Periksa bahwa log memiliki context tanpa data sensitif.\n2. Uji endpoint health bila tersedia.\n3. Pastikan metric dan alert dapat dipetakan ke tindakan.\n4. Periksa failure dependency path.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
