---
description: Membayangkan hasil akhir sebelum membangun — visualisasi struktur file, alur user, tampilan akhir. Input langsung ke plan. Tanpa bayangan = plan tebakan.
---

# IMAGINE

Bayangkan hasil jadi, uraikan:
1. **BENTUK AKHIR** : seperti apa saat selesai (file, fungsi, alur, tampilan)
2. **STRUKTUR** : peta file/folder yang dibutuhkan
3. **ALUR** : langkah demi langkah dari input sampai output
4. **DEFINISI RAPI** : kriteria "ini sudah selesai" (checklist)

Kalau bingung membayangkan → baca struktur project dulu, baru bayangkan.

## APA YANG DILAKUKAN
Membangun visual mental dari hasil akhir pekerjaan sebelum menulis satu baris kode. Imagine = merencanakan dari ujung, bukan dari awal. Bayangan yang jelas mengarahkan setiap keputusan implementasi.

## KAPAN WAJIB JALAN
1. **Fitur baru** — sebelum architect mendesain
2. **Perubahan arsitektur** — sebelum rencana dibuat
3. **UI baru/modifikasi** — sebelum tampilan ditulis
4. **Integrasi system** — sebelum connect 2 system
5. **Refactor besar** — sebelum pekerjaan dimulai

## KAPAN OPSIONAL (TAPI BERGUNA)
- Bug kompleks → bayangkan fix sebelum debug
- Performance optimization → bayangkan before/after
- Migration → bayangkan data lama vs baru

## URUTAN KERJA

### 1. BACA KONTEKS
- Hasil dari skill `scan` → bahasa, framework, struktur project
- Hasil dari skill `think` → masalah, opsi, putusan
- Tanpa konteks ini → imagine hanya khayalan

### 2. BAYANGKAN BENTUK AKHIR
Tulis deskripsi konkret:
- File apa saja yang akan ada/diubah?
- Setiap file: isi intinya apa (1 frasa)?
- Bagaimana user berinteraksi dengan hasilnya?
- Bagaimana alur data dari input ke output?

### 3. PETAKKAN STRUKTUR
```
src/
├── api/
│   └── handler.ts      → endpoint baru
├── services/
│   └── auth.ts         → logic autentikasi
├── tests/
│   └── auth.test.ts    → test coverage
```
Maksimal 10 baris struktur. Lebih dari itu = terlalu detail untuk imagine.

### 4. ALUR LANGKAH
Urutan eksekusi yang masuk akal:
1. Definisikan interface/skema
2. Implementasi core logic
3. Integrasi dengan system yang ada
4. Test
5. Document

### 5. KRITERIA SELESAI
Checklist terukur:
- [ ] Semua file di struktur ada
- [ ] Alur data berfungsi end-to-end
- [ ] Test mengcover semua kasus utama
- [ ] Dokumen ter-update

## OUTPUT FORMAT
```
IMAGINE:
BENTUK  : <1-2 kalimat deskripsi hasil akhir>
STRUKTUR: <daftar file, maks 10 baris>
ALUR    : <langkah 1→2→3...>
SELESAI : <checklist 3-5 item>
```

## ATURAN
- Bayangan yang tidak terjangkau realita project = khayalan. Cocokkan dengan hasil skill scan.
- Hasil imagine = input langsung ke skill plan (blok TUJUAN/FILE). Tanpa imagine, plan menebak.
- Bayangan harus REALISTIS — sesuai stack & constraint project
- Detail terlalu banyak → masuk plan, bukan di imagine. Imagine = big picture

## INTEGRASI PIPELINE
```
SCAN → THINK → IMAGINE ← posisi skill ini → PLAN → SPEC → ...
```
- Sebelum: scan (konteks project), think (keputusan)
- Sesudah: plan (rencana 8 blok), spec (spesifikasi detail)
- Berkaitan: `skill architect` (desain dari imagine), `skill estimate` (skala dari imagine)

## EDGE CASE
- Tidak ada skill scan → jalankan scan dulu, baru imagine
- Bayangan konflik dengan constraint project → prioritaskan constraint, adjust bayangan
- User berikan mockup/wireframe → gunakan sebagai dasar bayangan, bukan ignore
- Tugas kecil sederhana → imagine 2 baris cukup, jangan dipaksa 10

## ERROR HANDLING
- Tidak bisa membayangkan hasil → baca lebih banyak konteks (file, docs), lalu coba lagi
- Bayangan terlalu kabur → spesifikkan: dari "halaman baru" ke "form login dengan 3 field"
- Bayangan bertentangan dengan think → evaluasi ulang think, baru imagine

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip imagine → "langsung coding aja" = plan tanpa arah
- ❌ Bayangan tanpa konteks project → khayalan indah yang tidak bisa dibangun
- ❌ Bayangan terlalu detail → masuk ke plan/design, bukan imagine
- ❌ Bayangan statis → bila kode berubah, update bayangan juga
- ❌ Menganggap imagine = rencana → imagine = visi, plan = rencana teknis

## MASTERY — ALL-ROUNDER MAX
Imajinasi kelas atas:
- 3 alternatif minimal: "satu-satunya cara" = belum mikir — selalu ada jalan lain
- Edge case dari aliran data: kosong/lambat/ganda/salah format/sadar-jahat
- Bayangkan maintenance 6 bulan: siapa baca kode ini? apa yang bikin dia bingung?
- Desain = keputusan yang bisa dibatalkan murah — jangan kunci apa yang belum pasti
