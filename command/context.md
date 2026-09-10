---
description: CONTEXT — lapor status konteks sesi: file yang sudah diserap, ringkasan aktif, saran compact/handoff sebelum kehilangan arah.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill context — audit konteks sesi: apa yang sudah dibaca & diserap (ringkasan), apa yang masih "aktif", apa yang mati.
2. Lapor blok [CTX]:
   DISERAP : <file yang sudah dirangkum, + lokasi kunci>
   AKTIF   : <yang sedang dipakai — minimal>
   MATI    : <yang harus dibuang dari konteks aktif>
   SARAN   : compact sekarang? handoff? lanjut (alasan 1 kalimat)
3. Konteks penuh → saran + tawaran: jalankan /handoff dulu (HUKUM 8).

## Usage

```
/context
```

- Tidak ada argument — audit konteks sesi saat ini.

## Triggers

- **skill context** — analisis konteks aktif vs mati
- **HUKUM 8** — aturan kompresi konteks

## Example

```
/context
```

## Expected Output

```
[CTX]
DISERAP : src/auth.js:1-85, skills/doctor/run.sh, AGENTS.md:HUKUM 1-6
AKTIF   : command/audit.md, tests/self-test.sh
MATI    : AGENTS.md bagian HUKUM 7-12 (sudah di-ringkasan)
SARAN   : lanjut — konteks masih 40% kapasitas
```

## Error Cases

- **Sesi baru (belum ada konteks)** → lapor "sesi bersih, mulai dari /scan"
- **Konteks penuh (>90%)** → wajib sarankan compact/handoff

## Related Commands

- `/handoff` — kemas konteks untuk sesi berikutnya
- `/report` — ringkasan sesi formal
- `/scan` — awali sesi baru dengan pemetaan
