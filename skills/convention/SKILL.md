---
description: CONVENTION — ekstrak & tegakkan konvensi repo: struktur, penamaan, gaya, alur git. Satu sumber kebenaran yang dipakai semua agent — konsistensi tanpa diingat-ingat.
---

# CONVENTION

Kode yang konsisten dibaca 10x lebih cepat. Konvensi tidak ditulis = tiap agent bikin aturannya sendiri.

## APA YANG DILAKUKAN
Mengekstrak dan menegakkan konvensi project: struktur folder, penamaan file/fungsi, gaya import, error handling, test naming, alur git. Convention = aturan tak tertulis yang dibuat tertulis.

## KAPAN WAJIB JALAN
1. **Boot sesi di project yang sudah jalan** — setelah skill scan
2. **Sebelum coder menulis file baru** — ikuti konvensi yang sudah ada
3. **Setelah melihat pola berulang** — yang belum tercatat → catat
4. **Sebelum deliver** — pastikan kode konsisten

## URUTAN KERJA

### 1. EKTRAK (dari kode yang sudah ada, bukan keinginan)
Pola yang perlu diekstrak:
- Struktur folder (src/, lib/, modules/)
- Penamaan file (camelCase, kebab-case, snake_case)
- Penamaan fungsi/variabel (singkat vs deskriptif)
- Gaya import (relative, alias, barrel export)
- Error handling (throw, Result type, error object)
- Test naming (describe/it, test/should)
- Alur git (branch naming, commit message format)

### 2. CATAT
Konvensi ke memori project: `.opencode/memory/conventions.md`
Buat baru bila belum ada. Format:
```
## <Area>
- <aturan> — <contoh baik / contoh buruk>
```

### 3. TEGAKKAN
Sebelum lapor: cek kode baru vs konvensi
- Pelanggaran = temuan P3 (kosmetik tapi konsistensi penting)
- File:baris bila melanggar
- Ulangi sampai konsisten

### 4. PERBARUI
Konvensi berubah dengan sengaja (bukan kebiasaan) → catat perubahannya + alasan

## FORMAT ENTRY conventions.md
```
## Struktur
- src/ untuk kode utama, tests/ untuk test — contoh: src/auth/, tests/auth.test.ts

## Penamaan
- file: kebab-case (user-profile.ts) — bukan camelCase
- fungsi: camelCase (getUserProfile) — bukan snake_case
- konstanta: SCREAMING_SNAKE (MAX_RETRY) — bukan camelCase

## Import
- relative untuk file sesama folder (./helper)
- alias @/ untuk cross-folder (@/lib/utils)
```

## GERBANG
- Konvensi dari "rasa" tanpa bukti kode = dilarang. Ekstrak dari file nyata, sebut contohnya
- Coder menulis pola baru yang melanggar konvensi tercatat → P3 + catat di laporan
- Konvensi yang sudah mati (tidak ada kode memakainya) → tandai, jangan dipertahankan mati-matian

## INTEGRASI PIPELINE
```
SCAN → CONVENTION ← posisi skill ini → CODER (ikuti konvensi)
                                          ↓
                                    AUDIT-FULL (cek konsistensi)
```
- Sebelum: scan (peta project), recall (konvensi lama)
- Sesudah: coder (ikuti konvensi), audit (cek konsistensi)
- Berkaitan: `skill scan` (peta project), `skill audit-full` (cek konsistensi)

## EDGE CASE
- Tidak ada konvensi yang jelas → buat dari kode yang ada, jangan impor dari project lain
- Konvensi bertentangan dengan best practice → catat konvensi + rekomendasi, biarkan user putuskan
- Monorepo → konvensi per package bila berbeda
- Multi-bahasa → konvensi per bahasa (JS ≠ Python)

## ERROR HANDLING
- Konvensi tidak tertulis → ekstrak dari kode yang ada
- Konvensi berubah tanpa pemberitahuan → update conventions.md
- Tidak yakin konvensi → baca kode yang sudah ada, ikuti pola

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Membuat konvensi tanpa ekstrak dari kode → konvensi impor = tidak relevan
- ❌ Skip ekstraksi → "sudah tahu" = ingatan bisa salah
- ❌ Melanggar konvensi sendiri → konsistensi = tanggung jawab semua
- ❌ Konvensi mati dipertahankan → delete, jangan archive
- ❌ Konvensi terlalu banyak → yang penting saja, jangan bikin buku

## MASTERY — ALL-ROUNDER MAX
Konvensi kelas atas:
- Tulis yang dipakai HARI INI, bukan yang diidealkan — konvensi impian = konvensi yang dilanggar diam-diam
- Tiap aturan ada alasannya (1 kalimat) — aturan tanpa alasan = dogma, dogma = ditolak anak baru
- Enforcement otomatis (linter/formatter/CI) — konvensi tanpa mesin penegak = saran
- Konvensi berubah = changelog + migrasi — perubahan diam-diam = konvensi dua versi hidup bersama
