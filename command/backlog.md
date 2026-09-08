---
description: BACKLOG — antrian kerja terukur: tiap item punya definisi selesai + skor dampak×usaha + status. Sumber skill milestone & /roadmap.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill recall + baca `.opencode/backlog.md` bila ada, selain itu mulai baru.
2. Tambah item dari $ARGUMENTS: tiap item = judul + definisi selesai terukur + skor (dampak 1–5 × usaha 1–5 dibalik, gaya /roadmap) + sumber (user/audit/perf/metrics).
3. Tampilkan papan: ID | item | skor | definisi selesai | status (ANTRE/JALAN/SELESAI).
4. Bila user minta mulai → item teratas masuk pipeline penuh (skill milestone bila besar, plan 8 blok selalu).
5. Simpan papan kembali ke `.opencode/backlog.md` (project) atau memori global bila tidak ada project.

GERBANG: item tanpa definisi selesai = masuk paksa diberi definisi, atau ditolak.
