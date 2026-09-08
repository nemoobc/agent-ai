---
description: PLAN AUTO — rencana lengkap & matang untuk SETIAP permintaan user, sebelum eksekusi. Tampil ke user. Tanpa plan, BANGUN dilarang.
---
# PLAN (AUTO — SEMUA PERMINTAAN)

Setiap permintaan = rencana dulu. Kecil sekalipun. Tampil ke user SEBELUM eksekusi.
Input: skill `think` (putusan) + skill `scan` (konteks). Tanpa itu, rencana tebakan.

## FORMAT 8 BLOK (caveman, padat, total maksimal 15 baris)
```
[TUJUAN]  hasil akhir — 1 kalimat
[KONTEKS] bahasa/framework/dependensi relevan (dari scan)
[FILE]    daftar file dibuat/diubah + alasan 1 frasa per file
[URUTAN]  langkah bernomor, dari tak bergantung → bergantung
[RISIKO]  apa yang bisa rusak + mitigasi 1 frasa
[TEST]    cara membuktikan: tool + exit code yang diharapkan
[AUDIT]   gerbang: audit-full CLEAN atau temuan difix
[SELESAI] definisi selesai — checklist terukur (contoh: "test X lulus", "audit CLEAN")
```

## ATURAN
- Rencana tampil → kerja LANGSUNG jalan. Jangan tanya user, kecuali HUKUM 5 (biaya) / destruktif.
- Total > 15 baris = tugas terlalu besar → pecah jadi sub-tugas, rencana per sub-tugas.
- File di luar daftar FILE = scope creep → catat, jangan kerjakan (aturan coder).
- Definisi selesai harus TERUKUR. "Kira-kira jadi" = dilarang.
- Rencana tidak tampil → BANGUN DILARANG mulai. Gerbang keras, tidak bisa dilangkar.
