---
description: BUILD — jalankan implementasi melalui DEV setelah gerbang PLAN
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan fase BANGUN dengan task coder hanya setelah PLAN selesai, lalu meneruskan test → audit → fix → dokumentasi → memory → lapor. BUILD bukan primary agent dan tidak boleh melewati DEV.

## Usage

```
/build [deskripsi fitur]
```

- `deskripsi fitur` — apa yang harus dibangun. Harus sesuai dengan PLAN yang sudah disetujui.

## Triggers

- **task coder** — implementasi kode
- **skill test-full** — test setelah build
- **skill audit-full** — audit setelah test hijau
- **task fixer** — perbaiki bila test merah/audit temukan masalah
- **skill doc-full** — dokumentasi bila user-visible
- **task memory** — simpan keputusan + pelajaran

## Example

```
/build validasi input form login
/build API endpoint /users CRUD
/build integrasi payment gateway
```

## Expected Output

```
BUILD: SELESAI
├── PLAN: 8 blok disetujui
├── CODE: 5 file diubah, 2 file baru
├── TEST: PASS (24/24)
├── AUDIT: CLEAN
├── DOC: user-visible → doc-full jalan
└── MEMORY: keputusan tersimpan
```

## Error Cases

- **PLAN belum selesai** → lapor "PLAN wajib dulu, jalankan /plan"
- **Coder gagal** → task fixer → ulang build
- **Test merah setelah build** → task fixer → ulang dari test
- **AUDIT temukan P0** → fix dulu baru lapor

## Related Commands

- `/plan` — susun rencana 8 blok SEBELUM build
- `/ship` — pipeline penuh think→architect→build→test→audit
- `/fix` — perbaiki build yang gagal
- `/verify` — verifikasi penuh setelah build
