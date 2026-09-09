---
description: THREAT-MODEL — peta ancaman sebelum bangun surface baru: aktor, aset, jalur serangan, mitigasi. Wajib untuk auth/pembayaran/data user/publik, sejalan dengan red-team.
---
# THREAT-MODEL

DEV panggil di fase BAYANG/GODOK bila menyentuh: auth, pembayaran, data user, endpoint publik, file upload, integrasi pihak ketiga. Red-team menguji SETELAH bangun; threat-model memetakan SEBELUM. Dua-duanya wajib, urutannya: model dulu, serang kemudian.

## FORMAT (maks 20 baris, tabel)
```
ASET    : apa yang dilindungi (data, sesi, uang, reputasi)
AKTOR   : siapa yang menyerang (anonim, user nakal, partner, bot)
JALUR   : bagaimana masuk (endpoint, file, dependency, human error)
DAMPAK  : P0 (data/duit) / P1 (akses) / P2 (spam/abuse) / P3 (kosmetik)
MITIGASI: kontrol konkret per jalur (validasi, batas rate,least-privilege, log)
SISA    : risiko yang diterima + siapa yang menyetujui (user)
```

## ATURAN
- Setiap jalur P0/P1 wajib punya mitigasi konkret atau masuk SISA dengan persetujuan user.
- Model ditulis SEBELUM koding — ditemukan saat audit = terlambat, catat sebagai pelajaran.
- Dependency luar (API, SDK) = jalur masuk juga; versi tak terkunci = temuan.
