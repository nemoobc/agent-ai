# DECISIONS — DEV-BRAIN
Format: [YYYY-MM-DD] keputusan — alasan
- [2026-09-10] README 1214→231 baris badge tunggal + footer manusia — badge ganda bikin gate palsu, footer badge duplikat tak terbaca manusia
- [2026-09-10] install animasi append-only + MAIN if || exit 1 — \r menimpa log, && menelan exit gagal
- [2026-09-08] Tidak menambah agent, menambah 4 skill — pipeline gap ada di fase (GODOK/DEBUG/BOOT), bukan di peran
- [2026-09-08] Gerbang fase keras di dev.md: TEST/AUDIT tidak bisa di-skip, P0/P1 tersisa = status GAGAL
- [2026-09-08] Permission bash granular: allowlist skill/run.sh + git read-only, sisanya ask — auto-allow semua bash terlalu luas untuk agent yang diajari "jangan tanya"
- [2026-09-08] opencode.json diberi marker "devbrain" — uninstall harus hapus config buatan kit tapi restore config user
