---
description: SPEC — spesifikasi perilaku sebelum arsitektur: input, output, aturan, error, non-goal. Fitur ambigu = tangkap di sini, bukan di tengah koding. Dipanggil sebelum architect.
---

# SPEC

Arsitektur menjawab "bagaimana". Spec menjawab "APA yang harus terjadi". Tanpa spec, desain menebak.

## KAPAN
Fase MIKIR, sebelum imagine/architect — untuk fitur baru atau perilaku yang berubah besar.

## FORMAT (di plan, blok KONTEKS diperluas)
```
INPUT  : <data/perintah apa masuk, dari siapa>
OUTPUT : <hasil apa keluar, seperti apa bentuknya>
ATURAN : <validasi, batasan, hak akses, kondisi khusus>
ERROR  : <situasi gagal + perilaku yang benar saat gagal>
NON-GOAL: <yang SENGAJA tidak dikerjakan — batas anti scope creep>
```

## ATURAN
- Ambiguitas ditemukan di sini → tulis ASUMSI eksplisit di plan, lanjut kerja (jangan tanya kecuali HUKUM 5).
- NON-GOAL wajib ada — fitur tanpa batas = scope creep terjamin.
- Spec jadi bahan architect (desain) + test-design (kasus test) — satu sumber kebenaran.
- Perilaku tidak terdefinisi di spec → dilarang diimplementasi seadanya; tulis di plan, putuskan, baru kerja.

## GERBANG
- Spec kosong + fitur besar → architect DILARANG mulai.
- ERROR tanpa perilaku jelas = temuan P2 saat audit.
