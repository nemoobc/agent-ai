---
description: ROUTE — router intensitas prompt: NORMAL / FULL / ULTRA. Jalur menentukan cakupan pipeline, delegasi agent, dan mode caveman sebelum eksekusi.
agent: dev
---
PROMPT: $ARGUMENTS

1. `bash skills/route/run.sh "<PROMPT>"` — hasil: JALUR + PEMICU + KELAS.
2. Terapkan jalur (skills/route/SKILL.md):
   - NORMAL = jalur inti, delegasi minimal.
   - FULL = inti + critic + doc-full + clean.
   - ULTRA = PANGGIL SEMUA: 11 agent + caveman ULTRA + skill gerbang wajib + verify 10 gerbang sebelum lapor.
3. Tampilkan marker `[ROUTE] <jalur> — pemicu: <kata>` di rencana + laporan.
4. Jalur ≠ bahasa: caveman tetap nyala di semua jalur; hukum & gerbang sama semua jalur.

GERBANG: prompt pemicu dieksekusi NORMAL = DILARANG; prompt biasa dipaksa ULTRA = DILARANG (boros).
