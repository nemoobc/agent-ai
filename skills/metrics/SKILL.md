---
description: METRICS — kesehatan project terukur: kompleksitas, cakupan test, utang teknis, kecepatan pipeline. Angka untuk keputusan, bukan dekorasi.
---

# METRICS

"Kayaknya kode makin berantakan" bukan data. Ukur.

## APA YANG DILAKUKAN
Mengumpulkan dan menganalisis metrik project untuk pengambilan keputusan berbasis data. Metrics = dasbor kesehatan project: angka, bukan opini.

## KAPAN WAJIB JALAN
1. **User tanya "gimana kondisi project?"** — kasih angka
2. **Sebelum milestone besar** — ukur dulu, baru rencanakan
3. **Setelah sprint/phase** — evaluasi dengan angka
4. **Saat /metrics dipanggil** — jalankan otomatis
5. **Sebelum roadmap** — dasarkan di data

## KUMPULKAN (angka murah dulu, tanpa tool khusus)

### 1. UKURAN
- Jumlah file per folder
- Baris per file terbesar (WC)
- File > 300 baris = kandidat pecah

### 2. KOMPLEKSITAS
- Fungsi > 50 baris
- Nesting > 3 tingkat
- Duplikasi (grep baris identik yang panjang)

### 3. TEST
- Jumlah kasus test
- Rasio file kode : file test
- Test yang terakhir ditambahkan kapan

### 4. UTANG
- Temuan audit tersisa (P2/P3)
- TODO/FIXME terbuka
- `git log` area terpanjang tanpa sentuhan

### 5. PIPELINE
- Durasi self-test
- Jumlah putaran fix rata-rata (dari session-log)

## BACA HASIL
- File terbesar + fungsi terpanjang = hotspot maintainability berikutnya
- Rasio test turun + fitur naik = risiko regresi naik. Ulang skill test-design
- Utang P2/P3 naik 3 kali berturut → jadikan milestone khusus pembayaran utang

## FORMAT LAPORAN
```
METRICS  : <tanggal>
UKURAN   : X file, Y baris, file terbesar Z baris
KOMPLEKS : F fungsi > 50 baris, N nesting dalam, D duplikasi
TEST     : T kasus, rasio 1 test : R kode
UTANG    : P2/P3 tersisa, TODO terbuka
PUTUSAN  : <1–3 aksi konkret berdasar angka>
```

## GERBANG
- Angka tanpa PUTUSAN = laporan kosong. Angka harus memicu keputusan
- Metrics jalan tiap kali /metrics dipanggil + otomatis di /roadmap sebagai dasar skor

## INTEGRASI PIPELINE
```
METRICS ← posisi skill ini → ESTIMATE (gunakan angka)
                                ↓
                           MILESTONE (rencana berbasis data)
                           ROADMAP (prioritas berbasis angka)
```
- Sebelum: scan (peta project), test-full (angka test)
- Sesudah: estimate (skala), milestone (pecahan), roadmap (prioritas)
- Berkaitan: `skill scan` (peta), `skill coverage` (gap test), `skill test-full` (angka test)

## EDGE Case
- Project sangat kecil → metrics ringkas saja
- Project sangat besar → prioritaskan metrik paling berdampak
- Metrics berubah drastis → investigasi perubahan
- Tidak ada tool metrics → manual dengan grep + wc

## ERROR HANDLING
- Command metrics gagal → fallback ke manual
- Angka tidak masuk akal → verifikasi ulang
- Metrics timeout → skip metric yang timeout, lanjut yang lain

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Metrics tanpa keputusan → angka tanpa aksi = dekorasi
- ❌ Over-engineering metrics → cukup yang penting saja
- ❌ Skip metrics → "kayaknya baik-baik aja" = tidak ada bukti
- ❌ Metrics sekali → harus berkala, bukan one-shot
- ❌ Mengabaikan trend → naik/turun lebih penting dari angka tunggal
