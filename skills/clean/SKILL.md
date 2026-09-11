---
description: CLEAN — bersih-bersih otomatis artefak kerja dari project: build output, cache, log, file OS. Allowlist ketat — kode sumber, node_modules, .git, .env tidak pernah disentuh.
---

# CLEAN (AUTO)

Artefak numpuk → build lambat, diff kotor, secret bisa ikut ke-zip. Bersihkan otomatis, aman, terukur.

## APA YANG DILAKUKAN
Menghapus artefak build, cache, dan file sementara dari project sesuai allowlist yang ketat. Clean = housekeeping otomatis yang aman.

## JALANKAN
```bash
bash ~/.config/opencode/skill/clean/run.sh [root] [--dry]
```
(atau terpasang di project: `bash .opencode/skill/clean/run.sh [root] [--dry]`)

## URUTAN

### 1. SCAN TARGET
Target HANYA dari ALLOWLIST (bukan hasil tebakan):
```
dist/ build/ out/ .next/ .nuxt/ .turbo/ .parcel-cache/
.cache/ coverage/ .pytest_cache/ .mypy_cache/ __pycache__/
tmp/ *.log *.tmp .DS_Store Thumbs.db
```

### 2. DRY RUN (default)
`--dry` → tampilkan target + ukuran, TANPA hapus. Ragu → dry dulu.

### 3. REAL CLEAN
REAL → hapus → lapor ukuran dibebaskan per target + total.

### 4. EXIT CODE
- 0: bersih (atau dry)
- 1: ada yang gagal
- 2: root tidak ada

## GERBANG / LARANGAN
- DILARANG sentuh: kode sumber, `node_modules`, `.git`, `.env*`, lockfile, memori
- Root dikunci dari argumen pertama — DILARANG beroperasi di luar project root
- Project tanpa git (tidak ada undo) → skill backup dulu sebelum REAL
- Wajib sebelum deliver/zip supaya arsip bersih — dan kapan pun user minta rapi

## OUTPUT FORMAT
```
CLEAN: mode (dry/real)
TARGET: dist/ (2.3MB), build/ (1.1MB), .cache/ (500KB)
TOTAL : 3.9MB dibebaskan
SISA  : src/ (aman), node_modules/ (aman)
```

## INTEGRASI PIPELINE
```
KERJA SELESAI → CLEAN ← posisi skill ini → DELIVER / COMMIT
```
- Sebelum: kerja selesai, artefak menumpuk
- Sesudah: deliver (zip bersih), commit (diff bersih)
- Berkaitan: `skill deliver` (zip bersih), `skill git-guard` (diff bersih)

## EDGE CASE
- Tidak ada artefak → clean tidak melakukan apa-apa, exit 0
- Artefak sangat besar (>1GB) → lapor ukuran sebelum hapus
- Root salah → DILARANG beroperasi
- File artefak sedang dipakai proses lain → skip, catat

## ERROR HANDLING
- File sedang digunakan → skip file itu, lanjut yang lain
- Permission denied → catat, skip
- Root tidak ada → exit 2
- Gagal menghapus beberapa file → catat, exit 1

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Hapus tanpa dry run → cek dulu apa yang akan dihapus
- ❌ Skip clean → artefak menumpuk, project melambat
- ❌ Clean di production → hanya di development
- ❌ Hapus lockfile → lockfile = keamanan dependency
- ❌ Hapus .env → secret bisa hilang

## MASTERY — ALL-ROUNDER MAX
Clean kelas atas:
- Daftar dulu (--dry), hapus kemudian — hapus tanpa daftar = kasih tau setelah kehilangan
- Zona terlarang eksplisit: src/node_modules/.git/data user — bersih di zona salah = bersih yang menangis
- Artefak build/cache/log/tmp = kandidat — semuanya regenerable, semuanya boleh pergi
- Sebelum deliver/zip: clean WAJIB — arsip berisi sampah = hadiah berisi sampah
