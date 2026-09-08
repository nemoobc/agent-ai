---
description: PR — siapkan pull request dari diff: ringkasan, perubahan, bukti test, checklist, judul konvensional. Siap tempel, bukan kerja setengah.
---

# PR

PR = kontrak yang dibaca orang lain. Judul + ringkasan + bukti. Tanpa itu = PR ditolak oleh reviewer.

## KAPAN
User minta buat PR, review PR, atau setelah fitur selesai & user bilang "siapkan PR".

## CARA
1. **BACA DIFF** — `git diff <base>...HEAD` (atau staged). Petakan: apa berubah, berapa baris per file.
2. **RINGKAS** — 1–3 kalimat: apa, kenapa, bagaimana. Bahasa user.
3. **PERUBAHAN** — daftar file + alasan 1 frasa (dari plan bila ada — rencana 8 blok tinggal dipakai ulang).
4. **BUKTI** — test & audit terakhir (exit code + angka). Merah? PR belum lahir — /fix dulu.
5. **JUDUL** — konvensional: `feat:` / `fix:` / `refactor:` / `docs:` + ringkas. Dari tipe perubahan dominan.
6. **CHECKLIST** — dari template `.github/PULL_REQUEST_TEMPLATE.md` bila ada; kalau tidak: test hijau, audit CLEAN, changelog sinkron (bila user-visible), a11y/red-team bila relevan.

## FORMAT
```
JUDUL : <tipe>: <ringkas>
RINGKASAN : <1–3 kalimat>
PERUBAHAN : <file + alasan, maks 8 baris>
BUKTI     : test PASS (N/N) • audit CLEAN • lint PASS
CHECKLIST : [x] test hijau [x] audit CLEAN [x] changelog [x] <relevan>
```

## GERBANG
- Test merah / audit temuan P0-P1 → PR DILARANG disiapkan, fix dulu.
- Judul non-konvensional atau tanpa ringkasan = belum PR, itu tempelan diff.
- Push/merge = aksi ke remote → hanya dengan perintah eksplisit user (HUKUM 5).