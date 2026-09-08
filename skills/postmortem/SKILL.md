---
description: POSTMORTEM — bedah insiden/gagal: garis waktu, akar masalah, dampak, aksi pencegahan permanen. Tanpa menyalahkan. Wajib setelah gagal keras atau data rusak.
---

# POSTMORTEM

Gagal = data. Bedah dulu, baru lanjut. Yang tidak ditulis akan terulang.

## KAPAN
Tugas GAGAL keras (gerbang tidak bisa dilalui), data rusak/hilang, regresi produksi, atau bug yang lolos test lama sampai ke user.

## FORMAT
```
## POSTMORTEM: <judul> — <tanggal>
GARIS WAKTU : <detik/menit/langkah — kapan mulai sampai ketahuan>
DAMPAK      : <apa yang rusak, seberapa luas, angka>
AKAR        : <sebab utama — teknik, bukan orang>
MENGAPA LOLOS: <kenapa test/audit tidak menangkap>
AKSI        : [x] fix sekarang → [x] test regresi → [x] pencegahan permanen (gerbang/skill/aturan)
PELAJARAN   : 1 baris → masuk lessons.md (skill learn)
```

## ATURAN
- Tanpa menyalahkan orang. Bedah sistem, bukan pribadi.
- AKSI tanpa perubahan konkret = dilarang. "Lebih teliti" dilarang.
- MENGAPA LOLOS wajib dijawab — kalau tidak, gerbang yang sama akan bolong lagi.
- Regresi dari postmortem WAJIB punya test permanen (skill test-design: blok REGRESSION).
