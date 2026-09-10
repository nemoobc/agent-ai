---
description: PROFILE — profil gaya komunikasi & kedalaman user (A/B/C + kedalaman D1–D3). Dipelajari dari interaksi, dipakai DEV untuk menyesuaikan laporan & sentuhan, kerja TETAP pipeline penuh.
---

# PROFILE

DEV simpan di `memory/MEMORY.md` (bagian PROFIL). Script: `bash skills/profile/run.sh show` — tampilkan profil dari memori.

## APA YANG DILAKUKAN
Membangun profil komunikasi user: tone (A/B/C) dan kedalaman (D1-D3). Profile = personalisasi laporan tanpa mengorbankan kualitas kerja.

## TINGKAT TONE

### A = Tegas
Tugas keras/desakan → marker pendek, angka, nol basa-basi.
```
[TEST] 5/5 PASS
[AUDIT] CLEAN
STATUS: SELESAI
```

### B = Netral (default)
Marker + laporan singkat. Balance antara informasi dan efisiensi.

### C = Santai
Sapaan longgar, tetap pendek. KERJA tidak berubah: pipeline penuh tetap jalan (HUKUM 1).

## TINGKAT KEDALAMAN

### D1 = Hasil akhir
Lapor hasil saja: STATUS/TEST/AUDIT. User tidak perlu tahu proses.

### D2 = + Alasan
Hasil + putusan kunci + file kena. User perlu tahu kenapa.

### D3 = + Proses
Hasil + rencana + trade-off + skenario. User eksplorasi/tilik cara kerja.

## CARA KERJA

### Deteksi Tone
- User bicara singkat/kasar → A
- User bicara biasa → B
- User bicara santai/ngobrol → C

### Deteksi Kedalaman
- User tanya "sudah?" → D1
- User tanya "kenapa?" → D2
- User tanya "gimana caranya?" → D3

### Update Profil
- Sinyal eksplisit user → update profil
- Dugaan sekali = catat, dua kali = kunci

## ATURAN
- Profil = preferensi MENYAMPAIKAN, bukan kualitas kerja. Kualitas = konstan (HUKUM 9)
- Naik/turun tingkat berdasar sinyal eksplisit user
- Simpan: tanggal, tingkat, pemicu. Maks 3 baris di MEMORY.md

## GERBANG
- Tone/C tidak boleh mengurangi kualitas kerja → test tetap jalan, audit tetap jalan
- D1 bukan alasan skip test/audit → hanya mengubah cara MENYAMPAIKAN, bukan APA yang dikerjakan
- Profil yang salah → user memberi feedback → update segera

## INTEGRASI PIPELINE
```
RECALL (baca profil) → KERJA → LAPOR (pakai profil)
```
- Sebelum: recall (baca profil dari memori)
- Sesudah: laporan disesuaikan dengan profil
- Berkaitan: `skill recall` (membaca profil), `skill remember` (menyimpan profil)

## EDGE CASE
- User tidak memberi sinyal → default: B + D2
- Sinyal konflik → ambil yang paling baru
- Multi-user → profil per user, bukan global
- Profil berubah seiring waktu → update berkala

## ERROR HANDLING
- Profil tidak ada di memori → default B + D2
- Profil corrupt → reset ke default
- Tidak yakin profil → konservatif: B + D2

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Mengira profil = kualitas → profil = cara menyampaikan, bukan apa yang dikerjakan
- ❌ D1 = skip test → D1 = laporan singkat, bukan pekerjaan setengah
- ❌ A = kasar → A = tegas, bukan tidak sopan
- ❌ Profil kaku → update saat user berubah
- ❌ Profil = alasan untuk tidak bertanya → profil = cara menjawab, bukan cara bertanya
