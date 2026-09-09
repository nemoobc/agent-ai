---
description: Jalankan serangan adversarial critic ke hasil kerja sebelum lapor SELESAI
agent: dev
---
TUGAS: /critique

1. Kumpulkan klaim yang akan dilaporkan (status, angka test, file, fitur).
2. Panggil task `critic` — serang 5 tembakan: spesifikasi → logika → bukti → skenario tak-teruji → gap.
3. Output: daftar `[VETO|TEMUAN|CATATAN] temuan — bukti (file:baris/exit code)`.
4. VETO ada → task `fixer` → ulang critique → sampai `VERDICT: CLEAN`.
5. Lapor singkat caveman + rantai bukti (HUKUM 11).
