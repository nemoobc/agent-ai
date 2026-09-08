---
description: CONTEXT — lapor status konteks sesi: file yang sudah diserap, ringkasan aktif, saran compact/handoff sebelum kehilangan arah.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill context — audit konteks sesi: apa yang sudah dibaca & diserap (ringkasan), apa yang masih "aktif", apa yang mati.
2. Lapor blok [CTX]:
   DISERAP : <file yang sudah dirangkum, + lokasi kunci>
   AKTIF   : <yang sedang dipakai — minimal>
   MATI    : <yang harus dibuang dari konteks aktif>
   SARAN   : compact sekarang? handoff? lanjut (alasan 1 kalimat)
3. Konteks penuh → saran + tawaran: jalankan /handoff dulu (HUKUM 8).