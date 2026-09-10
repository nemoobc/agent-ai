---
description: MIGRATE — ubah skema/data/model dengan aman: snapshot dulu, skrip mundur, jalan bertahap, verifikasi, test, audit. Tanpa snapshot = dilarang. Data hilang tidak bisa dikembalikan oleh test.
---

# MIGRATE

Data hilang = tidak ada test yang bisa mengembalikan. Snapshot dulu, baru apa pun.

## APA YANG DILAKUKAN
Mengubah skema database, model data, atau struktur data secara terukur dan aman. Migrate = operasi bedah data: presisi, bukan keberanian.

## KAPAN WAJIB JALAN
1. **Schema berubah** — tambah/hapus kolom, ubah tipe, rename
2. **Data transform** — konversi format, merge kolom, split field
3. **Model berubah** — perubahan data model yang mempengaruhi persistensi
4. **API version upgrade** — perubahan kontrak yang mempengaruhi data
5. **User minta migrasi data** — apapun jenisnya

## URUTAN KERJA (TANPA SKIP)

### 1. SNAPSHOT (backup)
Backup dulu: dump / salinan file / git commit eksplisit.
Tanpa snapshot: BERHENTI, lapor, minta keputusan user.
→ skill `backup`

### 2. CONTOH
Tulis contoh data lama → data baru (1–3 baris). Perubahan tak bisa diperlihatkan = belum dipahami.
```
LAMA: { name: "John", age: 25 }
BARU: { first_name: "John", birth_year: 1999 }
```

### 3. SKRIP MUNDUR (down-migration)
Tulis down-migration SEBELUM up-migration. Tidak bisa mundur → perlu persetujuan eksplisit user.

### 4. UJI KECIL
Jalankan di salinan/dataset kecil dulu. Hitung baris sebelum/sesudah.

### 5. JALAN BERTAHAP
Produksi: batch kecil, checkpoint tiap batch, log progres. Bisa dihentikan & dilanjutkan.

### 6. VERIFIKASI
Jumlah baris cocok, spot-check record, query kunci balikan hasil wajar.

### 7. TEST + AUDIT
skill `test-full` + `audit-full`. Merah = mundur (down-migration), perbaiki, ulang.

### 8. LAPOR
Snapshot di mana, baris berubah, hasil verifikasi, lokasi skrip mundur.

## GERBANG
- Tanpa snapshot = DILARANG jalan
- Down-migration tidak ada + data besar = HUKUM 5 (minta keputusan user)
- Skema berubah + kode lama belum ikut = deploy dilarang sampai sinkron

## INTEGRASI PIPELINE
```
BACKUP → MIGRATE ← posisi skill ini → VERIFY → TEST-FULL → AUDIT-FULL
                    ↓
              DOWN-MIGRATION (bila gagal)
              ROLLBACK (restore dari backup)
```
- Sebelum: backup (snapshot), think (analisa perubahan)
- Sesudah: test-full (verifikasi), audit-full (keamanan)
- Berkaitan: `skill backup` (snapshot), `skill recovery` (pulihkan), `skill data` (analisis data)

## EDGE CASE
- Data kosong → migrasi tetap jalan, verifikasi = 0 baris cocok
- Data sangat besar (>1M baris) → batch processing, checkpoint per batch
- Schema berubah + dependensi → pastikan semua dependensi ikut diupdate
- Migrasi downtime → konfirmasi maintenance window dengan user

## ERROR HANDLING
- Migrasi gagal di tengah → DOWN-MIGRATION segera
- Data corrupt setelah migrasi → RESTORE dari backup
- Verifikasi gagal → DOWN-MIGRATION + postmortem
- Timeout → batch lebih kecil, checkpoint lebih sering

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip snapshot → "biasanya aman" = judi dengan data orang
- ❌ Migrasi tanpa down-migration → tidak bisa mundur = trap
- ❌ Migrasi langsung di produksi tanpa uji coba → disaster
- ❌ Migrasi tanpa verifikasi → tidak tahu data rusak
- ❌ Migrasi terlalu besar sekaligus → pecah ke batch kecil
