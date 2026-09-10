---
description: HANDOFF — kemas konteks sesi: selesai (bukti), sisa (terukur), keputusan, pelajaran, command validasi, jebakan. Untuk sesi/agent/orang berikutnya.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill handoff — kemas sesi sesuai formatnya.
2. Simpan ke memori (remember) + pelajaran (learn) supaya recall berikutnya menangkap.
3. Lapor blok HANDOFF gaya caveman. SETENGAH harus kosong — bila ada pekerjaan setengah jalan, selesaikan/batalkan DULU sebelum handoff diterbitkan.
4. Bila user minta file: docs/HANDOFF-<tanggal>.md, tanpa mengubah kode.

## Usage

```
/handoff
```

- Tidak ada argument — kemas konteks sesi saat ini.

## Triggers

- **skill handoff** — format handoff standar
- **skill remember** — simpan ke memori
- **skill learn** — ekstrak pelajaran

## Example

```
/handoff
```

## Expected Output

```
HANDOFF — 2026-09-10
SELESAI : auth module (5 file, test 24/24, audit CLEAN) — bukti: tests/run.log
SISA   : migration script (0/3 file, belum dimulai)
KEPUTUSAN: pakai bcrypt bukan argon2 (alasan: compat)
PELAJARAN: npm audit false-positive di offline mode
JALAN: /estimate "migration script" → /plan → /build
JEBAKAN: jangan lupa cek foreign key constraint
```

## Error Cases

- **Pekerjaan setengah jalan** → BATAL handoff, selesaikan/batalkan dulu
- **Sesi kosong** → lapor "tidak ada yang perlu di-handoff"
- **File tidak bisa ditulis** → simpan ke memori saja

## Related Commands

- `/context` — cek status konteks sebelum handoff
- `/report** — laporan formal (lebih detail dari handoff)
- `/memory** — ingatan untuk recall berikutnya
