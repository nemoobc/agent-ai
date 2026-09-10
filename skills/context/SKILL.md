---
description: CONTEXT — disiplin konteks: baca file sekali + ringkas, jangan baca ulang utuh, compact saat penuh, handoff sebelum hilang. Jantung HUKUM 8.
---

# CONTEXT

Konteks adalah bahan bakar. Boros = bodoh di tengah tugas. Disiplin = selesai tanpa tersesat.

## APA YANG DILAKUKAN
Mengelola konteks aktif sesi kerja agar tetap efisien: baca sekali + ringkas, jangan baca ulang utuh, compact saat penuh, handoff sebelum hilang. Context = manajemen memori kerja.

## ATURAN INTI

### 1. BACA SEKALI
File dibaca → langsung tulis ringkasan 1 paragraf:
- Isi utama file
- Lokasi kunci `file:baris` untuk fakta penting
- Yang penting nanti (referensi masa depan)
Baca ulang utuh hanya bila ada alasan baru (file berubah).

### 2. RINGKAS SAAT DIPAKAI
Habis pakai skill/file, output panjang → ringkas ke fakta yang dipakai nanti:
- Output test > 50 baris → ringkas ke: PASS/FAIL + angka
- Skill output panjang → ambil kesimpulan + angka
- Baca file > 100 baris → ringkas ke 3-5 poin kunci

### 3. COMPACT SAAT PENUH
Tanda konteks penuh:
- Kehilangan detail awal sesi
- Harus baca ulang file yang sama untuk ke-3 kalinya
- Merasa "lupa sudah mengerjakan apa"

Aksi: STOP kerja → compact = tulis intisari sesi ke memori (remember + learn) → pindahkan kerja aktif ke plan/handoff → lanjut dengan kepala bersih.

### 4. HANDOFF SEBELUM HILANG
- Sesi panjang (>30 menit) → skill handoff
- Ganti topik besar → skill handoff
- Konteks mati (file yang sudah tidak relevan) → buang dari aktif

## CARA MENYAMPAIKAN KEPUTUSAN KONTEKS
- Tandai di laporan: `[CTX] ringkas: file X (sudah diserap)`
- Tandai: `[CTX] compact: 3 fakta disimpan, konteks dimuat ulang`
- Ringkasan file ≠ salinan file. 1 paragraf, angka & lokasi kunci saja
- Kalau ragu file masih perlu → tulis ringkasan, buang detail. Ringkasan selalu bisa dibaca ulang

## GERBANG
- Konteks penuh tanpa compact/handoff → kerja berikutnya DILARANG sampai konteks dirapikan
- Ringkasan tanpa lokasi `file:baris` untuk fakta penting = ringkasan gagal
- "Masih ingat kan file itu?" tanpa ringkasan tertulis = ilusi konteks, dilarang diandalkan

## INTEGRASI PIPELINE
```
RECALL → SCAN → CONTEXT ← posisi skill ini → THINK → PLAN → BANGUN → TEST
                    ↓
              BUDGET (monitoring)
              HANDOFF (transfer)
              COMPACT (kompres)
```
- Sebelum: recall (memori), scan (peta project)
- Sesudah: semua fase kerja (monitoring konteks)
- Berkaitan: `skill budget` (monitoring pemakaian), `skill handoff` (transfer konteks)

## EDGE CASE
- Sesi pendek (<10 menit) → compact mungkin tidak diperlukan
- Banyak file dibaca → prioritaskan ringkasan yang paling sering dirujuk
- File berubah di tengah sesi → baca ulang, update ringkasan
- Output tool sangat panjang → ringkas agresif, ambil angka saja

## ERROR HANDLING
- Lupa merangkum file → catat `[CTX] belum dirangkum: file X`, baca ulang nanti bila perlu
- Compact terlalu agresif → detail hilang, baca ulang file sumber
- Handoff tidak lengkap → tambah yang kurang, ulang handoff

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Baca ulang file yang sama berulang → ringkas sekali, pakai ringkasan
- ❌ Simpan semua detail → buang yang tidak relevan
- ❌ Skip compact → konteks penuh = kerja menurun kualitasnya
- ❌ Handoff tanpa struktur → penerus tidak bisa lanjut
- ❌ "Masih ingat" tanpa bukti tertulis → ilusi konteks = bahaya
