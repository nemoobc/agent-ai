---
description: Serah kerja tanpa git: zip → upload tmpfiles.org → link (dilarang commit/push)
agent: dev
---
TUGAS: /deliver [jam]

1. Guard dulu: bash skills/git-guard/run.sh — merah → BATAL, lapor temuan, tidak ada zip.
2. Zip: bash skills/deliver/run.sh ${1:-24} — buat arsip isi kerja (tanpa .git), upload tmpfiles.org.
3. Lapor: ukuran + jumlah file + link unduh + masa hidup + "hapus manual bila perlu".
4. DILARANG: git commit, git push, atau perintah git apa pun. User yang pegang repo.
GERBANG: tanpa permintaan eksplisit user → upload DILARANG (HUKUM 5).
