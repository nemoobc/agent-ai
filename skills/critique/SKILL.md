---
description: CRITIQUE — serangan adversarial ke hasil kerja sendiri: spesifikasi, logika, bukti, skenario tak-teruji. Veto blokir lapor SELESAI. Tugas besar/berisiko = WAJIB.
---

# CRITIQUE

DEV panggil (task `critic`) SETELAH audit CLEAN, SEBELUM lapor SELESAI. Tugas besar/berisiko → WAJIB. Tugas kecil (< 3 file, tanpa risiko) → boleh skip dengan alasan tertulis 1 baris.

## APA YANG DILAKUKAN
Mencari kelemahan dalam hasil kerja sendiri dengan pola pikir penyerang/kritikus. Critique = red team internal: mencari celah sebelum user atau production menemukannya.

## KAPAN WAJIB JALAN
1. **Setelah audit FULL CLEAN** — audit menangkap pola dikenal, critique mencari pola baru
2. **Tugas besar (> 10 file)** — semakin besar, semakin banyak yang bisa salah
3. **Berisiko tinggi** — auth, pembayaran, data user, public endpoint
4. **Sebelum lapor SELESAI** — sebagai gerbang terakhir sebelum delivery

## KAPAN OPSIONAL
- Tugas kecil (< 3 file, internal murni, tanpa risiko)
- Dengan alasan tertulis 1 baris kenapa skip

## URUTAN KERJA

### 1. KUMPULKAN KLAIM
Dari laporan draft, kumpulkan semua klaim:
- Status (SELESAI / GAGAL)
- Angka test (PASS/FAIL count)
- Angka audit (CLEAN / temuan)
- File yang diklaim berubah
- Fitur yang diklaim berfungsi

### 2. VERIFIKASI BUKTI PER KLAIM
Untuk tiap klaim → temukan BUKTInya:
| Klaim | Bukti yang Dicari |
|---|---|
| "test PASS" | Exit code test + output test |
| "audit CLEAN" | Exit code audit + output audit |
| "file berubah" | git diff file:baris |
| "fitur jalan" | Test case yang membuktikan |

Tanpa bukti = temuan langsung.

### 3. SERANG 5 DITEMBAK

| # | Tembakan | Yang Dicari |
|---|---|---|
| 1 | SPESIFIKASI | Apakah hasil sesuai yang diminta? Ada yang terlewat? |
| 2 | LOGIKA | Apakah pendekatan benar? Ada shortcut yang merusak? |
| 3 | BUKTI | Apakah semua klaim punya bukti fisik? Ada yang mengarang? |
| 4 | SKENARIO TAK-TERUJI | Apa yang belum dites? Input edge? Error case? |
| 5 | GAP | Apa yang seharusnya ada tapi tidak ada? Dokumentasi? Test? |

### 4. SKENARIO RUSAK
Minimal 3 skenario yang BELUM dites:
```
SKENARIO 1: <input/aksi> → <prediksi akibat> → belum dites
SKENARIO 2: <input/aksi> → <prediksi akibat> → belum dites
SKENARIO 3: <input/aksi> → <prediksi akibat> → belum dites
```

### 5. VERDICT

| Verdict | Arti | Aksi |
|---|---|---|
| CLEAN | Tidak ada temuan kritis | Lapor SELESAI diizinkan |
| VETO (n) | n temuan yang harus difix dulu | Task fixer → fix → ulang critique |

## OUTPUT FORMAT
```
CRITIQUE:
KLAIM DIVERIFIKASI: X/Y
SERANGAN:
  1. <tembakan + temuan>
  2. <tembakan + temuan>
  ...
SKENARIO RUSAK: 3+ (daftar)
VERDICT: CLEAN / VETO (n)
```

## GERBANG (KAPAN DILARANG)
- Lapor SELESAI dengan veto tersisa = DILARANG (gerbang dev.md)
- Critique yang cuma muji = critique palsu, ulang dengan bukti
- Hitungan temuan tidak dicatat = critique tidak terjadi
- Skip critique tanpa alasan = laporan tidak valid

## INTEGRASI PIPELINE
```
AUDIT-FULL (CLEAN) → CRITIQUE ← posisi skill ini → LAPOR (bila CLEAN)
                                    ↓
                              FIX-FULL (bila VETO)
                              TEST-FULL (ulang)
                              AUDIT-FULL (ulang)
```
- Sebelum: audit-full harus CLEAN
- Sesudah: bila CLEAN → lapor; bila VETO → fix → ulang
- Berkaitan: `skill red-team` (serangan lebih agresif untuk publik), `skill trace` (rantai bukti)

## EDGE CASE
- Tugas sangat kecil → skip dengan alasan 1 baris, catat
- Critique menemukan masalah yang juga ditemukan audit → hitung sebagai temuan critique juga
- Tidak ada bukti untuk diverifikasi → langsung temuan
- User minta skip critique → catat, tanggung jawab user

## ERROR HANDLING
- Critique loop > 3 kali → ada masalah fundamental, perlu postmortem
- Tidak bisa menemukan bukti klaim → klaim tidak valid, veto
- Critique sendiri punya kesalahan → diperiksa ulang, jangan defend

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Critique yang cuma memuji → itu bukan critique, itu validasi palsu
- ❌ Skip critique pada tugas besar → "udah audit aja" ≠ kritik adversarial
- ❌ Veto yang tidak ditindaklanjuti → veto = harus fix, bukan catatan kaki
- ❌ Critique tanpa bukti → "kayaknya ada masalah" = bukan temuan
- ❌ Mengulang critique yang sama → fix dulu temuan, baru critique baru

## MASTERY — ALL-ROUNDER MAX
Kritik kelas atas:
- Serang bukti, bukan orang: klaim→bukti→celah — nada menyerang pribadi = kritik kalah
- Steel-man dulu: versi terkuat argumen lawan — kalau kalah lawan versi lemah, kamu belum menang
- Veto harus bernama: P0/P1 konkret + kondisi lulus — veto tanpa syarat = sensor
- Tanyakan yang tak ditanyakan: apa yang laporan TIDAK bilang? keheningan itu data
