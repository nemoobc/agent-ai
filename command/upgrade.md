---
description: UPGRADE — update DEV-BRAIN dengan aman: --update → --check → lint → lapor. Memori tetap aman.
agent: dev
---
TUGAS: $ARGUMENTS

1. `bash install.sh --update` (unduh master, banding versi, install ulang, memori aman).
2. `bash install.sh --check` — instalasi sehat.
3. Bila kit repo ini tersedia: `bash tests/lint-kit.sh` + `bash tests/self-test.sh` — verifikasi struktur & detektor.
4. Lapor: versi lama → baru, status check, hasil lint/self-test.
5. Bila update menolak (sudah terbaru / remote tidak lebih baru) → lapor saja, jangan paksa (anti-downgrade sudah built-in).