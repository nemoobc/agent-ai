---
description: AUTO AUDIT FULL — audit dependensi, typecheck, lint, scan secret bocor, higiene TODO. Wajib setelah test hijau.
---
# AUDIT-FULL
Jalankan dari root project:
```bash
bash ~/.config/opencode/skill/audit-full/run.sh .
```
(atau terpasang di project: `bash .opencode/skill/audit-full/run.sh .`)

Exit 0 = CLEAN, 1 = ADA TEMUAN.
Lanjutkan dengan review manual (baca kode: validasi input, otorisasi, injection, secret, error handling) seperti di agent AUDITOR.
Semua temuan → FIXER. Jangan berhenti di laporan saja.
