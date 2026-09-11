---
description: CHANGELOG — validasi & generate entry CHANGELOG.md sinkron dengan VERSION + badge README. Jalankan saat rilis, bump versi, atau sebelum release workflow jalan.
---

# CHANGELOG

Rilis = bukti tertulis. VERSION, CHANGELOG, badge README, satu sumber: git tag.

## APA YANG DILAKUKAN
Membuat dan memvalidasi entry changelog yang sinkron dengan versi aktual project. Changelog = catatan resmi perubahan: apa yang berubah, kapan, dan mengapa.

## KAPAN WAJIB JALAN
1. **Sebelum rilis** — pastikan changelog lengkap dan sinkron
2. **Setelah bump versi** — update entry sesuai versi baru
3. **Saat release workflow** — validasi sinkronisasi
4. **User minta changelog** — generate dari commit history

## URUTAN KERJA

### 1. BACA COMMIT HISTORY
```bash
git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~30)..HEAD
```
Commit sejak tag terakhir.

### 2. KELOMPOKKAN PER TIPE
Mengikuti Keep a Changelog:
- **Added** — fitur baru
- **Fixed** — bug fix
- **Changed** — perubahan perilaku
- **Deprecated** — fitur yang akan dihapus
- **Removed** — fitur yang dihapus
- **Security** — perubahan keamanan

### 3. TENTUKAN VERSI
Tipe dominan → bump:
- Feature = MINOR (1.0.0 → 1.1.0)
- Fix = PATCH (1.0.0 → 1.0.1)
- Breaking change = MAJOR (1.0.0 → 2.0.0)

Update `VERSION` file.

### 4. TULIS ENTRY
Entry baru di atas, format sama dengan entry lama:
```
## [X.Y.Z] — YYYY-MM-DD
### Added
- deskripsi perubahan (kalimat aktif, tanpa nama file berlebihan)
```

### 5. SINKRON
Badge VERSION di README = file VERSION. Tidak sinkron = bad self-test.

### 6. SELF-TEST
`bash tests/self-test.sh` — badge & struktur terkunci.

## FORMAT ENTRY
```
## [X.Y.Z] — YYYY-MM-DD
### Added / Fixed / Changed / Removed
- teks pendek, kalimat aktif, tanpa nama file berlebihan
```

## GERBANG
- VERSION, CHANGELOG, badge README tidak sinkron = GAGAL, fix dulu
- Commit tanpa deskripsi → minta konteks dari user, jangan mengarang isi commit
- Rilis = tag baru setelah entry. Tanpa tag = belum rilis
- Entry tanpa referensi commit → tidak valid

## INTEGRASI PIPELINE
```
COMMIT → CHANGELOG ← posisi skill ini → VERSION SYNC → RELEASE
```
- Sebelum: commit history, perubahan kode
- Sesudah: version sync, release
- Berkaitan: `skill doc-full` (update README), `skill self-test` (validasi)

## EDGE CASE
- Tidak ada commit baru → tidak ada entry baru
- Commit deskripsi tidak jelas → minta konteks dari user
- Breaking change tapi tidak ada migration guide → catat, tambah warning
- Pre-release → catat sebagai [Unreleased]

## ERROR HANDLING
- Format tidak konsisten → luruskan format dulu, baru isi entry
- VERSION file tidak ada → buat baru
- Badge tidak cocok → hitung aktual, perbaiki angkanya

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Mengarang entry tanpa referensi commit → entry harus dilacak
- ❌ Mengabaikan breaking change → wajib dicatat + migration guide
- ❌ Entry terlalu teknis → tulis untuk user, bukan untuk developer
- ❌ Skip self-test → changelog harus valid
- ❌ Rilis tanpa tag → tag = tanda rilis resmi

## MASTERY — ALL-ROUNDER MAX
Changelog kelas atas:
- Keep a Changelog: Added/Changed/Fixed/Removed/Deprecated/Security — konsisten = bisa dipindai
- Satu entry = satu perubahan user-bisa-rasakan — internal refactoring tidak masuk (bukan urusan pembaca)
- Nomor versi + tanggal tiap rilis — changelog tanpa tanggal = arkeologi
- Versi = sumber tunggal (VERSION file), badge/docs mengikuti — dua sumber = pasti berkelahi
