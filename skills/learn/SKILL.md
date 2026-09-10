---
description: LEARN — ekstrak pelajaran dari setiap tugas selesai/gagal jadi lessons.md terukur (Pola/Bukti/Aksi). Wajib di akhir tugas, di atas remember. Tanpa bukti = dilarang masuk.
---

# LEARN

Tugas selesai atau gagal = pelajaran. Tanpa diekstrak = ulang kesalahan.

## APA YANG DILAKUKAN
Mengekstrak pelajaran terukur dari setiap tugas: apa yang dilakukan, hasilnya apa, apa yang berubah. Learn = dokumentasi pembelajaran: pastikan kesalahan tidak terulang.

## KAPAN WAJIB JALAN
1. **Tugas selesai** — ada yang dipelajari dari proses
2. **Tugas gagal** — mengapa gagal, apa yang harus berubah
3. **Fix loop ≥ 2 putaran** — ada pola yang bisa diekstrak
4. **Bug ditemukan** — pelajaran untuk mencegah kejadian serupa

## URUTAN KERJA

### 1. AMATI
Apa yang dilakukan, apa hasilnya, apa yang mengherankan.

### 2. EKSTRAK
Pelajaran dalam format terukur:
- `POLA` — situasi umum (1 kalimat)
- `BUKTI` — angka/exit code/file:baris (bukan perasaan)
- `AKSI` — apa yang diubah di kit/kebiasaan kerja

### 3. SIMPAN
Entry teratas `memory/lessons.md` (1 blok, maksimal 5 baris). Duplikat → timpa yang lama.

### 4. UTAMAKAN
Pelajaran yang mengubah aturan kit → tulis juga ke decisions.md (lewat skill remember).

### 5. UKUR
Setiap 10 lesson: review — ada pola berulang? → jadikan gerbang/skill baru, hapus lesson yang sudah jadi aturan.

## FORMAT ENTRY
```
## YYYY-MM-DD — judul pelajaran
- POLA: <situasi>
- BUKTI: <angka/exit/file:baris>
- AKSI: <perubahan konkret>
```

Contoh:
```
## 2024-01-15 — Test merah setelah fix-full
- POLA: formatting bisa merusak syntax di template languages
- BUKTI: test 3/5 FAIL setelah prettier, exit 1
- AKSI: tambah re-test wajib setelah fix-full di SKILL.md
```

## GERBANG
- Tanpa BUKTI = dilarang masuk lessons.md. Perasaan bukan pelajaran
- AKSI tanpa perubahan konkret = dilarang. "Lebih hati-hati" dilarang
- POLA tanpa situasi spesifik = terlalu umum, tidak berguna

## INTEGRASI PIPELINE
```
TUGAS SELESAI/GAGAL → LEARN ← posisi skill ini → REMEMBER → HANDOFF/SELESAI
                          ↓
                    LESSONS.MD (pelajaran)
                    DECISIONS.MD (keputusan bila mengubah aturan)
```
- Sebelum: tugas selesai/gagal, debug selesai
- Sesudah: remember (simpan ke memori), handoff (transfer)
- Berkaitan: `skill remember` (simpan), `skill postmortem` (pelajaran dari insiden)

## EDGE CASE
- Tugas terlalu kecil untuk pelajaran → skip, tidak semua butuh lesson
- Pelajaran sudah ada di lessons.md → update, jangan append
- Pelajaran bertentangan dengan lesson lama → pilih yang paling baru/bukti kuat
- Terlalu banyak lesson → review, hapus yang sudah jadi aturan

## ERROR HANDLING
- BUKTI tidak bisa ditemukan → jangan tulis lesson tanpa bukti
- AKSI tidak jelas → buat AKSI yang lebih spesifik
- lessons.md penuh → kompres, hapus yang sudah jadi aturan

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip learn → "sudah selesai" = pelajaran hilang
- ❌ Learn tanpa bukti → "kayaknya ini penyebabnya" bukan pelajaran
- ❌ Learn tanpa aksi → "lebih hati-hati" bukan perubahan
- ❌ Lesson tidak pernah direview → lessons.md jadi kuburan kata
- ❌ Duplikat lesson → timpa yang lama, jangan append
