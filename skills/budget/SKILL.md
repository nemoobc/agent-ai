---
description: BUDGET — anggaran konteks sesi (HUKUM 8 terukur): pakai ringkasan konteks ringkas + pengukuran pemakaian per fase + pemicu compact/handoff sebelum kehabisan.
---

# BUDGET (HUKUM 8 TERUKUR)

Konteks = bahan bakar. Habis di tengah = pekerjaan mati. Kelola, jangan cuma harap cukup.

## APA YANG DILAKUKAN
Mengukur dan mengelola pemakaian konteks sesi agar tidak kehabisan di tengah kerja. Budget = GPS konteks: memberi tahu posisi dan kapan harus berhenti mengisi.

## ANGGARAN DEFAULT (per sesi kerja besar)

| Fase | Budget | Catatan |
|---|---|---|
| BOOT (recall+scan) | ≤ 10% | Ringkas ke peta 10 baris, buang mentahnya |
| GODOK (plan+spec) | ≤ 20% | Rencana tampil ke user, inti disimpan ke PLAN.md bila besar |
| BANGUN | ≤ 40% | Tiap file selesai → ringkas 1 baris ke papan kerja |
| TEST+AUDIT+FIX | ≤ 20% | Output test diringkas jadi angka, bukan log penuh |
| CADANGAN | ≥ 10% | Jangan pernah kosong; habis → HANDOFF SEKARANG |

## PEMICU (jalan otomatis)
1. Sudah baca ulang file yang sama 2x → ringkas permanen (skill context)
2. Output tool > 100 baris → ambil angka yang dipakai, sisanya buang
3. Fase berikutnya butuh konteks lebih dari cadangan → compact + handoff dulu (HUKUM 8)

## CARA KERJA

### Saat Setiap Fase Besar
1. Estimasi pemakaian fase ini: berapa banyak yang perlu dibaca/diproses
2. Bandingkan dengan budget tersedia
3. Cadangan < 10% → HANDOFF SEKARANG, kerja DILARANG lanjut
4. Tandai di laporan: `[BUDGET] pakai ~X% | fase: Y | cadangan: Z`

### Monitoring Berkelanjutan
- Hitung perkiraan dari jejak baca/output
- Update estimasi di akhir tiap fase
- Jangan tunggu habis → compact di 20%, bukan di 0%

## URUTAN (GERBANG)
- Sebelum fase besar → cek sisa anggaran dulu; cadangan < 10% → compact/handoff DULU, kerja DILARANG lanjut
- Habis baca file sama 2x / output tool > 100 baris → ringkas permanen sebelum kerja berikutnya

## OUTPUT FORMAT
```
[BUDGET] pakai ~X% | fase: Y | cadangan: Z | aksi: lanjut/compact/handoff
```
Angka = estimasi jujur dari jejak baca/output, bukan karangan. Salah ukur pun tidak apa — yang penting pemicu jalan.

## INTEGRASI PIPELINE
```
BOOT → BUDGET ← posisi skill ini → GODOK → BANGUN → TEST → LAPOR
         ↑                                              ↓
    CONTEXT (compact)                              HANDOFF (cadangan habis)
```
- Sebelum: scan (peta project), context (disiplin konteks)
- Sesudah: semua fase kerja (monitoring berkelanjutan)
- Berkaitan: `skill context` (aturan konteks), `skill handoff` (transfer saat habis)

## EDGE CASE
- Sesi sangat pendek (<5 file) → budget bisa lebih longgar
- Sesi sangat panjang (>20 file) → budget lebih ketat, compact lebih sering
- Banyak output tool → ringkas agresif, ambil angka saja
- User banyak bertanya → konteks terpakai untuk jawaban, kurangi budget kerja

## ERROR HANDLING
- Salah ukur →修正 estimasi, jangan paksa lanjut
- Compact tapi konteks masih penuh → handoff sekarang
- Handoff tapi sesi baru juga penuh → masalah fundamental, perlu postmortem

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Mengabaikan budget → habis di tengah = kerja mati setengah jalan
- ❌ Terlalu banyak detail disimpan → boros konteks, compact lebih penting
- ❌ Skip monitoring → "masih cukup" tanpa data = judi
- ❌ Compact terlalu telat → sudah telat compact = konteks hilang
- ❌ Menganggap budget = batas kaku → ini panduan, sesuaikan dengan realita
