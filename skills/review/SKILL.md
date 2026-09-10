---
description: REVIEW — baca PR/branch/diff sebelum merge: konteks rencana, bereskan conflict, verifikasi test+audit, saran commit. Baca dulu, baru bicara.
---

# REVIEW

Baca dulu. Baru bicara.

## APA YANG DILAKUKAN
Mereview pull request, branch, atau diff sebelum merge: verifikasi perubahan, cek test+audit, identifikasi risiko, saran commit. Review = filter kualitas kedua.

## KAPAN WAJIB JALAN
1. **User minta review PR/branch/diff** — baca dan evaluasi
2. **Sebelum merge** — pastikan aman
3. **PR dari agent lain** — verifikasi hasil kerja
4. **User tanya "apakah ini aman?"** — review mendalam

## URUTAN KERJA

### 1. UKUR & PETAKAN
`git log --oneline -5`, `git diff <target>...HEAD --stat` — ukur skala perubahan.

### 2. BERESKAN KONFLIK
Bila ada conflict → checkout --theirs/--ours, merge manual, test ulang.

### 3. BACA DIFF
Kerangka: perubahan perilaku vs perubahan gaya.
- Perubahan perilaku → lebih berisiko, perlu test
- Perubahan gaya → lebih aman, perlu konsistensi

### 4. TEST + AUDIT
Skill `test-full` + `audit-full` (exit code dicatat).

### 5. VERIFIKASI KLAIM
Klaim tanpa bukti → tolak. `file:baris` WAJIB di laporan.

## FORMAT LAPORAN
```
REVIEW: <file/folder>
PREDIKSI MERGE: AMAN / RISIKO / GAGAL
HAMBATAN: <1–3 hambatan terbesar>
TEST    : PASS/FAIL + angka
AUDIT   : CLEAN / X temuan
SARAN COMMIT : <satu kalimat pesan>
```

## GERBANG
- Merge dilarang bila test merah, P0/P1 temuan, atau konflik belum beres
- User minta merge → command `/merge` (terpisah)
- Review tanpa membaca diff = tidak valid

## INTEGRASI PIPELINE
```
PR/BRANCH → REVIEW ← posisi skill ini → MERGE (dengan perintah user)
```
- Sebelum: PR/branch/diff tersedia
- Sesudah: merge (dengan perintah eksplisit user)
- Berkaitan: `skill test-full` (verifikasi test), `skill audit-full` (verifikasi audit)

## EDGE CASE
- PR sangat besar (>500 baris) → review bertahap, fokus file kritis
- Konflik merge → resolve dulu, baru review
- PR tanpa test → catat sebagai temuan, rekomendasikan tambah test
- PR untuk hotfix → review lebih cepat, fokus safety

## ERROR HANDLING
- Diff tidak bisa dibaca → catat di SELAIN
- Test merah → review belum valid, fix dulu
- Tidak yakin aman → konservatif: jangan merge

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Review tanpa membaca diff → "sepertinya aman" bukan review
- ❌ Skip test/audit → review harus lengkap
- ❌ Review terlalu cepat → baca perubahan dengan seksama
- ❌ Mengabaikan konflik → resolve dulu
- ❌ Review tanpa bukti → "file:baris" harus ada
