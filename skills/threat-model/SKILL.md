---
description: THREAT-MODEL — peta ancaman sebelum bangun surface baru: aktor, aset, jalur serangan, mitigasi. Wajib untuk auth/pembayaran/data user/publik, sejalan dengan red-team.
---

# THREAT-MODEL

DEV panggil di fase BAYANG/GODOK bila menyentuh: auth, pembayaran, data user, endpoint publik, file upload, integrasi pihak ketiga. Red-team menguji SETELAH bangun; threat-model memetakan SEBELUM. Dua-duanya wajib, urutannya: model dulu, serang kemudian.

## APA YANG DILAKUKAN
Membuat peta ancaman keamanan sebelum kode ditulis. Threat-model = detektif sebelum kejahatan: memetakan siapa penyerang, apa target, bagaimana cara masuk.

## KAPAN WAJIB JALAN
1. **Auth / autentikasi** — login, register, session management
2. **Pembayaran** — transaksi, kartu kredit, invoice
3. **Data user pribadi** — profil, preferensi, riwayat
4. **Endpoint publik** — accessible tanpa autentikasi
5. **File upload** — user bisa upload file
6. **Integrasi eksternal** — API pihak ketiga, webhook

## FORMAT (maks 20 baris, tabel)
```
ASET    : apa yang dilindungi (data, sesi, uang, reputasi)
AKTOR   : siapa yang menyerang (anonim, user nakal, partner, bot)
JALUR   : bagaimana masuk (endpoint, file, dependency, human error)
DAMPAK  : P0 (data/duit) / P1 (akses) / P2 (spam/abuse) / P3 (kosmetik)
MITIGASI: kontrol konkret per jalur (validasi, batas rate, least-privilege, log)
SISA    : risiko yang diterima + siapa yang menyetujui (user)
```

## CARA KERJA

### 1. IDENTIFIKASI ASET
- Apa yang dilindungi? (data, uang, reputasi, akses)
- Seberapa berharga? (P0-P3)

### 2. IDENTIFIKASI AKTOR
- Siapa yang mungkin menyerang? (anonim, user nakal, bot, insider)
- Motivasinya apa? (untung, iseng, kompetitor)

### 3. IDENTIFIKASI JALUR
- Endpoint mana yang bisa diakses?
- Input apa yang bisa dimanipulatisi?
- Dependency apa yang punya vulnerability?

### 4. ESTIMASI DAMPAK
- P0: data/duang hilang → dampak bisnis langsung
- P1: akses tidak sah → kompromi akun
- P2: spam/abuse → ganggu service
- P3: kosmetik → tidak ada dampak nyata

### 5. TULIS MITIGASI
Per jalur: kontrol konkret yang mencegah serangan.

### 6. DOKUMENTASI SISA
Risiko yang diterima + siapa yang menyetujui.

## ATURAN
- Setiap jalur P0/P1 wajib punya mitigasi konkret atau masuk SISA dengan persetujuan user
- Model ditulis SEBELUM koding — ditemukan saat audit = terlambat, catat sebagai pelajaran
- Dependency luar (API, SDK) = jalur masuk juga; versi tak terkunci = temuan

## INTEGRASI PIPELINE
```
THINK → THREAT-MODEL ← posisi skill ini → ARCHITECT → CODER → RED-TEAM
```
- Sebelum: think (analisa), spec (spesifikasi)
- Sesudah: architect (desain mitigasi), coder (implementasi), red-team (pengujian)
- Berkaitan: `skill red-team` (pengujian setelah bangun), `skill audit-full` (audit keamanan)

## EDGE CASE
- Tidak ada ancaman teridentifikasi → catat "tidak ada ancaman diketahui" + dasar
- Ancaman terlalu banyak → prioritas P0 dulu, P1/P3 bisa ditunda
- Ancaman dari pihak ketiga → dokumentasi, tidak bisa dikontrol langsung
- Model usang → update saat arsitektur berubah

## ERROR HANDLING
- Tidak yakin ada ancaman → konsultasi dengan red-team
- Mitigasi terlalu mahal → diskusikan dengan user, risiko diterima
- Model tidak lengkap → tambah saat audit menemukan celah baru

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip threat-model → "biasanya aman" = buta keamanan
- ❌ Threat-model setelah koding → terlambat, perlu redesign
- ❌ Mitigasi tanpa spesifikasi → "validasi input" tanpa detail = tidak berguna
- ❌ Mengabaikan P0/P1 → P0/P1 harus punya mitigasi atau disetujui user
- ❌ Threat-model statis → update saat arsitektur berubah
