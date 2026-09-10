---
description: POSTMORTEM — bedah insiden/gagal: garis waktu, akar masalah, dampak, aksi pencegahan permanen. Tanpa menyalahkan. Wajib setelah gagal keras atau data rusak.
---

# POSTMORTEM

Gagal = data. Bedah dulu, baru lanjut. Yang tidak ditulis akan terulang.

## APA YANG DILAKUKAN
Menganalisis insiden atau kegagalan secara mendalam: garis waktu, akar masalah, dampak, dan aksi pencegahan permanen. Postmortem = bedah mayat teknis: mencari penyebab kematian agar tidak terulang.

## KAPAN WAJIB JALAN
1. **Tugas GAGAL keras** — gerbang tidak bisa dilalui
2. **Data rusak/hilang** — operasi merusak data
3. **Regresi produksi** — bug lolos test lama sampai ke user
4. **Bug yang lolos test** — test ada tapi tidak menangkap
5. **Hotfix** — produksi down, perlu postmortem setelah tenang

## FORMAT
```
## POSTMORTEM: <judul> — <tanggal>
GARIS WAKTU : <detik/menit/langkah — kapan mulai sampai ketahuan>
DAMPAK      : <apa yang rusak, seberapa luas, angka>
AKAR        : <sebab utama — teknik, bukan orang>
MENGAPA LOLOS: <kenapa test/audit tidak menangkap>
AKSI        : [x] fix sekarang → [x] test regresi → [x] pencegahan permanen (gerbang/skill/aturan)
PELAJARAN   : 1 baris → masuk lessons.md (skill learn)
```

## URUTAN KERJA

### 1. GARIS WAKTU
Kapan mulai, kapan terjadi, kapan ketahuan, kapan ditangani.
Setiap langkah dengan timestamp bila mungkin.

### 2. DAMPAK
- Apa yang rusak? (data, service, reputasi)
- Seberapa luas? (berapa user terpengaruh)
- Angka pasti bila ada

### 3. AKAR MASALAH
Penyebab TEKNIS, bukan kesalahan orang.
- Bukan "developer lupa" → "tidak ada guard yang mendeteksi"
- Bukan "test jelek" → "test tidak mengcover skenario X"

### 4. MENGAPA LOLOS
Kenapa test/audit tidak menangkap?
- Test tidak ada untuk skenario ini?
- Audit tidak cek area ini?
- Guard tidak cukup sensitif?

### 5. AKSI PERMANEN
- Fix sekarang: perbaikan langsung
- Test regresi: test permanen untuk mencegah kembali
- Pencegahan: gerbang/skill/aturan baru

### 6. PELAJARAN
1 baris → masuk lessons.md (skill learn)

## ATURAN
- Tanpa menyalahkan orang. Bedah sistem, bukan pribadi
- AKSI tanpa perubahan konkret = dilarang. "Lebih teliti" dilarang
- MENGAPA LOLOS wajib dijawab — kalau tidak, gerbang yang sama akan bolong lagi
- Regresi dari postmortem WAJIB punya test permanen (skill test-design: blok REGRESSION)

## INTEGRASI PIPELINE
```
INSIDEN → POSTMORTEM ← posisi skill ini → LESSONS.MD → PREVENSI
                         ↓
                    LEARN (pelajaran)
                    TEST-DESIGN (test regresi)
                    GERGANG BARU (pencegahan)
```
- Sebelum: insiden terjadi, data rusak, produksi down
- Sesudah: learn (pelajaran), test-design (test regresi), pencegahan permanen
- Berkaitan: `skill learn` (pelajaran), `skill recovery` (pemulihan), `skill hotfix` (fix cepat)

## EDGE CASE
- Insiden kecil → postmortem ringkas (5 baris)
- Insiden besar → postmortem lengkap + review tim
- Penyebab tidak diketahui → catat "penyebab tidak diketahui" + rencana investigasi
- Insiden berulang → postmortem sebelumnya belum efektif, evaluasi ulang

## ERROR HANDLING
- Garis waktu tidak lengkap → isi dengan perkiraan, catat
- Dampak tidak bisa diukur → estimasi + catat sebagai estimasi
- Akar masalah tidak jelas → investigasi lebih lanjut, jangan tebak

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip postmortem → insiden akan terulang
- ❌ Menyalahkan orang → bedah sistem, bukan pribadi
- ❌ AKSI tanpa perubahan → "lebih hati-hati" bukan pencegahan
- ❌ Tidak ada test regresi → bug akan kembali
- ❌ Postmortem terlalu panjang → cukup untuk pelajaran, jangan esai
