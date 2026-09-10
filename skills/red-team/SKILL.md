---
description: RED-TEAM — serang hasil kerja sendiri sebelum user/penyerang melakukannya: input jahat, batas, penyalahgunaan, kegagalan berantai. Wajib untuk auth/pembayaran/data user/permukaan publik.
---

# RED-TEAM

Audit-full mengejar pola yang dikenal. Red-team berpikir seperti penyerang: pola baru tidak ada di daftar.

## APA YANG DILAKUKAN
Menguji keamanan dan ketahanan sistem dengan pola pikir penyerang: input jahat, batas ekstrem, penyalahgunaan, kegagalan berantai. Red-team = penetration testing internal.

## KAPAN WAJIB JALAN
1. **Auth / autentikasi** — login, register, session
2. **Pembayaran** — transaksi, kartu kredit
3. **Data pribadi user** — profil, preferensi, riwayat
4. **Endpoint publik** — accessible tanpa autentikasi
5. **Upload file** — user bisa upload
6. **Ekspor data** — download, API response

## SERANGAN STANDAR (jawab per baris di laporan)

### 1. INPUT JAHAT
- String kosong? 10 MB? unicode/emoji?
- SQL/HTML/shell injection?
- Null? Tipe salah? Array bukan string?

### 2. BATAS
- Berapa maksimal yang diterima?
- Apa terjadi melebihi?
- Rate limit ada?

### 3. PENYALAHGUNAAN
- Fungsi dipakai di luar niatnya?
- Akses objek orang lain (IDOR)?
- Parameter diputar?

### 4. KEGAGALAN BERANTAI
- Service A mati → B apa reaksi?
- Retry tanpa akhir?
- Data setengah tersimpan?

### 5. PENGECUALIAN TAK TERDUGA
- Concurrent sama-sama nulis?
- Jaringan putus di tengah?
- Jam di-mundur?

## CARA KERJA
1. Pilih permukaan serang dari perubahan (endpoint, form, file, cron)
2. Uji serius: tulis payload nyata, jalankan (bukan imajinasi). Bukti = output/exit code
3. Temuan valid → fixer; sertakan test permanen (skill test-design: blok NEGATIVE/EDGE)

## GERBANG
- "Kayaknya aman" dilarang. Uji atau tandai belum diuji
- Temuan P0/P1 dari red-team = gerbang keras, sama seperti audit
- Red-team WAJIB untuk permukaan publik; dilewati → laporan akhir WAJIB menyebutnya

## INTEGRASI PIPELINE
```
THREAT-MODEL → CODER → RED-TEAM ← posisi skill ini → FIX-FULL
                                    ↓
                              TEST-FULL (test permanen)
                              AUDIT-FULL (gabungan)
```
- Sebelum: threat-model (peta ancaman), coder (implementasi)
- Sesudah: fix-full (perbaikan), test-full (test permanen)
- Berkaitan: `skill threat-model` (peta ancaman sebelum bangun), `skill audit-full` (audit menyeluruh)

## EDGE CASE
- Tidak ada permukaan publik → red-team opsional, tapi tetap catat
- Serangan kompleks → pecah ke beberapa test case
- Temuan tidak bisa difix sekarang → catat sebagai known risk
- Third-party component → test dari sisi integrasi

## ERROR HANDLING
- Payload tidak bisa dijalankan → catat sebagai tebakan, tandai belum diuji
- Temuan tidak bisa difix → risk acceptance dengan user
- Red-team loop > 5 temuan → fokus P0/P1 dulu

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ "Kayaknya aman" → uji atau tandai belum diuji
- ❌ Skip red-team → penyerang tidak akan skip
- ❌ Red-team tanpa bukti → "kemungkinan bisa" bukan bukti
- ❌ Temuan P0/P1 diabaikan → gerbang keras
- ❌ Hanya test happy path → red-team = test unhappy path
