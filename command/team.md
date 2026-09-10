---
description: TEAM — pecah kerja jadi unit tak-bergantung, lempar sub-agent paralel, verifikasi ulang penuh, merge + lapor papan.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill plan — rencana 8 blok dulu (selalu).
2. skill team — pecah unit (tanpa file bentrok), antrean sub-agent, verifikasi ulang penuh (test+audit menyatukan), merge.
3. Lapor papan unit + hasil merge. Unit gagal → fixer dulu, paralel berhenti.
GERBANG: hasil paralel tanpa verifikasi ulang = DILARANG lapor SELESAI.

## Usage

```
/team [deskripsi kerja]
```

- `deskripsi kerja` — pekerjaan yang bisa dipecah jadi unit paralel

## Triggers

- **skill plan** — rencana 8 blok
- **skill team** — pecah unit + delegasi paralel
- **task coder** — implementasi per unit
- **skill test-full + audit-full** — verifikasi menyatukan

## Example

```
/team buat 3 API endpoint: /users, /posts, /comments
/team refactor 5 module secara paralel
```

## Expected Output

```
TEAM: 3 unit paralel
├── UNIT 1: /users — coder A — test: PASS (12/12)
├── UNIT 2: /posts — coder B — test: PASS (8/8)
├── UNIT 3: /comments — coder C — test: PASS (6/6)
├── MERGE: sukses (0 conflict)
├── TEST MENYATUKAN: PASS (26/26)
├── AUDIT: CLEAN
└── STATUS: SEMUA HIJAU
```

## Error Cases

- **Unit ada file bentrok** → tidak boleh paralel, serial saja
- **1 unit gagal** → fixer dulu, paralel berhenti
- **Merge conflict** → resolve manual, ulang test menyatukan
- **Verifikasi ulang tidak jalan** → DILARANG lapor

## Related Commands

- `/build** — build serial (bukan paralel)
- `/hermes** — delegasi lintas-domain
- `/ship** — pipeline penuh (bukan paralel)

