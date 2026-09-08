---
description: PR — siapkan pull request siap tempel dari diff: judul konvensional, ringkasan, perubahan, bukti test, checklist.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill pr — susun PR dari diff (`git diff <base>...HEAD` atau staged).
2. Sebelum disusun: test-full + audit-full + git-guard harus hijau (merah? /fix dulu).
3. Output format skill pr. Bila template `.github/PULL_REQUEST_TEMPLATE.md` ada → ikuti checklistnya.
4. Push/merge TIDAK dilakukan tanpa perintah eksplisit user (HUKUM 5 — aksi ke remote).