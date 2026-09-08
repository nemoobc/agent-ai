---
description: COST — estimasi biaya/token sebelum aksi berbiaya (API berbayar, LLM call, cloud service). Wajib sebelum aksi berbiaya — HUKUM 5.
---

# COST

HUKUM 5: aksi berbiaya = BERHENTI, tanya user. Skill ini bikin pertanyaan itu bawa angka, bukan perasaan.

## KAPAN
Sebelum: LLM call eksternal, API berbayar, cloud service, SaaS baru, batch besar, atau tugas > 10 file.

## CARA (≤ 6 langkah, laporan ≤ 15 baris)
1. **PETA** — aksi → sumber biaya (API X, token, storage, compute).
2. **SUMBER ANGKA** — cari di repo dulu: config, docs, endpoint, harga di README. Dilarang mengarang angka tanpa sumber.
3. **ANGKA** — volume: jumlah call, token per call, frekuensi per hari/bulan.
4. **SKALA** — terbaik / wajar / terburuk, dalam unit biaya.
5. **ALTERNATIF** — cek dulu resource yang sudah ada di repo/config. Yang sudah ada dipakai dulu. Alternatif termurah dicatat.
6. **STOP** — lapor angka → tunggu keputusan user. Tanpa konfirmasi = TIDAK JALAN.

## FORMAT LAPORAN
```
COST   : <aksi>
SUMBER : <file repo / docs>  BUKTI: <angka dari sumber>
SKALA  : terbaik X / wajar Y / terburuk Z (unit)
ALTERN : <pakai yang sudah ada> / <alternatif termurah>
PUTUSAN: BUTUH KONFIRMASI USER — <1 kalimat, bawa angka>
```

## GERBANG
- Estimasi tanpa sumber = DILARANG. Cari dulu, tulis sumbernya.
- "Kecil kemungkinan besar" dilarang. Angka atau tidak jalan.
- User tidak minta LLM/cloud + resource repo cukup → pakai yang ada, lapor sumbernya.
- HUKUM 5 tetap: tanpa konfirmasi user = TIDAK JALAN.
