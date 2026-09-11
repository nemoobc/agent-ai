---
description: AUTO FIX FULL — formatter, lint --fix, lalu re-test otomatis sampai terlihat hasil. Dipakai FIXER di setiap putaran perbaikan. Script hanya permukaan — fix logis tetap tulis sendiri.
---

# FIX-FULL

Jalankan dari root project:
```bash
bash ~/.config/opencode/skill/fix-full/run.sh .
```
(atau terpasang di project: `bash .opencode/skill/fix-full/run.sh .`)

## APA YANG DILAKUKAN
Script otomatis menjalankan 3 tahap perbaikan permukaan secara berurutan:

| Tahap | Tool | Target |
|---|---|---|
| 1. Format | prettier / black / gofmt / rustfmt | Gaya kode konsisten |
| 2. Lint Fix | eslint --fix / ruff --fix / clippy --fix | Masalah yang bisa di-auto-fix |
| 3. Re-test | test-full (otomatis) | Pastikan fix tidak menambah regresi |

Script hanya menangani masalah format & lint yang bisa di-fix otomatis. **Fix logis (bisnis logic) tetap harus kamu tulis sendiri** — script tidak mengubah perilaku kode.

## EXIT CODE & GERBANG

| Exit | Arti | Aksi |
|---|---|---|
| `0` | Semua bersih + test hijau | Lanjut ke audit |
| `1` | Ada yang masih gagal (lint error / test fail) | Baca output, fix manual, ulang |
| `2` | Script tidak ada / tidak terdeteksi | Fix manual sesuai stack project |

## KAPAN WAJIB JALAN
1. **Setelah setiap fix manual** — pastikan tidak ada regressi format
2. **Setelah coder menulis kode baru** — auto-format sebelum test
3. **Sebelum commit** — bersihkan code style dulu (bersama git-guard)
4. **Sebelum deliver** — kode harus bersih sebelum dikirim
5. **Sebelum PR** — PR dengan style issues = reviewing overhead

## CARA KERJA DETAIL

### Pre-condition
- Pastikan project punya minimal satu formatter/lint yang terkonfigurasi
- Script mendeteksi otomatis: prettier config, eslint config, pyproject.toml, .golangci.yml, dll

### Eksekusi
1. **FORMAT** — jalankan formatter sesuai stack. Exit ≠ 0 → catat file yang gagal, lanjut
2. **LINT --FIX** — jalankan lint dengan auto-fix. Catat yang tidak bisa di-fix otomatis
3. **RE-TEST** — jalankan `test-full`. Merah = ada yang rusak dari formatting → rollback

### Post-condition
- Semua file sudah ter-format sesuai konvensi project
- Semua auto-fixable lint issues sudah tertangani
- Test masih hijau (tidak ada regresi dari formatting)

## OUTPUT WAJIB
```
FIX-FULL: format ✓ (X file) → lint ✓ (Y auto-fix) → test ✓ (N/N PASS)
```
Atau bila gagal:
```
FIX-FULL: format ✓ → lint ✗ (Z issues manual) → test ✗ (M/M FAIL)
```

## INTEGRASI PIPELINE
```
BANGUN → FIX-FULL ← posisi skill ini
              ↓
         TEST-FULL → AUDIT-FULL → CRITIQUE
              ↑
         debug (bila bug)
         fix manual (bila logic error)
```
- Sebelum: coder menulis kode, atau fixer menulis fix manual
- Sesudah: test-full otomatis, lalu audit-full
- Berkaitan: `skill git-guard` (pre-commit), `skill clean` (artifacts)

## EDGE CASE
- Project tanpa formatter → catat di SELAIN, format manual sesuai konvensi
- Formatter konflik dengan lint rules → prioritaskan lint rules, catat
- Fix-full loop: format → test merah → format ulang → loop → 3x gagal = STOP, fix manual
- Monorepo → script jalankan di root, deteksi config per package

## ERROR HANDLING
- Formatter belum terpasang → exit dengan pesan, rekomendasi install
- Lint config corrupt → revert ke default, catat
- Test merah SETELAH format → rollback format dulu, fix logic, baru format ulang
- Auto-fix mengubah perilaku (jarang tapi mungkin) → test harus menangkap

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Menganggap fix-full = selesai → script hanya permukaan, logic tetap perlu review manual
- ❌ Skip re-test setelah format → formatting bisa merusak syntax (terutama template languages)
- ❌ Mengulangi fix-full tanpa memperbaiki root cause → loop = tanda masalah lebih dalam
- ❌ Melaporkan "sudah fix" tanpa menjalankan script → exit code = satu-satunya bukti
- ❌ Menggunakan fix-full untuk fix logic → script hanya format + lint, bukan fixer

## MASTERY — ALL-ROUNDER MAX
Fix kelas atas:
- Gagal dulu (test merah) → fix → hijau — fix tanpa test merah = belum bukti apa-apa
- Diff minimal: satu fix = satu commit = satu alasan — campur refactor = review mustahil
- Fix akar bukan gejala: patch di tempat keluhan ≠ perbaikan di tempat penyakit
- Post-fix: cari pola sama di codebase — bug jarangan sendirian
