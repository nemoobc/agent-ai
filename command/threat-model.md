---
description: Peta ancaman surface baru: aset, aktor, jalur, dampak, mitigasi — sebelum koding, sejalan dengan red-team
agent: dev
---
TUGAS: /threat-model <fitur>

1. Tentukan surface: auth, pembayaran, data user, endpoint publik, upload, integrasi luar.
2. Tulis model (maks 20 baris): ASET / AKTOR / JALUR / DAMPAK (P0–P3) / MITIGASI / SISA (risiko diterima + persetujuan user).
3. Jalur P0/P1 tanpa mitigasi konkret → masuk SISA, minta keputusan user (opsi bernomor + angka, HUKUM 7).
4. Masukkan mitigasi ke spesifikasi/plan SEBELUM coder mulai.
5. Setelah bangun: red-team WAJIB — uji jalur yang dipetakan satu per satu.
