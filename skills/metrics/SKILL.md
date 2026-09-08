---
description: METRICS — kesehatan project terukur: kompleksitas, cakupan test, utang teknis, kecepatan pipeline. Angka untuk keputusan, bukan dekorasi.
---

# METRICS

"Kayaknya kode makin berantakan" bukan data. Ukur.

## KUMPULKAN (angka murah dulu, tanpa tool khusus)
1. **UKURAN** — jumlah file per folder, baris per file terbesar (WC), file > 300 baris = kandidat pecah.
2. **KOMPLEKSITAS** — fungsi > 50 baris, nesting > 3 tingkat, duplikasi (grep baris identik yang panjang).
3. **TEST** — jumlah kasus, rasio file kode : file test, test yang terakhir ditambahkan kapan.
4. **UTANG** — temuan audit tersisa (P2/P3), TODO/FIXME terbuka, `git log` area terpanjang tanpa sentuhan.
5. **PIPELINE** — durasi self-test, jumlah putaran fix rata-rata (dari session-log).

## BACA
- File terbesar + fungsi terpanjang = hotspot maintainability berikutnya.
- Rasio test turun + fitur naik = risiko regresi naik. Ulang skill test-design.
- Utang P2/P3 naik 3 kali berturut → jadikan milestone khusus pembayaran utang.

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
- Angka tanpa PUTUSAN = laporan kosong. Angka harus memicu keputusan.
- Metrics jalan tiap kali /metrics dipanggil + otomatis di /roadmap sebagai dasar skor.
