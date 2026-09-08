---
description: COVERAGE — peta gap test heuristik: daftar fungsi/class dari source, cek mana yang tidak pernah disebut di file test. Bukan pengganti coverage tool — penunjuk area yang belum tersentuh.
---

# COVERAGE

Coverage tool yang asli lebih akurat — tapi tidak selalu terpasang. Heuristik ini memberi peta dalam 5 detik: fungsi mana yang belum punya test sama sekali.

## JALANKAN
```bash
bash ~/.config/opencode/skill/coverage/run.sh
```
(atau terpasang di project: `bash .opencode/skill/coverage/run.sh`)

Output: daftar fungsi/class dari source + mana yang tidak pernah disebut di test files.

## BACA
- Fungsi di area penting tanpa test reference → gap. Masuk /backlog dengan definisi selesai (skill test-design: kasus apa dulu).
- Bukan bukti "tidak teruji" mutlak — nama fungsi bisa berubah/re-export. Gunakan sebagai peta, konfirmasi manual untuk fungsi kritis.
- Fungsi baru dari coder tanpa test → langsung gap → test-design.

## GERBANG
- Peta gap tidak boleh dijadikan klaim "coverage X%" — itu heuristik, bukan pengukur.
- Area kritis (auth/data/publik) dengan gap → P2, masuk backlog sebelum fitur baru.