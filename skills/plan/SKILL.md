---
description: PLAN AUTO — rencana lengkap & matang untuk SETIAP permintaan user, sebelum eksekusi. Tampil ke user. Tanpa plan, BANGUN dilarang. Format 8 blok.
---

# PLAN (AUTO — SEMUA PERMINTAAN)

Setiap permintaan = rencana dulu. Kecil sekalipun. Tampil ke user SEBELUM eksekusi.
Input: skill `think` (putusan) + skill `scan` (konteks). Tanpa itu, rencana tebakan.

## APA YANG DILAKUKAN
Membuat rencana eksekusi terstruktur untuk setiap permintaan user sebelum kode ditulis. Plan = peta jalan: semua orang tahu ke mana, bagaimana sampai di sana.

## KAPAN WAJIB JALAN
1. **Setiap permintaan user** — tanpa pengecualian
2. **Task architect** — rencana arsitektur
3. **Sebelum coder menulis kode** — coder butuh peta
4. **Sebelum refactoring** — rencana perubahan
5. **Sebelum hotfix** — rencana fix sempit

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
- Rencana tampil → kerja LANGSUNG jalan. Jangan tanya user, kecuali HUKUM 5 (biaya) / destruktif
- Total > 15 baris = tugas terlalu besar → pecah jadi sub-tugas, rencana per sub-tugas
- File di luar daftar FILE = scope creep → catat, jangan kerjakan (aturan coder)
- Definisi selesai harus TERUKUR. "Kira-kira jadi" = dilarang
- Rencana tidak tampil → BANGUN DILARANG mulai. Gerbang keras, tidak bisa dilangkar

## INTEGRASI PIPELINE
```
SCAN → THINK → IMAGINE → PLAN ← posisi skill ini → CODER → TEST → AUDIT
                ↑
           SPEC (spesifikasi)
           ESTIMATE (skala)
```
- Sebelum: scan (konteks), think (keputusan), imagine (visualisasi)
- Sesudah: coder (implementasi), test (pengujian), audit (keamanan)
- Berkaitan: `skill spec` (spesifikasi), `skill estimate` (skala), `skill milestone` (pecahan XL)

## EDGE CASE
- Tugas sangat sederhana (1 baris) → plan 3-5 baris cukup
- Tugas ambigu → plan dengan asumsi eksplisit
- Plan ditolak user → revisi, jangan diam
- Scope creep → catat di plan, jangan kerjakan

## ERROR HANDLING
- Think belum dilakukan → jalankan think dulu, baru plan
- Scan belum dilakukan → jalankan scan dulu, baru plan
- Plan terlalu panjang → pecah ke milestone

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip plan → "langsung coding" = kerja tanpa arah
- ❌ Plan tanpa think/scan → rencana tebakan
- ❌ Plan > 15 baris → pecah, jangan dipaksa
- ❌ Definisi selesai tidak terukur → "selesai" harus bisa diverifikasi
- ❌ File di luar plan → scope creep, catat tapi jangan kerjakan

## MASTERY — ALL-ROUNDER MAX
Rencana kelas atas:
- 8 blok wajib: masalah/spesifikasi/desain/urutan-kerja/test-design/estimasi/eksekusi/verifikasi — blok hilang = rencana bocor
- Urutan kerja = graf dependensi, bukan daftar selera — unit independen ditandai untuk paralel
- Tiap blok punya kriteria selesai yang bisa dites — "selesai" tanpa test = perasaan
- Estimasi dari angka file/tugas (S<10, M<30, L<60, XL>60) — tanpa angka = tebakan
