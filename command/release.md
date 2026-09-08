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
