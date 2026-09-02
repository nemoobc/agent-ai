---
name: incident-response
description: Incident triage, containment, recovery, communication, and postmortem.
---

# incident-response

## Trigger

Gunakan skill ini ketika tugas melibatkan:

- Outage, incident, breach, degraded service, data issue, production failure, recovery, atau postmortem.

## Sebelum Bekerja

1. Baca instruksi repository seperti `AGENTS.md`, `README.md`, dan konfigurasi terkait.
2. Inspeksi file, dependency, test, serta implementasi serupa.
3. Tentukan batas perubahan, risiko, dan asumsi.
4. Ikuti pola yang sudah ada sebelum membuat pola baru.
5. Jangan mengubah area yang tidak terkait.

## Standar Kerja

- Utamakan keselamatan, containment, data integrity, dan bukti.\n- Jangan melakukan aksi destruktif tanpa approval.\n- Tentukan impact, scope, timeline, dan service dependency.\n- Pertahankan log dan evidence yang relevan.\n- Gunakan rollback atau mitigasi terkecil yang menurunkan impact.\n- Pisahkan fakta, hipotesis, dan keputusan.\n- Buat postmortem berorientasi perbaikan sistem, bukan menyalahkan individu.

## Validasi

1. Verifikasi service recovery dan data integrity.\n2. Catat timestamp, tindakan, dan hasil.\n3. Pastikan monitoring/alert tidak terus memicu setelah recovery.\n4. Buat follow-up untuk root cause dan pencegahan.

## Output

Laporkan:

1. Perubahan atau hasil utama.
2. File penting yang disentuh.
3. Validasi yang benar-benar dijalankan.
4. Asumsi, risiko, batasan, atau pekerjaan lanjutan.
