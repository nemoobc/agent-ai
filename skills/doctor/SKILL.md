---
description: DOCTOR — diagnosa instalasi & kesehatan: lingkungan, dependensi opsional, typecheck, memori (termasuk deteksi secret di memori). Jalankan kapan pun tanpa diminta bila ada yang terasa aneh.
---
# DOCTOR

Jalankan dari root project:
```bash
bash ~/.config/opencode/skill/doctor/run.sh .
```
(atau terpasang di project: `bash .opencode/skill/doctor/run.sh .`)

Exit 0 = sehat, 1 = ada masalah.

Cek: tool inti (bash/git/grep), dependensi opsional (npm/shellcheck/gitleaks/pip-audit),
typecheck bila ada tsconfig, status git, dan memori DEV-BRAIN (jumlah entries +
deteksi secret yang bocor ke memori — P0).
Masalah temuan → FIXER. Tanpa masalah → lapor SEHAT, jangan bertele-tele.
