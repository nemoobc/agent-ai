---
description: GIT-GUARD — gerbang sebelum commit yang JALAN: blokir secret, merge marker, debug statement, diff raksasa di staged changes. Jalankan run.sh otomatis sebelum commit.
---

# GIT-GUARD

Commit adalah gerbang terakhir sebelum kode pergi. Satu secret di commit = sakit panjang. Guard menutup pintunya.

## JALANKAN (otomatis sebelum tiap commit, juga di /ship dan /release)
```bash
bash ~/.config/opencode/skill/git-guard/run.sh
```
(atau terpasang di project: `bash .opencode/skill/git-guard/run.sh`)

Exit 0 = CLEAN (aman di-commit). Exit 1 = BLOKIR (ada masalah di staged diff).

## YANG DIBLOKIR (run.sh)
1. **SECRET** — pola API key/token/private key di staged diff (OpenAI, Anthropic, GitHub, Google, Slack, dsb).
2. **MERGE MARKER** — `<<<<<<<` / `=======` / `>>>>>>>` tersisa.
3. **DEBUG** — `console.log(...)`, `print(...)`, `var_dump(...)`, `pdb.`, `debugger` yang DITAMBAHKAN (baris `+`).
4. **DIFF RAKSASA** — satu file > 1000 baris ditambahkan → pecah commit dulu.

## SETELAH BLOKIR
- Fixer membersihkan (buang secret, ganti ke env; hapus debug; pecah commit).
- Ulangi guard sampai CLEAN. Baru commit boleh lahir.
- Secret yang pernah ter-commit = BUKAN selesai dengan hapus file: rotasi secret + catat ke postmortem bila parah.

## GERBANG
- Guard BLOKIR → commit DILARANG jalan. Tidak ada pengecualian "sekali aja".
- Guard tidak ada di kit → taruh di pre-commit hook project (`git config core.hooksPath` atau `.git/hooks/pre-commit`).
- Commit yang lolos guard tapi masih secret (pola baru) → tambah pola ke run.sh, itu pelajaran → lessons.md.