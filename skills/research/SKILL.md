---
description: RESEARCH — riset eksternal bersumber: versi library, API, harga, best practice. Webfetch/web_search. Tanpa sumber = dilarang diklaim. Data, bukan opini.
---

# RESEARCH

Pengetahuan kedaluwarsa = bug yang menunggu. Riset dulu, klaim belakangan.

## APA YANG DILAKUKAN
Mencari informasi terkini dari sumber eksternal: dokumentasi resmi, release notes, harga, best practice. Research = fondasi keputusan berbasis data, bukan hafalan.

## KAPAN WAJIB JALAN
1. **Versi library/API yang belum pernah dipakai** — cek compatibility
2. **Keputusan pemilihan tool/service** — bandingkan opsi
3. **Harga & limit** — masuk skill cost sebagai sumber angka
4. **Best practice yang diperdebatkan** — cek terkini, jangan hafalkan
5. **Breaking change** — cek changelog/migration guide

## URUTAN KERJA

### 1. SARING
Bisa dijawab dari repo/memori? → jangan riset. Mulai dari README, CHANGELOG, config.

### 2. CARI
web_search/web_fetch. Prioritas:
1. Docs resmi (official documentation)
2. Release notes (GitHub releases)
3. Issue tracker (known issues)
4. Blog/community (best practices)

### 3. CATAT SUMBER
Tiap klaim wajib pasangan URL + tanggal akses. Tanpa sumber = opini, bukan temuan.

### 4. COCOKKAN
Versi & instruksi cocokkan dengan kondisi project sekarang (versi runtime, framework).

### 5. SIMPAN
Temuan penting → plan/memori dengan sumbernya. Review sesi berikutnya pakai recall.

## FORMAT TEMUAN
```
RISET : <topik>
S1    : <klaim> — <URL> (<tanggal>)
S2    : <klaim> — <URL> (<tanggal>)
SIMPUL: <keputusan 1 kalimat + alasannya>
```

## GERBANG
- Klaim tanpa sumber = DILARANG masuk plan/laporan
- Dua sumber bertentangan → sebut keduanya + pilih yang resmi, catat risiko
- Riset berbiaya (API call) → lewat skill cost dulu (HUKUM 5)

## INTEGRASI PIPELINE
```
BUTUH INFO → RESEARCH ← posisi skill ini → KEPUTUSAN (think/plan)
```
- Sebelum: identifikasi kebutuhan informasi
- Sesudah: keputusan berbasis data
- Berkaitan: `skill cost` (estimasi biaya dari riset), `skill think` (keputusan dari riset)

## EDGE CASE
- Tidak ada docs resmi → gunakan source lain, catat keterbatasan
- Docs outdated → cari versi terbaru, verifikasi
- Dua sumber berbeda → pilih yang resmi, catat yang lain
- Riset butuh waktu lama → estimasi dulu, konfirmasi dengan user

## ERROR HANDLING
- Web search gagal → coba sumber alternatif
- URL tidak bisa diakses → cari mirror/cached version
- Informasi tidak ditemukan → catat "tidak ditemukan" + rencana alternatif

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Riset tanpa sumber → "kayaknya begitu" = opini
- ❌ Skip riset → "sudah tahu" = pengetahuan kedaluwarsa
- ❌ Mengabaikan sumber resmi → docs resmi > blog
- ❌ Riset terlalu lama → estimasi waktu, fokus ke yang dibutuhkan
- ❌ Mengarang sumber → fabrication = integrity violation
