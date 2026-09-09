---
description: DELIVER — jalur serah kerja tanpa git: zip → upload tmpfiles.org → link. Dipakai saat user melarang commit/push. Script run.sh otomatis.
---
# DELIVER

User bilang "jangan commit/push, upload aja" → skill ini.

## JALAN
```bash
bash skills/deliver/run.sh            # zip repo (tanpa .git) → upload tmpfiles.org → print link
bash skills/deliver/run.sh 72         # hidup 72 jam (default 24)
```

## GERBANG
- Tanpa perintah eksplisit user → DILARANG upload apa pun (HUKUM 5: aksi keluar).
- Secret dilarang ikut: run.sh cek pola secret dulu; ketemu → BATAL, lapor file kena.
- Zip dibuat dari isi kerja saat itu (termasuk perubahan belum di-commit).
- Lapor: ukuran zip + jumlah file + link + "hapus dari tmpfiles bila perlu".
