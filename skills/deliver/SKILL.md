---
description: DELIVER — jalur serah kerja tanpa git: zip → upload tmpfiles.org → link. Dipakai saat user melarang commit/push. Secret dilarang ikut. Script run.sh otomatis.
---

# DELIVER

User bilang "jangan commit/push, upload aja" → skill ini.

## JALANKAN
```bash
bash skills/deliver/run.sh            # zip repo (tanpa .git) → upload tmpfiles.org → print link
bash skills/deliver/run.sh 72         # hidup 72 jam (default 24)
```

## APA YANG DILAKUKAN
Membuat arsip project (zip) tanpa direktori .git, mengunggah ke tmpfiles.org, dan memberikan link download. Tanpa perintah eksplisit user → DILARANG upload apa pun.

## URUTAN KERJA

### 1. PRE-CONDITION
- User menginstruksikan "jangan commit/push, upload aja"
- Project sudah dalam kondisi SELESAI (semua gerbang hijau)
- Tidak ada secret yang akan ikut ter-zip

### 2. PERSIAPAN ZIP
-扫 sweep file yang akan di-zip
- Exclude: `.git/`, `.env`, `node_modules/`, `__pycache__/`, `*.log`, secret patterns
- Termasuk: semua kode sumber, config, dokumen, test

### 3. SECRET CHECK (run.sh otomatis)
- Scan pola secret: API key, token, private key, password
- Ketemu → BATAL, lapor file yang kena
- Tidak ada secret → lanjut upload

### 4. UPLOAD
- Buat zip → upload ke tmpfiles.org
- Dapat link → cetak ke user
- Default TTL: 24 jam (bisa diatur via argumen)

### 5. POST-CONDITION
- Link diberikan ke user
- Ukuran zip + jumlah file dilaporkan
- Reminder: hapus dari tmpfiles bila perlu

## OUTPUT FORMAT
```
DELIVER:
UKURAN : X MB, Y file
LINK   : https://tmpfiles.org/dl/...
TTL    : Z jam
HAPUS  : hapus dari tmpfiles bila sudah tidak perlu
```

## GERBANG
- Tanpa perintah eksplisit user → DILARANG upload apa pun (HUKUM 5: aksi keluar)
- Secret dilarang ikut: run.sh cek pola secret dulu; ketemu → BATAL, lapor file kena
- Zip dibuat dari isi kerja saat itu (termasuk perubahan belum di-commit)
- Lapor: ukuran zip + jumlah file + link + "hapus dari tmpfiles bila perlu"
- Upload GAGAL → retry 1x, masih gagal → lapor ke user dengan opsi alternatif

## INTEGRASI PIPELINE
```
SELESAI (semua gerbang hijau) → DELIVER ← posisi skill ini
                                     ↓
                               LINK ke user
```
- Sebelum: semua gerbang hijau (test, audit, critique)
- Sesudah: user terima link, reminder hapus bila perlu
- Berkaitan: `skill clean` (bersihkan sebelum zip), `skill git-guard` (pastikan tidak ada secret di staged)

## EDGE CASE
- Project sangat besar (>100MB) → kompres lebih agresif, exclude lebih banyak
- tmpfiles.org down → retry, atau kasih alternatif (zip lokal)
- User minta password-protection → catat opsi, keputusan user
- Multi-part project → satu zip, atau link terpisah

## ERROR HANDLING
- Upload gagal → retry 1x, lalu kasih zip lokal
- Secret terdeteksi → BATAL total, lapor file, minta user fix
- Zip corrupt → buat ulang, verifikasi bisa di-extract
- Network error → kasih zip lokal sebagai alternatif

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Upload tanpa perintah user → aksi keluar = HUKUM 5
- ❌ Skip secret check → secret di zip = keamanan bocor
- ❌ Upload file yang seharusnya tidak di-zip → .env, secret, credential
- ❌ Lupa reminder hapus → data sensitive di public link
- ❌ Mengarang ukuran/jumlah file → lapor angka aktual
