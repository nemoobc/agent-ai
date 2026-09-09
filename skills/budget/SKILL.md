---
description: BUDGET — anggaran konteks sesi (HUKUM 8 terukur): pakai ringkasan konteks ringkas + pengukuran pemakaian per fase + pemicu compact/handoff sebelum kehabisan.
---
# BUDGET (HUKUM 8 TERUKUR)

Konteks = bahan bakar. Habis di tengah = pekerjaan mati. Kelola, jangan cuma harap cukup.

## ANGGARAN DEFAULT (per sesi kerja besar)
- BOOT (recall+scan) ≤ 10% — ringkas ke peta 10 baris, buang mentahnya.
- GODOK (plan+spec) ≤ 20% — rencana tampil ke user, inti disimpan ke PLAN.md bila besar.
- BANGUN ≤ 40% — tiap file selesai → ringkas 1 baris ke papan kerja; baca ulang hanya bila file berubah.
- TEST+AUDIT+FIX ≤ 20% — output test diringkas jadi angka, bukan log penuh.
- CADANGAN ≥ 10% — jangan pernah kosong; habis → HANDOFF SEKARANG.

## PEMICU (jalan otomatis)
- Sudah baca ulang file yang sama 2x → ringkas permanen (skill context).
- Output tool > 100 baris → ambil angka yang dipakai, sisanya buang.
- Fase berikutnya butuh konteks lebih dari cadangan → compact + handoff dulu (HUKUM 8).

## URUTAN (GERBANG)
- Sebelum fase besar → cek sisa anggaran dulu; cadangan < 10% → compact/handoff DULU, kerja DILARANG lanjut.
- Habis baca file sama 2x / output tool > 100 baris → ringkas permanen sebelum kerja berikutnya.

## OUTPUT
1 blok ≤ 6 baris di tiap fase besar: `[BUDGET] pakai ~X% | fase: Y | cadangan: Z | aksi: lanjut/compact/handoff`.
Angka = estimasi jujur dari jejak baca/output, bukan karangan. Salah ukur pun tidak apa — yang penting pemicu jalan.
