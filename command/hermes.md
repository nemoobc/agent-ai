---
description: HERMES — delegasikan tugas lintas-domain (infra/integrasi/operasi/dokumen/riset/data) ke agent hermes, dengan laporan berbukti penuh.
agent: dev
---
TUGAS: $ARGUMENTS

1. Tugas > 3 langkah → skill plan singkat dulu — utusan pun jalan dengan arah.
2. task hermes — kerjakan penuh; lapor wajib formatnya (STATUS/KERJA/FILE/BUKTI/SELAIN).
3. skill test-full + audit-full atas hasilnya → task fixer bila merah (hasil utusan = hasil kit).
4. DEV lapor ulang ke user gaya caveman + rantai bukti (HUKUM 11).

GERBANG: aksi destruktif/berbiaya dari hermes → eskalasi balik ke user (HUKUM 5). Laporan tanpa exit code/file:baris → tolak, minta ulang.

## Usage

```
/hermes [deskripsi tugas lintas-domain]
```

- `deskripsi tugas` — tugas yang tidak masuk scope coder tester auditor

## Triggers

- **skill plan** — rencana singkat untuk tugas > 3 langkah
- **task hermes** — agent lintas-domain
- **skill test-full** — verifikasi hasil hermes
- **skill audit-full** — audit hasil hermes

## Example

```
/hermes setup nginx reverse proxy untuk production
/hermes tulis dokumentasi API endpoint
/hermes riset performa Redis vs Memcached
```

## Expected Output

```
HERMES: SELESAI
├── STATUS: sukses
├── KERJA: nginx config + docker compose + health check
├── FILE: nginx.conf, docker-compose.prod.yml, docs/nginx-setup.md
├── BUKTI: nginx -t exit 0, docker-compose config valid
└── SELAIN: tidak diuji di production (staging saja)
TEST: PASS, AUDIT: CLEAN
```

## Error Cases

- **Hermes minta aksi destruktif** → eskalasi ke user (HUKUM 5)
- **Laporan tanpa bukti** → tolak, minta hermes ulang
- **Tugas bukan lintas-domain** → redirect ke agent yang tepat

## Related Commands

- `/team` — pecah kerja jadi unit paralel
- `/pr` — pull request dari hasil hermes
- `/release** — rilis hasil kerja hermes
