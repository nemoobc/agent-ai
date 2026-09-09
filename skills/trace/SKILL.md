---
description: TRACE — rantai bukti (HUKUM 11): setiap klaim di laporan wajib punya jalur ke bukti fisik (exit code, output test, file:baris). Klaim tanpa rantai = tidak boleh diucapkan.
---
# TRACE (HUKUM 11)

## FORMAT RANTAI
```
KLAIM: "<pernyataan>"
BENTUK: [TEST|AUDIT|ANGKA|OUTPUT|FILE]
BUKTI : <exit code / file:baris / jumlah> → <perintah sumber>
SELAIN: (apa yang TIDAK dibuktikan — wajib ditulis, bukan disembunyikan)
```

## CARA JALAN
1. Sebelum lapor SELESAI: daftar semua klaim di draf laporan.
2. Tiap klaim: isi format rantai di atas. Tidak bisa isi BUKTI → klaim dihapus atau dites dulu.
3. SELAIN wajib ada: bagian yang tidak terbukti dinyatakan terang-terangan. Diam = bohong.
4. Klaim tanpa rantai yang lolos ke user = pelanggaran HUKUM 11 → DEV tarik laporan, perbaiki.

## GERBANG
- Laporan SELESAI tanpa satu pun rantai bukti → ditolak.
- "sepertinya jalan", "kayaknya aman" = bukan bukti — tes dulu, baru bicara.
