---
description: Mikir mendalam sebelum eksekusi — analisa masalah, batasan, opsi, risiko, lalu putus. Wajib sebelum membangun/memperbaiki apa pun. Dilarang menebak.
---

# THINK

Godok dengan struktur ini (jangan lewati satu pun):
1. **MASALAH** : apa yang sebenarnya diminta (di balik kata-kata user)
2. **KONTEKS** : bahasa/framework/batasan project yang relevan
3. **OPSI** : minimal 2 pendekatan + trade-off masing-masing
4. **RISIKO** : apa yang bisa hancur / efek samping
5. **PUTUSAN** : pilih satu, alasan satu kalimat

Tulis hasil maksimal ~10 baris, lalu LANGSUNG eksekusi. Jangan berhenti untuk bertanya.

## APA YANG DILAKUKAN
Mengubah masalah abstrak jadi keputusan konkret dengan bukti. Think = filter kualitas sebelum kode ditulis. Tanpa think, setiap baris kode berisiko salah arah.

## KAPAN WAJIB JALAN
1. **Setiap tugas baru** — tanpa pengecualian, keciliar sederhana sekali (1 file, fix typo)
2. **Sebelum architect** — arsitektur tanpa analisa = desain tanpa fondasi
3. **Sebelum fix bug** — fix tanpa analisa = tebak, bisa menambah masalah
4. **Sebelum refactor** — refactor tanpa analisa bisa merusak lebih dari memperbaiki
5. **Sebelum keputusan arsitektur** — framework pilihan, pattern, approach

## URUTAN KERJA

### 1. BACA KONTEKS (skill scan)
- Bahasa, framework, struktur project
- File yang terpengaruh
- Dependensi yang relevan

### 2. ANALISA MASALAH
Tulis dalam 1-2 kalimat:
- Apa yang diminta user (literal)
- Apa yang benar-benar dibutuhkan (di balik literal)
- Apa batasan yang ada (waktu, teknologi, skill)

### 3. EVALUASI OPSI
Minimal 2 pendekatan:
| Opsi | Deskripsi | Kelebihan | Kekurangan | Usaha |
|---|---|---|---|---|
| A | ... | ... | ... | S/M/L |
| B | ... | ... | ... | S/M/L |

### 4. IDENTIFIKASI RISIKO
Per opsi:
- Apa yang bisa gagal?
- Apa dampak kegagalan?
- Bagaimana mitigasinya?

### 5. BUAT PUTUSAN
Pilih satu opsi + alasan 1 kalimat. Putusan harus:
- Berdasarkan fakta dari 3 langkah sebelumnya
- Bisa dipertanggungjawabkan
- Bukan "terasa benar" tapi "terbukti benar"

## OUTPUT FORMAT
```
THINK:
MASALAH : <1-2 kalimat>
KONTEKS : <bahasa, framework, constraint>
OPSI    : A) <deskripsi> / B) <deskripsi> — PILIH: <A/B>
RISIKO  : <1-2 risiko utama + mitigasi>
PUTUSAN : <pilihan + alasan 1 kalimat>
```

## ATURAN
- Format 5 bagian di atas WAJIB utuh — putusan tanpa opsi = dugaan, dilarang
- Output think = input skill spec & plan. Rantai: think → spec → imagine → plan
- Opsi harus REALISTIS sesuai stack & constraint project
- Putusan boleh salah — yang dilarang = putusan tanpa analisa

## INTEGRASI PIPELINE
```
SCAN → THINK ← posisi skill ini → IMAGINE → PLAN → SPEC → ...
         ↑
      RECALL (memori)
```
- Sebelum: scan (konteks project), recall (pelajaran lama)
- Sesudah: imagine (visualisasi), plan (rencana 8 blok), spec (spesifikasi)
- Berkaitan: `skill spec` (spesifikasi dari think), `skill estimate` (skala dari think)

## EDGE CASE
- Tidak ada opsi yang bagus → pilih "terburuk dari yang buruk" + catat risiko
- Dua opsi setara → pilih yang lebih sederhana + catat
- User sudah putuskan → verify putusan user vs analisa, catat bila konflik
- Tugas sangat kecil (1 baris) → think 1 baris: "masalah X, fix di file:baris, risiko nol"

## ERROR HANDLING
- Konteks tidak cukup → baca file tambahan, scan ulang, lalu think
- Opsi tidak bisa dievaluasi → cari data dulu (skill research), baru putuskan
- Putusan konflik dengan user → diskusikan dengan data, jangan paksa

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip think → "langsung coding" = keputusan tanpa dasar
- ❌ Think tanpa konteks project → analisa indah yang tidak applicable
- ❌ Hanya 1 opsi → pastikan minimal 2, bandingkan
- ❌ Putusan tanpa alasan → "karena terasa benar" = dilarang
- ❌ Think terlalu panjang (>15 baris) → think = analisa cepat, bukan esai
- ❌ Mengulang think yang sama → putusan sudah dibuat, eksekusi
