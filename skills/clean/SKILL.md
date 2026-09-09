---
description: CLEAN — bersih-bersih otomatis artefak kerja dari project: build output, cache, log, file OS. Allowlist ketat — kode sumber, node_modules, .git, .env tidak pernah disentuh.
---
# CLEAN (AUTO)

Artefak numpuk → build lambat, diff kotor, secret bisa ikut ke-zip. Bersihkan otomatis, aman, terukur.

Script:
```bash
bash ~/.config/opencode/skill/clean/run.sh [root] [--dry]
```
(atau terpasang di project: `bash .opencode/skill/clean/run.sh [root] [--dry]`)

## URUTAN
1. Target HANYA dari ALLOWLIST (bukan hasil tebakan):
   `dist/ build/ out/ .next/ .nuxt/ .turbo/ .parcel-cache/ .cache/ coverage/ .pytest_cache/ .mypy_cache/ __pycache__/ tmp/ *.log *.tmp .DS_Store Thumbs.db`
2. `--dry` → tampilkan target + ukuran, TANPA hapus. Ragu → dry dulu.
3. REAL → hapus → lapor ukuran dibebaskan per target + total.
4. Exit: 0 bersih (atau dry), 1 ada yang gagal, 2 root tidak ada.

## GERBANG / LARANGAN
- DILARANG sentuh: kode sumber, `node_modules`, `.git`, `.env*`, lockfile, memori — allowlist script, bukan keputusan momen.
- Root dikunci dari argumen pertama — DILARANG beroperasi di luar project root.
- Project tanpa git (tidak ada undo) → skill backup dulu sebelum REAL.
- Wajib sebelum deliver/zip supaya arsip bersih — dan kapan pun user minta rapi.

## OUTPUT
Blok `[CLEAN]`: mode (dry/real), target + ukuran, total dibebaskan, sisa.
