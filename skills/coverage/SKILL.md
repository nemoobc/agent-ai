---
description: COVERAGE — peta gap test heuristik: daftar fungsi/class dari source, cek mana yang tidak pernah disebut di file test. Bukan pengganti coverage tool — penunjuk area yang belum tersentuh.
---

# COVERAGE

Coverage tool yang asli lebih akurat — tapi tidak selalu terpasang. Heuristik ini memberi peta dalam 5 detik: fungsi mana yang belum punya test sama sekali.

## APA YANG DILAKUKAN
Memetakan celah (gap) antara kode sumber dan cakupan test. Coverage heuristik = detektor area gelap: fungsi yang diekspor tapi tidak pernah diuji.

## KAPAN WAJIB JALAN
1. **Setelah coder menulis kode baru** — pastikan ada test yang mengcover
2. **Sebelum deliver** — pastikan tidak ada area kritis tanpa test
3. **Saat audit** — identifikasi area berisiko tinggi
4. **Sesuatu yang menambah fitur** — fitur baru harus punya test

## JALANKAN
```bash
bash ~/.config/opencode/skill/coverage/run.sh
```
(atau terpasang di project: `bash .opencode/skill/coverage/run.sh`)

Output: daftar fungsi/class dari source + mana yang tidak pernah disebut di test files.

## CARA KERJA

### 1. Daftar Semua Fungsi/Class
Dari source files (bukan test files):
- Fungsi publik/export
- Class methods
- Public API

### 2. Cek Referensi di Test
Untuk tiap fungsi: apakah namanya muncul di test files?
- Ada referensi → kemungkinan sudah dites
- Tidak ada referensi → gap

### 3. Prioritaskan Gap
- Area kritis (auth, payment, data) → P2
- Area internal → P3
- Helper/utilities → info saja

## BACA HASIL
- Fungsi di area penting tanpa test reference → gap. Masuk /backlog dengan definisi selesai (skill test-design: kasus apa dulu)
- Bukan bukti "tidak teruji" mutlak — nama fungsi bisa berubah/re-export. Gunakan sebagai peta, konfirmasi manual untuk fungsi kritis
- Fungsi baru dari coder tanpa test → langsung gap → test-design

## GERBANG
- Peta gap tidak boleh dijadikan klaim "coverage X%" — itu heuristik, bukan pengukur
- Area kritis (auth/data/publik) dengan gap → P2, masuk backlog sebelum fitur baru
- Gap di area non-kritis → catat, tidak blocking

## INTEGRASI PIPELINE
```
CODER (tulis kode) → COVERAGE ← posisi skill ini → TEST-DESIGN (tulis test untuk gap)
                                                       ↓
                                                  TEST-FULL (jalankan test)
```
- Sebelum: coder (kode baru), test-full (test yang sudah ada)
- Sesudah: test-design (tulis test untuk gap), test-full (jalankan)
- Berkaitan: `skill test-design` (kasus test), `skill test-full` (jalankan test)

## EDGE CASE
- Project tanpa test → semua fungsi gap, prioritaskan yang paling kritis
- Test tidak pakai nama fungsi yang sama → false positive gap
- Re-export / barrel export → fungsi mungkin sudah dites di tempat lain
- Test pakai mocking → fungsi asli mungkin tidak pernah dipanggil sungguhan

## ERROR HANDLING
- Coverage script gagal → fallback: grep manual nama fungsi di test files
- Terlalu banyak gap → prioritaskan area kritis dulu
- Tidak ada source files → project kosong, tidak ada yang perlu di-test

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Mengklaim "coverage X%" dari heuristik → ini bukan pengukur, ini peta
- ❌ Skip coverage karena "sudah ada test" → test bisa tidak mengcover semua
- ❌ Mengabaikan gap di area kritis → auth tanpa test = risiko tinggi
- ❌ Gap dianggap selesai tanpa test → gap = butuh test baru
- ❌ Coverage menggantikan test runner → coverage = pelengkap, bukan pengganti
