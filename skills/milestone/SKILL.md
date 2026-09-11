---
description: MILESTONE — pecah tugas besar jadi milestone bernomor dengan bukti per milestone. Tiap milestone = plan 8 blok mini + test + laporan pendek. Tanpa bukti = tidak selesai.
---

# MILESTONE

Tugas besar ≠ plan raksasa. Tugas besar = deretan milestone kecil yang masing-masing bisa dibuktikan.

## APA YANG DILAKUKAN
Membagi tugas besar menjadi milestone kecil yang bisa diverifikasi satu per satu. Milestone = checkpoint: setiap titik harus bisa dibuktikan sebelum lanjut.

## KAPAN WAJIB JALAN
1. **Plan > 15 baris** — terlalu besar untuk satu rencana
2. **Tugas > 10 file** — butuh checkpoint
3. **> 1 hari kerja** — butuh titik verifikasi
4. **Estimasi XL** — dari skill estimate, >15 file

## URUTAN KERJA

### 1. PETA
Pecah jadi milestone bernomor M1..Mn. Urutan: yang tidak bergantung dulu.
- M1: foundation (skema, types, interface)
- M2: core logic (business rules)
- M3: integration (connect systems)
- M4: UI (tampilan)
- M5: test + polish

### 2. DEFINISI
Tiap milestone WAJIB punya bukti selesai terukur:
- test N/N PASS
- audit CLEAN
- file X jadi
- spesifikasi terpenuhi

### 3. PAPAN
Tulis papan status: `M1 [SELESAI] M2 [JALAN] M3 [ANTRE]`
Update tiap selesai satu.

### 4. EKSEKUSI
Satu milestone = satu plan 8 blok mini = satu putaran test/audit penuh.

### 5. GERBANG
Milestone belum hijau → milestone berikutnya DILARANG mulai. Tanpa tombol skip.

### 6. LAPOR
Papan akhir + ringkas per milestone (1 baris per M).

## FORMAT PAPAN (update tiap fase)
```
M1 [SELESAI] auth core — test 5/5
M2 [JALAN  ] session + middleware
M3 [ANTRE  ] UI login + test e2e
```

## GERBANG
- Bukti milestone mengada-ada (tanpa exit code) = GAGAL
- Scope creep antar milestone → masuk milestone baru, bukan diselipkan
- Milestone belum selesai → jangan mulai milestone berikutnya
- Bukti harus bisa diverifikasi ulang

## INTEGRASI PIPELINE
```
ESTIMATE (XL) → MILESTONE ← posisi skill ini → PLAN PER M → BANGUN → TEST → AUDIT
```
- Sebelum: estimate (identifikasi XL), plan (rencana awal)
- Sesudah: plan per milestone, bangun, test, audit
- Berkaitan: `skill estimate` (identifikasi XL), `skill plan` (rencana per milestone), `skill team` (paralel antar milestone)

## EDGE CASE
- Milestone bergantung satu sama lain → serial, jangan paralel
- Milestone gagal → fix dulu, jangan skip ke berikutnya
- Milestone terlalu kecil → gabung dengan milestone berikutnya
- Milestone terlalu besar → pecah lagi

## ERROR HANDLING
- Milestone tidak bisa didefinisikan → pecah lebih kecil
- Bukti tidak bisa diukur → definisikan metrik yang lebih jelas
- Milestone loop > 3x gagal → postmortem, ada masalah fundamental

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Milestone tanpa bukti → "sudah selesai" tanpa verifikasi = palsu
- ❌ Skip milestone → pastikan Hijau dulu
- ❌ Scope creep antar milestone → masuk milestone baru
- ❌ Milestone terlalu besar → pecah lagi
- ❌ Milestone tanpa test → test = bukti

## MASTERY — ALL-ROUNDER MAX
Milestone kelas atas:
- Tiap milestone punya BUKTI selesai (test/demo/angka) — milestone tanpa bukti = progres khayalan
- M1 selalu end-to-end tipis (walking skeleton) — fondasi tebal tanpa jalan = fondasi yang tak teruji
- Depan makin kabur = milestone makin pendek — jarak pandan menentukan langkah, bukan keberanian
- Milestone telat 2x = rencana ulang, bukan mental — mengejar jadwal dengan realita yang menolak = dua kali telat
