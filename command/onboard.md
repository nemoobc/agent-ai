---
description: ONBOARD — peta project + cara kerja + lingkungan untuk anggota/agent baru dalam 1 blok.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill scan — peta project penuh (bahasa, framework, entry, test, struktur).
2. skill recall — memori project (keputusan penting, pelajaran).
3. Jalankan `bash install.sh --check` bila DEV-BRAIN belum terpasang di mesin baru.
4. Susun blok onboarding satu layar:

```
APA INI      : 1 kalimat fungsi project
STACK        : bahasa/framework/DB/tool
JALAN LOKAL  : command install/dev/test/audit
STRUKTUR     : folder penting (maks 6 baris)
ATURAN MAIN  : pipeline DEV-BRAIN + gerbang keras + konvensi khusus repo
MEMORI       : keputusan terpenting (maks 3)
```

5. Bila user minta file: simpan ke docs/ONBOARDING.md, jangan ubah kode.

## Usage

```
/onboard [file/opsional]
```

- `file` — opsional, simpan output ke file. Kosong = tampilkan ke user.

## Triggers

- **skill scan** — pemetaan project
- **skill recall** — memori project
- **bash install.sh --check** — validasi instalasi

## Example

```
/onboard
/onboard docs/ONBOARDING.md
```

## Expected Output

```
ONBOARDING — agent-ai
APA INI      : DEV-BRAIN kit — framework untuk AI agent yang bisa test, audit, fix otomatis
STACK        : Bash, Node.js, OpenCode, Git
JALAN LOKAL  : bash install.sh && bash tests/self-test.sh
STRUKTUR     : skills/ (56 skill), command/ (39 cmd), agents/ (11 agent), tests/ (8 test)
ATURAN MAIN  : 13 hukum, pipeline 8 fase, verify wajib sebelum selesai
MEMORI       : 1. pakai bcrypt (compat), 2. npm audit jangan tanpa lockfile, 3. hotfix freeze scope
```

## Error Cases

- **Project tidak dikenali** → scan manual + lapor
- **install.sh --check gagal** → lapor masalah instalasi
- **File tidak bisa ditulis** → tampilkan ke user saja

## Related Commands

- `/scan** — pemetaan mendalam
- `/bootstrap** — pasang DEV-BRAIN
- `/handoff** — kemas konteks untuk agent berikutnya
