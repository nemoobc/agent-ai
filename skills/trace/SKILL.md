---
description: TRACE — rantai bukti (HUKUM 11): setiap klaim di laporan wajib punya jalur ke bukti fisik (exit code, output test, file:baris). Klaim tanpa rantai = tidak boleh diucapkan.
---

# TRACE (HUKUM 11)

## APA YANG DILAKUKAN
Memverifikasi bahwa setiap klaim di laporan didukung oleh bukti fisik yang dapat diverifikasi. Trace = rantai bukti: klaim → bentuk bukti → sumber bukti → apa yang TIDAK dibuktikan.

## FORMAT RANTAI
```
KLAIM: "<pernyataan>"
BENTUK: [TEST|AUDIT|ANGKA|OUTPUT|FILE]
BUKTI : <exit code / file:baris / jumlah> → <perintah sumber>
SELAIN: (apa yang TIDAK dibuktikan — wajib ditulis, bukan disembunyikan)
```

## CARA JALAN

### 1. KUMPULKAN KLAIM
Sebelum lapor SELESAI: daftar semua klaim di draf laporan.

### 2. VERIFIKASI PER KLAIM
Tiap klaim: isi format rantai di atas. Tidak bisa isi BUKTI → klaim dihapus atau dites dulu.

### 3. TULIS SELAIN
SELAIN wajib ada: bagian yang tidak terbukti dinyatakan terang-terangan. Diam = bohong.

### 4. CEK RANTAI
Klaim tanpa rantai yang lolos ke user = pelanggaran HUKUM 11 → DEV tarik laporan, perbaiki.

## CONTOH RANTAI

```
KLAIM : "test 5/5 PASS"
BENTUK: TEST
BUKTI : exit 0 → `npm test` (output: 5 passed, 0 failed)
SELAIN: tidak membuktikan test mengcover semua edge case

KLAIM : "file auth.ts berubah"
BENTUK: FILE
BUKTI : `git diff --stat` → auth.ts (+15 -8)
SELAIN: tidak membuktikan perubahan memperbaiki bug

KLAIM : "audit CLEAN"
BENTUK: AUDIT
BUKTI : exit 0 → `bash skills/audit-full/run.sh .`
SELAIN: tidak membuktikan tidak ada vulnerability di dependency
```

## GERBANG
- Laporan SELESAI tanpa satu pun rantai bukti → ditolak
- "sepertinya jalan", "kayaknya aman" = bukan bukti — tes dulu, baru bicara
- SELAIN kosong → rantai tidak lengkap
- BUKTI tidak bisa diverifikasi → klaim tidak valid

## INTEGRASI PIPELINE
```
SEMUA KLAIM → TRACE ← posisi skill ini → LAPOR SELESAI
```
- Sebelum: semua klaim di laporan
- Sesudah: laporan dengan rantai bukti lengkap
- Berkaitan: `skill critique` (verifikasi klaim), `skill test-full` (bukti test), `skill audit-full` (bukti audit)

## EDGE CASE
- Klaim tidak bisa dibuktikan → hapus klaim dari laporan
- Bukti tidak tersedia → catat di SELAIN
- Bukti ambigu → klarifikasi dengan test/audit tambahan
- Klaim benar tapi bukti tidak ada → cari bukti, jangan klaim tanpa bukti

## ERROR HANDLING
- Tidak ada bukti → hapus klaim atau buktikan dulu
- Bukti tidak meyakinkan → cari bukti tambahan
- Rantai terlalu panjang → kompres, ambil yang paling kritis

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Klaim tanpa bukti → "sudah selesai" tanpa verifikasi
- ❌ SELAIN kosong → pastikan semua ketidakpastian tercatat
- ❌ Bukti dari "rasa" → exit code / file:baris = satu-satunya bukti
- ❌ Rantai tidak lengkap → klaim + bentuk + bukti + SELAIN harus utuh
- ❌ Mengabaikan SELAIN → diam = bohong
