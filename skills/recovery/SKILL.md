---
description: RECOVERY — pemulihan setelah bencana (data rusak/hilang, migrasi gagal, deploy rusak): restore dari backup, verifikasi, minimal green, postmortem. Backup = tiket pulang.
---

# RECOVERY

Bencana bukan "kalau", tapi "kapan". Recovery = jalan pulang yang sudah disiapkan sebelumnya.

## URUTAN KERJA
1. **BERHENTI** — stop semua operasi tulis. Tidak ada yang boleh nulis lagi sebelum pemulihan selesai.
2. **INVENTORY** — apa yang rusak, kapan rusak (garis waktu), apa yang masih utuh, backup apa yang ada (skill backup).
3. **RESTORE** — dari backup TERDEKAT sebelum kerusakan. Restore ke lokasi/salinan dulu bila ragu (dry-run).
4. **VERIFIKASI** — setelah restore: hitung baris/record, spot-check, test-full + audit-full. Jangan lanjut sebelum terbukti.
5. **MINIMAL GREEN** — layanan minimal jalan dulu. Fitur bertahap setelah aman.
6. **POSTMORTEM** — skill postmortem → lessons.md: akar, mengapa backup/guard gagal menangkap, pencegahan permanen.

## GERBANG
- Operasi tulis lanjut sebelum inventory = DILARANG.
- Restore tanpa verifikasi terukur = belum pulih.
- Backup tidak ada → JANGAN pura-pura: lapor ke user dengan opsi (HUKUM 7 TITIK-PUTUS), jangan menciptakan data dari ingatan.
- Recovery tanpa postmortem = akan terulang. WAJIB.

## FORMAT LAPORAN
```
RECOVERY: <kerusakan → sumber restore → hasil verifikasi>
BUKTI   : record/baris cocok (X/X), test N/N, audit CLEAN
POSTMORTEM: <1 baris akar + aksi pencegahan>
```