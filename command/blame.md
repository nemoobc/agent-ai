---
description: BLAME — ringkas git blame per file: siapa mengubah apa, kapan, pesan commit → konteks untuk memahami kode.
agent: dev
---
TUGAS: $ARGUMENTS

1. File target dari $ARGUMENTS. Bila kosong → file yang paling baru berubah (git log -1 --name-only).
2. `git blame <file>` → kelompokkan per commit/penulis: fungsi/baris kunci siapa yang menulis kapan + pesan commit (git log -1 <hash> --format=%s).
3. Ringkas: 1 baris per area berubah (file:baris — penulis — kapan — pesan commit). Tanpa menghakimi penulis.
4. Bila ada area tidak jelas → tawarkan: bedah baris itu dengan skill explain.
5. JANGAN mengubah kode — /blame untuk memahami.