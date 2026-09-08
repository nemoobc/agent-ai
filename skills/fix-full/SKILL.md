---
description: AUTO FIX FULL — formatter, lint --fix, lalu re-test otomatis sampai terlihat hasil. Dipakai FIXER di setiap putaran perbaikan.
---
# FIX-FULL
Jalankan dari root project:
```bash
bash ~/.config/opencode/skill/fix-full/run.sh .
```
(atau terpasang di project: `bash .opencode/skill/fix-full/run.sh .`)

Script ini: prettier/black/gofmt → eslint --fix / ruff --fix → re-run test-full otomatis.
Perbaikan logis (bisnis logic) tetap harus kamu tulis sendiri — script hanya permukaan.
Ulangi: perbaiki → fix-full → cek → sampai hijau.
