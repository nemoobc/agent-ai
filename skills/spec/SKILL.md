---
description: SPEC — spesifikasi perilaku sebelum arsitektur: input, output, aturan, error, non-goal. Fitur ambigu = tangkap di sini, bukan di tengah koding. Dipanggil sebelum architect.
---

# SPEC

Arsitektur menjawab "bagaimana". Spec menjawab "APA yang harus terjadi". Tanpa spec, desain menebak.

## APA YANG DILAKUKAN
Mendefinisikan spesifikasi perilaku sistem sebelum desain arsitektur: input, output, aturan, error handling, non-goal. Spec = kontrak perilaku: apa yang harus terjadi, bukan bagaimana.

## KAPAN WAJIB JALAN
1. **Fitur baru** — sebelum architect mendesain
2. **Perilaku berubah besar** — spesifikasi baru diperlukan
3. **Ambiguitas ditemukan** — tangkap di sini, bukan di tengah koding
4. **Integrasi system** — definisikan kontrak antar sistem

## FORMAT (di plan, blok KONTEKS diperluas)
```
INPUT  : <data/perintah apa masuk, dari siapa>
OUTPUT : <hasil apa keluar, seperti apa bentuknya>
ATURAN : <validasi, batasan, hak akses, kondisi khusus>
ERROR  : <situasi gagal + perilaku yang benar saat gagal>
NON-GOAL: <yang SENGAJA tidak dikerjakan — batas anti scope creep>
```

## ATURAN
- Ambiguitas ditemukan di sini → tulis ASUMSI eksplisit di plan, lanjut kerja (jangan tanya kecuali HUKUM 5)
- NON-GOAL wajib ada — fitur tanpa batas = scope creep terjamin
- Spec jadi bahan architect (desain) + test-design (kasus test) — satu sumber kebenaran
- Perilaku tidak terdefinisi di spec → dilarang diimplementasi seadanya; tulis di plan, putuskan, baru kerja

## GERBANG
- Spec kosong + fitur besar → architect DILARANG mulai
- ERROR tanpa perilaku jelas = temuan P2 saat audit
- NON-GOAL kosong → scope creep terjamin

## INTEGRASI PIPELINE
```
THINK → SPEC ← posisi skill ini → IMAGINE → ARCHITECT → CODER → TEST-DESIGN
```
- Sebelum: think (analisa masalah)
- Sesudah: imagine (visualisasi), architect (desain), coder (implementasi)
- Berkaitan: `skill think` (keputusan), `skill api-design` (kontrak API), `skill test-design` (kasus test)

## EDGE CASE
- Spec terlalu detail → cukup untuk implementasi, jangan novel
- Spec terlalu kabur → tambah detail untuk area kritis
- Spec berubah selama implementasi → update spec, jangan diam
- Spec dari user → verifikasi dengan think, pastikan bisa diimplementasi

## ERROR HANDLING
- Spec tidak lengkap → tambah yang kurang, jangan mulai koding
- Spec konflik dengan constraint → diskusikan dengan user
- Spec tidak bisa diuji → tambah success criteria yang terukur

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip spec → "langsung coding" = desain tanpa fondasi
- ❌ Spec tanpa NON-GOAL → scope creep terjamin
- ❌ Spec tanpa ERROR handling → error handling = afterthought
- ❌ Spec tidak bisa diuji → "berhasil" harus terdefinisi
- ❌ Spec statis → update saat kebutuhan berubah

## MASTERY — ALL-ROUNDER MAX
Spesifikasi kelas atas:
- Format baku: input/output/aturan/error/non-goal — non-goal MELINDUNGI dari scope creep
- Contoh konkret > definisi abstrak — 3 contoh input→output mengunci perilaku
- Aturan error eksplisit: apa yang terjadi saat input salah — diam di spec = bug di produksi
- Spec berubah? versi + alasan — bukan diam-diameter
