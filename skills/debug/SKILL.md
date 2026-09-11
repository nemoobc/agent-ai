---
description: DEBUG sistematis — reproduksi → isolasi → hipotesis → bukti → fix → re-test. Wajib sebelum memperbaiki bug apa pun, dilarang menebak. Akar masalah ketemu, baru fix.
---

# DEBUG

Dilarang menebak. Dilarang fix sebelum akar masalah ketemu. Urutan WAJIB:

1. **REPRODUKSI** — buktikan bug muncul dengan command/langkah pasti. Tidak bisa direproduksi? Catat itu, jangan karang cerita.
2. **ISOLASI** — persempit: file → fungsi → baris. Pakai log sementara, `git bisect`, atau eliminasi variabel.
3. **HIPOTESIS** — 1–2 dugaan penyebab. Tulis singkat. Masing-masing harus bisa dibuktikan salah.
4. **BUKTI** — tes hipotesis dengan eksperimen terkecil. Hasilnya menang atas opini.
5. **FIX** — perbaiki akar masalah, bukan gejala. Tambah test yang gagal dulu, lalu lulus, bila mungkin.
6. **RE-TEST** — jalankan test-full. Bug sama muncul lagi? Kembali ke langkah 2.

Output wajib: root cause + `file:baris` + test pembuktian.
Log sementara untuk debugging HAPUS sebelum selesai.

## APA YANG DILAKUKAN
Proses ilmiah untuk menemukan dan memperbaiki bug: observasi → hipotesis → eksperimen → kesimpulan → perbaikan. Debug = sains, bukan seni menebak.

## KAPAN WAJIB JALAN
1. **Test merah** — bug terdeteksi oleh test
2. **User melaporkan bug** — "ini nggak jalan", "error di X"
3. **Comportment aneh** — kode seharusnya melakukan X tapi melakukan Y
4. **Regression** — fitur yang dulunya jalan sekarang tidak
5. **Sebelum hotfix** — debug dulu, baru fix (HUKUM: jangan menebak)

## URUTAN DETAIL

### 1. REPRODUKSI (wajib — tanpa ini semua langkah selanjutnya sia-sia)
Tulis langkah persis:
```
LANGKAH:
1. jalankan `command X`
2. buka file Y
3. klik tombol Z
4. observe: <apa yang terjadi>

HARUSNYA: <apa yang seharusnya terjadi>
AKTUAL  : <apa yang benar-benar terjadi>
EXIT CODE: <bila ada>
```
- Tidak bisa reproduksi → catat kondisi, jangan pura-pura sudah reproduksi
- Intermittent → cari pola: waktu, input, urutan, beban

### 2. ISOLASI (perkecil area cari)
| Teknik | Kapan pakai | Contoh |
|---|---|---|
| Binary search | Banyak file berubah | `git bisect` |
| Log sementara | Perlu tahu nilai runtime | `console.log` / `print` |
| Eliminasi | Banyak dependensi | Komentari satu per satu |
| Minimal repro | Bug kompleks | Buat versi paling sederhana dari bug |
| Debugger | Butuh stepping | breakpoint, step through |

### 3. HIPOTESIS (1-2 dugaan, bukan 10)
Format:
```
HIPOTESIS A: <penyebab> — tes: <cara buktikan salah/benar>
HIPOTESIS B: <penyebab> — tes: <cara buktikan salah/benar>
```
- Setiap hipotesis harus bisa DIBUBUHKAN salah
- Bila tidak bisa dibuktikan salah = bukan hipotesis, itu opini

### 4. BUKTI (eksperimen kecil)
- Jalankan tes hipotesis
- Hasil = fakta, bukan opini
- Bila hipotesis salah → kembali ke 3
- Bila hipotesis benar → lanjut ke 5

### 5. FIX (akar masalah, bukan gejala)
- Perbaiki DI TEMPAT akar masalah berada
- Bukan di tempat gejala muncul (kecuali keduanya sama)
- Tambah test yang GAGAL sebelum fix → HIJAU setelah fix

### 6. RE-TEST
- Jalankan test-full
- Bug sama masih muncul → kembali ke langkah 2 (ada bug lain)
- Semua hijau → fix berhasil

## OUTPUT FORMAT
```
DEBUG:
REPRO  : <command/langkah reproduksi>
ISOLASI: <file:baris yang bermasalah>
AKAR   : <penyebab teknis>
FIX    : <apa yang diubah + mengapa>
TEST   : <test yang ditambah — GAGAL sebelum, HIJAU sesudah>
BERSIH : log sementara sudah dihapus
```

## INTEGRASI PIPELINE
```
TEST-FULL (merah) → DEBUG ← posisi skill ini → FIX → TEST-FULL (ulang)
                                                    ↓
                                              AUDIT-FULL
```
- Sebelum: test-full (deteksi bug), user report
- Sesudah: fix (perbaikan), test-full (verifikasi), audit-full
- Berkaitan: `skill hotfix` (debug untuk produksi), `skill postmortem` (pelajaran dari bug)

## EDGE CASE
- Bug tidak bisa direproduksi → jangan fix berdasarkan tebakan. Catat, monitor, reproduksi dulu
- Bug di dependency → fix di dependency atau workaround di kode
- Bug intermittent → cari pattern: waktu, beban, urutan, environment
- Bug yang "bukan bug" → verifikasi apakah perilaku memang seharusnya begitu

## ERROR HANDLING
- Debug loop > 5 iterasi → STOP, eskalasi ke postmortem, minta bantuan
- Tidak ada tool debugging → debug manual dengan print/log
- Bug di kode pihak ketiga → workaround atau ganti dependency
- Debug mengubah kode lain → rollback perubahan debug, fokus ke bug utama

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Fix tanpa reproduksi → "kayaknya ini masalahnya" = tebak, dilarang
- ❌ Fix gejala, bukan akar → bug akan kembali
- ❌ Log sementara tidak dihapus → debug artifacts = kode mati
- ❌ Skip re-test → fix mungkin menambah bug baru
- ❌ Debug terlalu lama tanpa progress → 30 menit = eskalasi
- ❌ "Sepertinya sudah fix" tanpa test membuktikan → test = bukti

## MASTERY — ALL-ROUNDER MAX
Debug kelas atas:
- Repro deterministik dulu — bug yang tak stabil = 3 bug menyamar jadi satu
- Bisect: git bisect + binary search perilaku — 100 commit = 7 langkah, bukan 100
- Teori → prediksi → uji: tiap langkah harus bisa SALAH — langkah yang tak bisa salah = bukan diagnosis
- Tiga tersangka klasik: cache basi, race condition, asumsi environment — cek paling murah dulu
