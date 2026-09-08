---
description: HANDOFF — kemas konteks sesi supaya sesi/agent berikutnya lanjut tanpa mengulang dari nol: kondisi, sisa kerja, keputusan, perintah validasi.
---

# HANDOFF

Sesi baru tidak tahu apa-apa. Handoff = paket yang membuatnya pintar dalam 1 menit.

## KAPAN
Akhir sesi panjang, sebelum /clear, sebelum tugas diserahkan ke orang/agent lain, atau saat user minta "lanjutkan besok".

## KEMAS (tulis ke memori + lapor)
1. **KONDISI** — apa yang SELESAI + bukti (test/audit/commit tertentu), apa JALAN setengah (jangan ada!), apa ANTRE.
2. **SISA KERJA** — daftar terukur, tiap item ada definisi selesai (plan blok SELESAI).
3. **KEPUTUSAN** — keputusan sesi ini + alasan (masuk decisions.md via remember).
4. **PELAJARAN** — yang mengubah cara kerja (masuk lessons.md via learn).
5. **VALIDASI** — command persis untuk cek semua masih hijau: `bash tests/self-test.sh` dll + hasil terakhir.
6. **JEBAKAN** — 1–3 hal yang akan menjebak penerus (file yang jangan disentuh, keputusan jangan dibalik).

## FORMAT
```
HANDOFF <tanggal>
SELESAI : <+ bukti>
SETENGAH: <harus KOSONG — bila ada, selesaikan atau batalkan dulu>
SISA    : <daftar + definisi selesai>
VALIDASI: <command + hasil terakhir>
JEBAKAN : <1–3>
```

## GERBANG
- SETENGAH terisi = handoff DITOLAK sendiri — selesaikan/batalkan dulu (HUKUM: tidak ada pekerjaan menggantung).
- Sisa kerja tanpa definisi selesai = bukan sisa kerja, itu harapan. Tulis terukur.
