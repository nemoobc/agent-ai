---
description: Pipeline penuh — think→architect→coder→test→audit→fix→memory→lapor
agent: dev
---
TUGAS: $ARGUMENTS

Jalankan PIPELINE PENUH tanpa bertanya apa pun di antara fase:
skill recall (awal sesi) → skill think → skill imagine + task architect → skill plan (rencana 8 blok TAMPIL ke user SEBELUM eksekusi) → task coder → skill test-full → skill audit-full → task fixer (bila perlu) → skill debug (bila bug) → skill doc-full (bila user-visible) → (aksi berbiaya? skill cost dulu) → task memory → lapor gaya caveman ULTRA.

## Usage

```
/ship [deskripsi tugas]
```

- `deskripsi tugas` — apa yang harus dibangun + di-test + di-audit + dilaporkan

## Triggers

- **skill recall** — awal sesi
- **skill think** — pemikiran mendalam
- **skill imagine + task architect** — desain solusi
- **skill plan** — rencana 8 blok
- **task coder** — implementasi
- **skill test-full** — test penuh
- **skill audit-full** — audit penuh
- **task fixer** — perbaiki bila perlu
- **skill doc-full** — dokumentasi bila user-visible
- **task memory** — simpan keputusan + pelajaran

## Example

```
/ship tambah validasi input form registrasi dengan error message
/ship integrasi payment gateway midtrans
/ship refactor auth module ke microservice
```

## Expected Output

```
SHIP: SELESAI (pipeline penuh)
├── RECALL: memori loaded (13 lessons, 5 decisions)
├── THINK: 3 opsi solusi, rekomendasi: middleware validator
├── IMAGINE + ARCHITECT: schema validation + error handler
├── PLAN: 8 blok disetujui (file: PLAN.md)
├── CODE: 5 file diubah, 2 file baru (+234 -89 baris)
├── TEST: PASS (42/42, +8 baru)
├── AUDIT: CLEAN
├── FIX: tidak perlu
├── DOC: tidak user-visible
├── MEMORY: keputusan tersimpan
└── LAPOR: caveman style, rantai bukti lengkap
```

## Error Cases

- **Plan ditolak user** → revisi, ulang dari PLAN
- **Coder gagal** → task fixer → ulang
- **Test merah** → fixer → ulang sampai hijau
- **Audit temukan P0** → fix dulu

## Related Commands

- `/build** — hanya fase build (tanpa think/architect)
- `/plan** — hanya fase plan
- `/fix** — hanya fase fix
- `/verify** — verifikasi penuh setelah ship

