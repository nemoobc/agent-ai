---
description: ENV-GUARD — hygiene environment: .env tidak ikut ke-commit, .env.example ada dan sinkron, secret tidak masuk git. Wajib untuk project dengan secret. run.sh jalan otomatis di audit.
---

# ENV-GUARD

Secret yang ke-commit = satu peristiwa, selamanya di history. Guard menjaga pintunya.

## JALANKAN
```bash
bash ~/.config/opencode/skill/env-guard/run.sh
```
(atau terpasang di project: `bash .opencode/skill/env-guard/run.sh`)
Exit 0 = bersih. Exit 1 = masalah.

## CEK YANG DILAKUKAN run.sh
1. `.gitignore` memuat `.env` (dan `.env.*` kecuali `.env.example`).
2. Tidak ada file `.env` yang ter-track di git (`git ls-files`).
3. `.env.example` ada (template key tanpa nilai) — kalau project pakai env.
4. Scan file ter-track untuk pola secret (API key, token, private key).

## SETELAH TEMUAN
- `.env` ter-track → `git rm --cached` + tambah ke .gitignore + rotasi secret (bukan cuma hapus!).
- `.env.example` hilang → bikin dari key yang dipakai (nilai kosong).
- Secret bocor ke history → rotasi + pertimbangkan gitleaks/rewrite hanya dengan persetujuan user (HUKUM 5 — rewrite history dilarang tanpa izin).

## GERBANG
- `.env` ter-track → commit DILARANG (gabung dengan git-guard).
- `.env.example` tidak sinkron dengan key asli → temuan P2.
- Secret bocor → P0. Rotasi wajib, bukan sekadar hapus file.