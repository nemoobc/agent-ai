---
description: PLAN — susun rencana 8 blok sebelum perubahan dimulai
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan fase GODOK melalui skill plan. Tampilkan rencana 8 blok kepada user, lalu berhenti di gerbang PLAN sampai rencana diterima oleh alur DEV. Jangan mengimplementasikan kode sebagai PLAN.

## Usage

```
/plan [deskripsi perubahan]
```

- `deskripsi perubahan` — apa yang harus direncanakan

## Triggers

- **skill plan** — susun rencana 8 blok
- **skill scan** — pemetaan file terpengaruh
- **skill estimate** — estimasi ukuran pekerjaan
- **HUKUM 2** — pipeline wajib: MIKIR → BAYANGKAN → GODOK → BANGUN

## Example

```
/plan tambah validasi input form registrasi
/plan migrasi dari CommonJS ke ES Modules
/plan refactor auth module jadi microservice
```

## Expected Output

```
PLAN — 8 BLOK
1. ANALISIS   : 3 file terpengaruh, 145 baris, autentikasi
2. TUJUAN     : validasi input: email, password, username
3. SOLUSI     : middleware validator + joi schema
4. BUKTI      : test merah→hijau untuk setiap validasi
5. URUTAN     : schema → middleware → route → test
6. TEST       : 8 assertion baru (happy path + edge case)
7. RISIKO     : breaking change jika lama pakai regex manual
8. SKALA      : S, 1-2 hari (S/M/L/XL + estimasi hari)

GATE: rencana diterima user → lanjut /build. Ditolak → revisi.
```

Efek: NOL kode. GATE: DITERIMA→/build <topik> | DITOLAK→revisi.

## Error Cases

- **Deskripsi tidak jelas** → minta spesifikasi lebih detail
- **Tidak ada scan** → scan dulu baru plan
- **Plan > XL** → pecah jadi milestone
- **User tidak terima** → revisi sampai diterima

## Related Commands

- `/build` — eksekusi setelah plan diterima
- `/ship` — pipeline penuh termasuk plan
- `/estimate` — estimasi sebelum plan
