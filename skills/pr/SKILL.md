---
description: PR — siapkan pull request dari diff: ringkasan, perubahan, bukti test, checklist, judul konvensional. Siap tempel, bukan kerja setengah. Push = aksi ke remote.
---

# PR

PR = kontrak yang dibaca orang lain. Judul + ringkasan + bukti. Tanpa itu = PR ditolak oleh reviewer.

## APA YANG DILAKUKAN
Mempersiapkan pull request lengkap dari diff yang ada: ringkasan perubahan, bukti test, checklist, judul konvensional. PR = dokumen resmi perubahan kode.

## KAPAN WAJIB JALAN
1. **User minta buat PR** — persiapkan
2. **Fitur selesai** — user bilang "siapkan PR"
3. **Review PR** — user minta review
4. **Sebelum merge** — pastikan PR siap

## URUTAN KERJA

### 1. BACA DIFF
`git diff <base>...HEAD` (atau staged). Petakan: apa berubah, berapa baris per file.

### 2. RINGKAS
1–3 kalimat: apa, kenapa, bagaimana. Bahasa user.

### 3. PERUBAHAN
Daftar file + alasan 1 frasa (dari plan bila ada — rencana 8 blok tinggal dipakai ulang).

### 4. BUKTI
Test & audit terakhir (exit code + angka). Merah? PR belum lahir — /fix dulu.

### 5. JUDUL
Konvensional: `feat:` / `fix:` / `refactor:` / `docs:` + ringkas. Dari tipe perubahan dominan.

### 6. CHECKLIST
Dari template `.github/PULL_REQUEST_TEMPLATE.md` bila ada; kalau tidak:
- [x] test hijau
- [x] audit CLEAN
- [x] changelog sinkron (bila user-visible)
- [x] a11y/red-team bila relevan

## FORMAT
```
JUDUL : <tipe>: <ringkas>
RINGKASAN : <1–3 kalimat>
PERUBAHAN : <file + alasan, maks 8 baris>
BUKTI     : test PASS (N/N) • audit CLEAN • lint PASS
CHECKLIST : [x] test hijau [x] audit CLEAN [x] changelog [x] <relevan>
```

## GERBANG
- Test merah / audit temuan P0-P1 → PR DILARANG disiapkan, fix dulu
- Judul non-konvensional atau tanpa ringkasan = belum PR, itu tempelan diff
- Push/merge = aksi ke remote → hanya dengan perintah eksplisit user (HUKUM 5)

## INTEGRASI PIPELINE
```
KERJA SELESAI → PR ← posisi skill ini → REVIEW → MERGE
```
- Sebelum: kerja selesai, test hijau, audit CLEAN
- Sesudah: review, merge (dengan perintah user)
- Berkaitan: `skill review` (review PR), `skill git-guard` (pre-commit check)

## EDGE CASE
- PR tanpa test → tambah test dulu
- PR terlalu besar → pecah ke beberapa PR
- Konflik merge → resolve dulu, baru siapkan PR
- PR untuk hotfix → judul `hotfix:` + deskripsi insiden

## ERROR HANDLING
- Diff terlalu besar → pecah commit/PR
- Judul tidak cocok → perbaiki judul
- Test merah → fix dulu, baru PR

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ PR tanpa ringkasan → reviewer tidak tahu apa yang berubah
- ❌ PR tanpa test → tidak ada bukti aman
- ❌ Push tanpa perintah user → HUKUM 5
- ❌ PR terlalu besar → pecah, jangan dipaksa
- ❌ Judul asal → gunakan konvensi yang berlaku
