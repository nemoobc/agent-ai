---
description: AUTO TEST FULL — deteksi semua framework test di project (node/python/go/rust/php/make) dan jalankan semuanya. Wajib setiap selesai menulis/mengubah kode. Exit code menentukan gerbang: hijau = lanjut, merah = fix dulu.
---

# TEST-FULL

Jalankan dari root project:
```bash
bash ~/.config/opencode/skill/test-full/run.sh .
```
(atau terpasang di project: `bash .opencode/skill/test-full/run.sh .`)

## APA YANG DILAKUKAN
Script mendeteksi otomatis framework test yang ada di project lalu menjalankan semuanya tanpa intervensi manual:

| Bahasa/Framework | Deteksi via | Perintah Test |
|---|---|---|
| Node (Jest/Vitest/Mocha) | `package.json` | `npm test` / `npx jest` / `npx vitest` |
| Python (Pytest/Unittest) | `pyproject.toml` / `requirements.txt` | `pytest` / `python -m unittest` |
| Go | `go.mod` | `go test ./...` |
| Rust | `Cargo.toml` | `cargo test` |
| PHP (PHPUnit) | `composer.json` | `vendor/bin/phpunit` |
| Make | `Makefile` target `test` | `make test` |
| Ruby (RSpec/Minitest) | `Gemfile` | `bundle exec rspec` / `rake test` |

Script menjalankan semua yang cocok — bukan salah satu. Multi-framework = semua dijalankan berurutan.

## EXIT CODE & GERBANG

| Exit | Arti | Aksi |
|---|---|---|
| `0` | PASS semua suite | Lanjut ke fase berikutnya (audit) |
| `1` | ADA GAGAL | Baca output → serah ke agent FIXER. Jangan lapor gagal ke user dulu — fix dulu |
| `2` | TIDAK ADA TEST terdeteksi | Tulis test via CODER sebelum dianggap selesai. NO-TESTS = DILARANG lapor SELESAI |

## KAPAN WAJIB JALAN
1. **Setiap selesai menulis/mengubah kode** — tanpa pengecualian
2. **Setelah fix-full** — pastikan fix tidak menambah regresi baru
3. **Sebelum audit-full** — hijau dulu, baru audit
4. **Sebelum deliver/PR** — bukti hijau wajib ada
5. **Setelah hotfix** — hotfix tanpa test = kecelakaan menunggu

## OUTPUT WAJIB
Laporkan ringkas:
```
TEST: X/Y PASS — Z suite (node: A/B, python: C/D, ...)
```
- Jumlah suite yang dijalankan
- Total pass vs fail
- Per-framework breakdown bila multi-framework

## ERROR HANDLING
- Script tidak ada / exit ≠ 0/1/2 → catat di SELAIN, jangan mengarang angka test
- Test timeout → catat sebagai FAIL, bukan PASS
- Dependency test belum terpasang → exit 2, catat perintah install yang dibutuhkan
- Test yang di-skip (skip/pending) → hitung terpisah dari PASS dan FAIL

## INTEGRASI PIPELINE
```
SCAN → THINK → PLAN → [TEST-DESIGN] → BANGUN → TEST-FULL ← posisi skill ini
                                          ↑                ↓
                                    fix-full (merah)   AUDIT-FULL (hijau)
```
- Sebelum: skill `fix-full` bila merah
- Sesudah: skill `audit-full` bila hijau
- Berkaitan: skill `test-design` (kasus test dulu), skill `coverage` (gap test)

## EDGE CASE
- Project monorepo → script mendeteksi test di tiap package
- Test berbasis waktu (time-dependent) → bisa false fail, catat sebagai known issue
- Test yang butuh env khusus (database, API) → skip bila env tidak ada, catat
- Test paralel vs serial → ikut konfigurasi framework

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Menganggap test merah = "test-nya yang salah" → kode-lah yang salah, fix kode
- ❌ Skip test karena "tidak relevan" → catat skipped, jangan sembunyikan
- ❌ Hanya jalanin test yang berubah → jalankan SEMUA, partial test = bohong
- ❌ Mengarang angka test tanpa menjalankan script → exit code = satu-satunya sumber kebenaran

## MASTERY — ALL-ROUNDER MAX
Eksekusi test kelas atas:
- Urutan: unit → integrasi → e2e — gagal cepat di lapisan termurah
- -x/stop-on-fail saat debug, full suite saat verifikasi — jangan tanya "yang mana merah" tanpa data
- Snapshot test = kunci + review diff — snapshot berubah otomatis = kepercayaan mati
- Dokumentasikan kenapa test ini ada (nama = perilaku, bukan nama fungsi)
