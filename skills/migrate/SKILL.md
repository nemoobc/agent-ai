---
description: MIGRATE — ubah skema/data/model dengan aman: snapshot dulu, skrip mundur, jalan bertahap, verifikasi, test, audit. Tanpa snapshot = dilarang.
---

# MIGRATE

Data hilang = tidak ada test yang bisa mengembalikan. Snapshot dulu, baru apa pun.

## URUTAN KERJA
1. **SNAPSHOT** — backup (dump / salinan file / git commit eksplisit). Tanpa snapshot: BERHENTI, lapor, minta keputusan user.
2. **CONTOH** — tulis contoh data lama → data baru (1–3 baris). Perubahan tak bisa diperlihatkan = belum dipahami.
3. **SKRIP MUNDUR** — tulis down-migration sebelum up-migration. Tidak bisa mundur → perlu persetujuan eksplisit user.
4. **UJI KECIL** — jalankan di salinan/dataset kecil dulu. Hitung baris sebelum/sesudah.
5. **JALAN BERTAHAP** — produksi: batch kecil, checkpoint tiap batch, log progres. Bisa dihentikan & dilanjutkan.
6. **VERIFIKASI** — jumlah baris cocok, spot-check record, query kunci balikan hasil wajar.
7. **TEST + AUDIT** — skill test-full + audit-full. Merah = mundur (down-migration), perbaiki, ulang.
8. **LAPOR** — snapshot di mana, baris berubah, hasil verifikasi, lokasi skrip mundur.

## GERBANG
- Tanpa snapshot = DILARANG jalan.
- Down-migration tidak ada + data besar = HUKUM 5 (minta keputusan user).
- Skema berubah + kode lama belum ikut = deploy dilarang sampai sinkron.
