---
description: DOC-FULL — sinkron README/CHANGELOG/dokumen saat perilaku berubah. Dipakai setelah perubahan yang user-visible.
---
# DOC-FULL

Wajib jalan bila perubahan kode mengubah perilaku, output, atau cara pakai. Tidak mengubah perilaku → skip.

1. **DETEKSI** — perubahan apa yang user-visible? Fitur baru, perilaku beda, command baru, default berubah?
2. **README** — update bagian terkait. Hitungan badge (agent/skill/command) WAJIB cocok isi repo.
3. **CHANGELOG** — tambah entry di bawah `[Unreleased]`: tanggal + perubahan 1 baris per item.
4. **CEK SILANG** — contoh command di dokumen harus bisa dijalankan persis seperti tertulis.

Output: daftar dokumen yang diubah + bagian mana. Dokumen bohong = bug.
