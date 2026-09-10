---
description: TEST-DESIGN — desain test SEBELUM koding: kasus positif, negatif, edge, limit, regresi. Tulis daftar kasusnya dulu, baru implementasi + test. Dipanggil DEV di fase GODOK.
---

# TEST-DESIGN

Test menulis setelah koding = test yang menuruti kode. Test didesain sebelum koding = kontrak. Bedanya besar.

## APA YANG DILAKUKAN
Mendesain kasus test sebelum kode ditulis: kasus positif, negatif, edge, limit, regresi. Test-design = kontrak pengujian: test harus bisa gagal bila kode salah.

## KAPAN WAJIB JALAN
1. **Perilaku baru** — setiap fitur/perilaku baru
2. **Perilaku berubah** — modifikasi yang mempengaruhi output
3. **Bug ditemukan** — test regresi untuk mencegah kembali
4. **Fase GODOK** — bersamaan plan

## KASUS TEST

### 1. POSITIVE (minimal 2)
Input normal → output diharapkan. Happy path.

### 2. NEGATIVE (minimal 2)
Input salah/tidak ada/tipe salah → error jelas, bukan crash.

### 3. EDGE (minimal 2)
Batas: kosong, nol, maksimum, unicode, timezone, race condition.

### 4. LIMIT (bila relevan)
Beban puncak: ukuran besar, banyak sekaligus.

### 5. REGRESSION
Bug lama yang sudah difix → test permanen biar tidak kembali.

## FORMAT DI PLAN
```
[TEST] kasus: +5 (2 pos, 2 neg, 2 edge, 1 reg) → test-full exit 0
```

## ATURAN
- Perilaku baru tanpa kasus di plan → coder DILARANG mulai
- Test yang tidak pernah bisa gagal (assert trivial) = bukan test
- Tidak yakin cara test → pertanyaan di plan, bukan di laporan akhir

## INTEGRASI PIPELINE
```
PLAN → TEST-DESIGN ← posisi skill ini → CODER (tulis kode + test)
                                              ↓
                                        TEST-FULL (jalankan test)
```
- Sebelum: plan (rencana 8 blok), think (analisa)
- Sesudah: coder (implementasi kode + test), test-full (jalankan)
- Berkaitan: `skill test-full` (jalankan test), `skill coverage` (gap test)

## EDGE CASE
- Tidak bisa menulis test sebelum kode → tulis test criteria dulu
- Test terlalu kompleks → pecah ke beberapa test case sederhana
- Test membutuhkan mock → identifikasi mock yang diperlukan
- Test membutuhkan data seed → definisikan data seed

## ERROR HANDLING
- Tidak yakin expected output → definisikan dulu, jangan tebak
- Test case terlalu banyak → prioritaskan yang paling kritis
- Test tidak bisa ditulis → identifikasi kenapa, mungkin perlu refactor

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Test menulis setelah kode → test menuruti kode, bukan kontrak
- ❌ Test trivial → "test 1 == 1" bukan test
- ❌ Skip test design → "nanti aja" = test tidak terstruktur
- ❌ Hanya test happy path → negative + edge juga penting
- ❌ Test tanpa assertion yang bisa gagal → test yang selalu pass = bukan test
