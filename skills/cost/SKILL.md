---
description: COST — estimasi biaya/token sebelum aksi berbiaya (API berbayar, LLM call, cloud service). Wajib sebelum aksi berbiaya — HUKUM 5. Tanpa angka = tidak jalan.
---

# COST

HUKUM 5: aksi berbiaya = BERHENTI, tanya user. Skill ini bikin pertanyaan itu bawa angka, bukan perasaan.

## APA YANG DILAKUKAN
Mengestimasi biaya aktual sebelum aksi berbiaya dilakukan. Cost = kalkulator realistis: angka dari sumber, bukan perkiraan.

## KAPAN WAJIB JALAN
1. **LLM call eksternal** — OpenAI, Anthropic, Google API
2. **API berbayar** — Stripe, Twilio, SendGrid, dll
3. **Cloud service** — AWS, GCP, Azure resource baru
4. **SaaS baru** — tool berlangganan
5. **Batch besar** — operasi yang menghasilkan banyak output/biaya
6. **Tugas > 10 file** — bisa memakan waktu lama

## CARA (≤ 6 langkah, laporan ≤ 15 baris)

### 1. PETA
Aksi → sumber biaya: API X, token, storage, compute

### 2. SUMBER ANGKA
Cari di repo dulu: config, docs, endpoint, harga di README.
Dilarang mengarang angka tanpa sumber.
```
SUMBER: pricing.md baris 45 → $0.002 per 1K tokens
```

### 3. ANGKA
Volume: jumlah call, token per call, frekuensi per hari/bulan

### 4. SKALA
Terbaik / wajar / terburuk, dalam unit biaya:
```
TERBAIK:  $0.50 (500K tokens, batch optimal)
WAJAR  :  $2.00 (1M tokens, standard)
TERBURUK: $8.00 (4M tokens, retry tinggi)
```

### 5. ALTERNATIF
Cek dulu resource yang sudah ada di repo/config.
Yang sudah ada dipakai dulu. Alternatif termurah dicatat.

### 6. STOP
Lapor angka → tunggu keputusan user. Tanpa konfirmasi = TIDAK JALAN.

## FORMAT LAPORAN
```
COST   : <aksi>
SUMBER : <file repo / docs>  BUKTI: <angka dari sumber>
SKALA  : terbaik X / wajar Y / terburuk Z (unit)
ALTERN : <pakai yang sudah ada> / <alternatif termurah>
PUTUSAN: BUTUH KONFIRMASI USER — <1 kalimat, bawa angka>
```

## GERBANG
- Estimasi tanpa sumber = DILARANG. Cari dulu, tulis sumbernya
- "Kecil kemungkinan besar" dilarang. Angka atau tidak jalan
- User tidak minta LLM/cloud + resource repo cukup → pakai yang ada, lapor sumbernya
- HUKUM 5 tetap: tanpa konfirmasi user = TIDAK JALAN

## INTEGRASI PIPELINE
```
AKSI BERBIAYA → COST ← posisi skill ini → USER PUTUSKAN → EKSEKUSI
```
- Sebelum: identifikasi aksi yang membutuhkan biaya
- Sesudah: user putuskan, eksekusi atau batalkan
- Berkaitan: `skill research` (cari harga), `skill monitor` (pantau penggunaan)

## EDGE CASE
- Tidak ada pricing info → riset dulu (skill research), baru estimate
- Harga berubah → cek sumber terbaru
- Biaya terlalu kecil (< $0.01) → catat, tapi tetap laporkan
- Free tier tersedia → gunakan, catat limit

## ERROR HANDLING
- Sumber tidak ditemukan → riset dulu, jangan mengarang
- Angka tidak pasti → berikan range, jangan titik tunggal
- User tidak merespons → jangan lanjut aksi berbiaya

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Estimasi tanpa sumber → "kira-kira $5" tanpa dasar = bohong
- ❌ Skip cost → aksi berbiaya tanpa konfirmasi = HUKUM 5 dilanggar
- ❌ Mengabaikan alternatif → yang sudah ada harus dipakai dulu
- ❌ Over-estimate → user takut padahal biayanya kecil
- ❌ Under-estimate → user terkejut saat tagihan datang

## MASTERY — ALL-ROUNDER MAX
Cost kelas atas:
- Estimasi = harga unit × volume + buffer risiko — satu angka tanpa rumus = tebakan berdasi
- Sumber harga bertanggal (halaman pricing + tanggal akses) — harga cloud berubah diam-diam
- Alternatif selalu dibandingkan (self-host vs SaaS vs plan) — opsi tunggal = keputusan tercuri
- Biaya tersembunyi: egress + storage + idle + support — harga iklan itu umpan
