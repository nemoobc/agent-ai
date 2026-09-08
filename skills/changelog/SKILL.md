---
description: CHANGELOG — validasi & generate entry CHANGELOG.md sinkron dengan VERSION + badge README. Jalankan saat rilis, bump versi, atau sebelum release workflow jalan.
---

# CHANGELOG

Rilis = bukti tertulis. VERSION, CHANGELOG, badge README, satu sumber: git tag.

## URUTAN KERJA
1. **BACA** — `git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~30)..HEAD` — commit sejak tag terakhir.
2. **KELOMPOKKAN** — per tipe: Added / Fixed / Changed / Removed (Keep a Changelog).
3. **VERSI** — tipe dominan → bump: feature = MINOR, fix = PATCH, breaking = MAJOR. Update `VERSION` file.
4. **TULIS** — entry baru atas, format sama dengan entry lama. Bahasa user.
5. **SINKRON** — badge VERSION README = file VERSION. Tidak sinkron = bad self-test.
6. **SELF-TEST** — `bash tests/self-test.sh` — badge & struktur terkunci.
7. **LAPOR** — versi baru, jumlah entry, status self-test.

## FORMAT ENTRY
```
## [X.Y.Z] — YYYY-MM-DD
### Added / Fixed / Changed / Removed
- teks pendek, kalimat aktif, tanpa nama file berlebihan
```

## GERBANG
- VERSION, CHANGELOG, badge README tidak sinkron = GAGAL, fix dulu.
- Commit tanpa deskripsi → minta konteks dari user, jangan mengarang isi commit.
- Rilis = tag baru setelah entry. Tanpa tag = belum rilis.
