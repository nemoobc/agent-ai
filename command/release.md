---
description: RELEASE — gerbang rilis: test → audit → changelog sinkron → version bump → tag & lapor. Tanpa lompat gerbang.
agent: dev
---
TUGAS: $ARGUMENTS

Gerbang berurutan, semua harus hijau:
1. skill test-full → hijau dulu (merah? /fix dulu, ulang dari 1).
2. skill audit-full → CLEAN atau semua temuan difix.
3. skill changelog → entry CHANGELOG terisi untuk versi target.
4. VERSION & badge README & CHANGELOG sinkron (self-test mengunci).
5. `bash tests/self-test.sh` → PASS penuh.
6. Lapor siap rilis gaya caveman: versi, jumlah entry changelog, status semua gerbang.
7. Tag/push RILIS hanya bila user eksplisit minta (HUKUM 5: aksi ke remote) — tanpa itu, berhenti di "SIAP RILIS".

## Usage

```
/release [versi]
```

- `versi` — nomor versi target (major/minor/patch). Kosong = auto-detect dari CHANGELOG.

## Triggers

- **skill test-full** — gerbang 1: test
- **skill audit-full** — gerbang 2: audit
- **skill changelog** — gerbang 3: changelog
- **bash tests/self-test.sh** — gerbang 4: konsistensi
- **HUKUM 5** — tag/push hanya bila user minta

## Example

```
/release
/release 2.3.0
/release patch
```

## Expected Output

```
RELEASE: SIAP RILIS
├── GATE 1 — TEST: PASS (42/42)
├── GATE 2 — AUDIT: CLEAN
├── GATE 3 — CHANGELOG: entry v2.3.0 (5 item)
├── GATE 4 — VERSION=2.3.0, badge sinkron
├── GATE 5 — SELF-TEST: PASS
├── VERSI: 2.3.0
└── STATUS: SEMUA HIJAU → SIAP RILIS
TAG/PUSH: menunggu perintah user (HUKUM 5)
```

## Error Cases

- **Test merah** → fix dulu, ulang dari gate 1
- **Audit temukan masalah** → fix dulu, ulang dari gate 2
- **Changelog kosong** → tulis dulu entry
- **Badge tidak sinkron** → perbaiki VERSION/README/CHANGELOG

## Related Commands

- `/pr** — pull request sebelum release
- `/verify** — verifikasi penuh sebelum rilis
- `/upgrade** — update DEV-BRAIN (bukan project)
