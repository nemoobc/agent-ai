---
description: EXPLAIN — bedah kode/file/arsitektur untuk user pemula: bahasa sederhana, analogi, diagram teks, tidak ada jargon tanpa penjelasan. Untuk user yang minta penjelasan, bukan kerja.
---

# EXPLAIN

User minta paham. Bukan minta kerja. Beda jalur.

## APA YANG DILAKUKAN
Menjelaskan kode, fitur, atau arsitektur dengan bahasa sederhana, analogi, dan diagram teks. Explain = menerjemahkan teknis ke bahasa manusia.

## KAPAN JALAN
1. **User bertanya "apa ini?"** — kode, file, konsep
2. **User minta penjelasan** — arsitektur, alur, cara kerja
3. **User bingung** — error message, perilaku tak terduga
4. **Knowledge transfer** — menjelaskan ke orang lain

## ATURAN

### 1. Mulai dari 1 kalimat: "ini untuk apa"
Jangan langsung ke detail. Mulai dari tujuan.

### 2. Analogi dunia nyata dulu, baru istilah teknis
Contoh: "Router = seperti switchboard telepon: menghubungkan panggilan ke nomor yang benar"

### 3. Diagram teks > paragraf panjang
```
Flow: Input → Process → Output
Tree: Root → A, B → A1, A2
Tabel: komparasi fitur
```

### 4. Jargon tanpa penjelasan = dilarang
Istilah teknis → 1 kalimat definisi. Contoh:
"API (Application Programming Interface) = cara program berbicara ke program lain"

### 5. Potongan kode ≤ 10 baris
Potongan panjang → potong, tunjuk `file:baris`. Jangan tumpahkan kode raksasa.

### 6. Akhiri dengan tawaran
"Mau kucoba jalanin/ubah/tambah test?" — tawaran, bukan kerja otomatis.

## FORMAT
```
APA   : <1 kalimat>
GIMANA: <flow sederhana / diagram teks>
FILE  : <file:baris kuncinya>
CONTOH: <input → output konkret>
LANJUT: mau kucoba jalanin / ubah / tambah test?
```

## LARANGAN
- Jangan langsung kerja (bikin file, ubah kode) — user belum minta
- Jangan langsung tumpah semua detail — tanya level user dulu bila ragu
- Jangan pakai bahasa formal akademik

## INTEGRASI PIPELINE
```
USER BERTANYA → EXPLAIN ← posisi skill ini → TAWARAN (lanjut kerja?)
```
- Sebelum: user bertanya
- Sesudah: user paham, lanjut ke kerja bila mau
- Berkaitan: `skill spec` (spesifikasi teknis), `skill handoff` (transfer pengetahuan)

## EDGE CASE
- User pemula total → analogi sangat sederhana, skip jargon
- User senior → bisa langsung ke teknis, tapi tetap jelas
- Konsep sangat kompleks → pecah ke beberapa bagian
- Tidak ada analogi yang cocok → langsung ke teknis dengan penjelasan langkah demi langkah

## ERROR HANDLING
- Penjelasan tidak dimengerti → coba analogi berbeda
- Tidak ada file yang dimaksud → jelaskan konsep dulu
- User butuh lebih detail → buka file dan tunjuk baris spesifik

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Langsung kerja → user belum minta, mereka minta penjelasan
- ❌ Tumpahkan semua detail → tanya level user dulu
- ❌ Pakai jargon tanpa definisi → user makin bingung
- ❌ Penjelasan terlalu panjang → cukup untuk pemahaman, bukan untuk dokumen
- ❌ Tidak ada tawaran lanjut → "mau kucoba?" = membuka pintu kerja
