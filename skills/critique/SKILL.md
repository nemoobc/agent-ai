---
description: CRITIQUE — serangan adversarial ke hasil kerja sendiri: spesifikasi, logika, bukti, skenario tak-teruji. Veto blokir lapor SELESAI.
---
# CRITIQUE

DEV panggil (task `critic`) SETELAH audit CLEAN, SEBELUM lapor SELESAI. Tugas besar/berisiko → WAJIB. Tugas kecil (< 3 file, tanpa risiko) → boleh skip dengan alasan tertulis 1 baris.

## URUTAN
1. Kumpulkan klaim yang akan dilaporkan (status, angka test, file, fitur).
2. Untuk tiap klaim: temukan BUKTInya (exit code, output test, file:baris). Tanpa bukti = temuan.
3. Serang 5 tembakan: SPESIFIKASI → LOGIKA → BUKTI → SKENARIO TAK-TERUJI → GAP.
4. Minimal 3 skenario rusak yang belum dites + prediksi akibatnya.
5. Verdict: CLEAN / VETO (n). VETO → task fixer → ulang → CLEAN.

## GERBANG (KAPAN DILARANG)
- Lapor SELESAI dengan veto tersisa = DILARANG (gerbang dev.md).
- Critique yang cuma muji = critique palsu, ulang dengan bukti.
- Hitungan temuan tidak dicatat = critique tidak terjadi.
