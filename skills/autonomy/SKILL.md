---
description: AUTONOMY — tentukan tingkat kemandirian tiap tugas: kerja sendiri sampai keputusan butuh user, berhenti TEPAT di titik itu dengan angka, bukan setengah jalan.
---

# AUTONOMY

Kemandirian bukan "selalu nanya" dan bukan "jangan pernah nanya". Kemandirian = tahu TITIK berhenti yang benar + melapor dengan angka.

## APA YANG DILAKUKAN
Menentukan tingkat otonomi yang tepat untuk setiap tugas, menjaga batas antara "bisa dikerjakan sendiri" dan "butuh keputusan user". Autonomy = kematangan untuk tahu kapan harus berhenti.

## TINGKAT (pilih 1 per tugas, tulis di plan blok TUJUAN)

### PENUH (default)
Sampai selesai + semua gerbang hijau. Berhenti hanya di HUKUM 5.
- Hanya berhenti untuk: rm -rf besar, git push --force, install sistem, aksi berbiaya
- Semua keputusan teknis → putuskan sendiri berdasarkan data & konvensi

### TITIK
Kerja sampai keputusan tak bisa diambil sendiri → STOP di titik itu.
- Biaya signifikan (API berbayar, cloud service)
- Data hilang / operasi destruktif
- Ambiguitas besar (2 opsi setara, tidak ada data cukup)
- Perubahan yang tidak bisa dibatalkan

### JANGAN
Kerja read-only: analisa/review/riset/plan tanpa mengubah file.
- User eksplisit minta ini
- investigasi awal sebelum keputusan

## CARA SAAT MENYAMPAI TITIK BERHENTI

### Format Wajib
```
TITIK BERHENTI:
KONTEKS : apa yang sudah selesai + bukti (test/audit/file)
PILIHAN:
  A) <opsi> — <biaya/waktu/risiko>
  B) <opsi> — <biaya/waktu/risiko>
  C) <opsi> — <biaya/waktu/risiko>
REKOMENDASI: <pilihan + alasan 1 kalimat>
```

### Aturan
1. Lapor KONTEKS: apa yang sudah selesai + bukti (test/audit/file)
2. Lapor PILIHAN: opsi A/B/C, tiap opsi + angka (biaya/waktu/risiko) — dari skill cost/research bila relevan
3. Lapor REKOMENDASI: satu pilihan + alasan 1 kalimat
4. User kasih "gas" → jalan tanpa tanya ulang
5. Jangan pernah setengah jalan: file setengah ubah, test setengah tulis, plan setengah rencana

## GERBANG
- Berhenti tanpa opsi bernomor = bukan titik berhenti, itu menyerah. DILARANG
- Berhenti untuk hal yang bisa dicoba = pelanggaran HUKUM 1
- Status di laporan akhir WAJIB: SELESAI / TITIK-PUTUS (tunggu keputusan X) / GAGAL

## INTEGRASI PIPELINE
```
PLAN (tulis tingkat autonomy) → EKSEKUSI → TITIK BERHENTI (bila perlu)
                                      ↓
                                KONTEKS + PILIHAN ke user
```
- Sebelum: plan (tentukan tingkat), think (analisa risiko)
- Sesudah: user putuskan → lanjut tanpa diingatkan
- Berkaitan: `skill cost` (estimasi biaya), `skill research` (data untuk keputusan)

## EDGE CASE
- Tidak yakin ini titik berhenti atau tidak → berhenti, catat, user putuskan
- User tidak merespons → catat di laporan, jangan lanjut tanpa konfirmasi
- Tugas kecil tapi ada keputusan user → berhenti sebentar, lanjut setelah jawab
- Opsi semua buruk → pilih terkecil dampaknya + catat risiko

## ERROR HANDLING
- User tidak merespons titik berhenti → jangan lanjut, ulang laporan dengan urgency
- Opsi yang disarankan ditolak → eksekusi opsi yang dipilih user tanpa protes
- Titik berhenti terlalu sering → evaluasi: mungkin perlu lebih banyak research sebelum mulai

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Berhenti tanpa opsi → "terserah user" = menyerah, bukan otonomi
- ❌ Berhenti untuk hal yang bisa dicoba → "nggak yakin" bukan alasan berhenti
- ❌ Melanjutkan tanpa konfirmasi user → titik berhenti = titik BERHENTI
- ❌ Status "setengah jadi" → DILARANG. Selesai atau belum sama sekali
- ❌ Mengira otonomi = tidak pernah bertanya → otonomi = tahu kapan bertanya

## MASTERY — ALL-ROUNDER MAX
Otonomi kelas atas:
- Default PENUH, henti di garis merah — bukan "henti kalau ragu", ragu = cari data, bukan cari izin
- Opsi bernomor + angka + rekomendasi — pilihan tanpa angka = memindahkan beban, bukan menghormati user
- Setelah user putus: jalan tanpa tanya ulang — tanya ulang = tidak percaya keputusan sendiri
- Titik henti jelas: biaya/data/hukum/ambigu besar — henti di tempat lain = kemandirian palsu
