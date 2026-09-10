---
description: DOC-FULL — sinkron README/CHANGELOG/dokumen saat perilaku berubah. Dipakai setelah perubahan yang user-visible. Dokumen bohong = bug.
---

# DOC-FULL

Wajib jalan bila perubahan kode mengubah perilaku, output, atau cara pakai. Tidak mengubah perilaku → skip.

## APA YANG DILAKUKAN
Menyinkronkan semua dokumentasi proyek agar sesuai dengan kode yang ada saat ini. Satu sumber kebenaran: kode = dokumen = versa. Berbohong = bug.

## KAPAN WAJIB JALAN
1. **Fitur baru ditambahkan** — user bisa lihat/perubahan cara pakai
2. **Perilaku berubah** — default, output format, error message, response code
3. **Command/endpoint baru** — tambah atau ubah interface publik
4. **Breaking change** — hapus/ubah cara lama → wajib catat + deprecation path
5. **Dependensi berubah** — yang mempengaruhi cara pakai

## KAPAN TIDAK PERLU
- Refactor murni (struktur berubah, perilaku sama)
- Fix typo di komentar internal
- Test ditambah/diubah (bukan behavior user-visible)
- Perubahan di file konfigurasi internal

## URUTAN KERJA

### 1. DETEKSI — perubahan apa yang user-visible?
Kuesioner cepat:
- Apakah user bisa melihat bedanya? (output, error, prompt, UI)
- Apakah cara pakai berubah? (command baru, flag baru, param baru)
- Apakah ada fitur baru yang bisa dipakai?
- Apakah ada fitur yang dihapus/diubah?

### 2. UPDATE README
- Bagian terkait diperbarui sesuai perubahan aktual
- **Hitungan badge** (agent/skill/command) WAJIB cocok isi repo — satu angka salah = self-test gagal
- Contoh command di README harus bisa dijalankan persis seperti tertulis (bukan contoh fiktif)
- Tautan internal harus valid (tidak broken)

### 3. UPDATE CHANGELOG
- Entry baru di bawah `[Unreleased]` atau versi yang sesuai
- Format: tanggal + perubahan 1 baris per item (Keep a Changelog)
- Tipe: Added / Fixed / Changed / Removed
- Setiap entry harus bisa diverifikasi ke commit/file tertentu

### 4. CEK SILANG — validasi integritas
- Semua contoh command di dokumen harus bisa dijalankan persis seperti tertulis
- Badge angka di README = jumlah aktual di folder (skill/command/agent)
- VERSION file = badge di README = entry CHANGELOG terakhir
- Tidak ada referensi ke file/endpoint yang sudah tidak ada

## FORMAT LAPORAN
```
DOC   : X dokumen diubah
FILE  : README (bagian X), CHANGELOG (entry Y)
SINKRON: VERSION badge ✓, command examples ✓, links ✓
```

## INTEGRASI PIPELINE
```
BANGUN → perubahan user-visible terdeteksi → DOC-FULL ← posisi skill ini
                                                  ↓
                                            CHANGELOG (skill changelog bila rilis)
                                            VERSION sync (bila bump versi)
```
- Sebelum: perubahan kode (any yang mengubah behavior)
- Sesudah: `skill changelog` bila rilis formal, `skill self-test` bila di project kit

## EDGE CASE
- Multi-bahasa → update semua locale files, bukan cuma default
- README punya badge CI → pastikan badge反映 aktual
- CHANGELOG sudah ada entry untuk hari ini → tambah, jangan timpa
- Dokumen di folder terpisah (docs/) → cek juga, jangan hanya README

## ERROR HANDLING
- File dokumen tidak ada → buat baru bila perubahan cukup signifikan, catat di laporan
- Format CHANGELOG tidak konsisten → luruskan format dulu, baru isi entry
- README badge tidak cocok → hitung aktual, perbaiki angkanya, jangan menebak

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Mengarang angka badge tanpa menghitung → hitung dulu, tulis angka pasti
- ❌ Menambah entry CHANGELOG tanpa referensi commit → setiap entry harus bisa dilacak
- ❌ Mengabaikan command examples yang sudah tidak valid → test manual atau skip
- ❌ Mengupdate README tapi lupa CHANGELOG → keduanya harus sinkron
- ❌ Dokumen berbohong tentang fitur yang belum ada/diubah → kode adalah sumber kebenaran
