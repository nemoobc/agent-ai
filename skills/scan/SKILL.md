---
description: SCAN — peta project saat BOOT sesi: bahasa, framework, struktur, entry point, test framework. Input wajib sebelum eksekusi pertama. Baca file, jangan tebak.
---

# SCAN

Jalan tiap awal sesi, sebelum eksekusi pertama. Baca file, jangan tebak:

1. **BAHASA & FRAMEWORK** — dari manifest: `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` / `composer.json` / `Makefile`
2. **ENTRY POINT** — main/index/app, script `start`/`dev` di manifest
3. **TEST FRAMEWORK** — jest/vitest/pytest/go test/… + cara menjalankannya
4. **STRUKTUR** — folder penting + fungsinya, maksimal 8 baris
5. **MEMORI PROJECT** — `.opencode/memory/` bila ada; baca 10 baris terakhir tiap file

Output: 1 blok peta project, maksimal 10 baris, gaya caveman. Tanpa blok ini, eksekusi pertama DILARANG.

## APA YANG DILAKUKAN
Membangun peta mental project dalam 30 detik — apa project ini, pakai apa, cara jalaninnya di mana. Scan = fondasi untuk semua skill lain yang menyentuh kode.

## KAPAN WAJIB JALAN
1. **Awal setiap sesi baru** — sebelum recall, think, atau plan
2. **User berpindah project** — peta baru untuk project baru
3. **Setelah perubahan arsitektur besar** — peta mungkin sudah usang
4. **Sebelum skill lain yang butuh konteks** — test, audit, fix, refactor

## URUTAN SCAN

### 1. BAHASA & FRAMEWORK (5 detik)
Cari file manifest di root:
```
package.json  → Node.js (cek dependencies utama)
pyproject.toml / requirements.txt → Python
go.mod        → Go
Cargo.toml    → Rust
composer.json → PHP
Makefile      → build system
Gemfile       → Ruby
```
Bila tidak ada manifest → scan manual: ekstensi file di src/

### 2. ENTRY POINT (5 detik)
Dari manifest:
- `scripts.start` / `scripts.dev` → perintah jalankan
- `main` / `index` / `app` → file utama
- Dari kode: file pertama yang di-import/export

### 3. TEST FRAMEWORK (5 detik)
Dari dependencies + config:
- Jest / Vitest / Mocha → Node
- Pytest / Unittest → Python
- `go test` → Go (built-in)
- `cargo test` → Rust (built-in)

### 4. STRUKTUR (10 detik)
```
src/          → kode sumber utama
tests/        → test files
config/       → konfigurasi
scripts/      → build/deploy scripts
docs/         → dokumentasi
```
Maksimal 8 baris. Lebih = terlalu detail untuk scan.

### 5. MEMORI PROJECT (5 detik)
- `.opencode/memory/` → baca 10 baris terakhir tiap file
- Konvensi, keputusan lama, pelajaran

## OUTPUT FORMAT
```
SCAN:
BAHASA   : <language> + <framework>
ENTRY    : <file:baris utama>
TEST     : <framework> — <command>
STRUKTUR : <folder utama, maks 8 baris>
MEMORI   : <ada/tidak> — <ringkas 1 baris>
```

## ATURAN
- Baca file, jangan tebak — scan yang tebakan = peta palsu
- Peta palsu → keputusan salah → kode salah → fix frustrasi
- Scan boleh dilewati HANYA bila project sudah di-scan di sesi yang sama dan tidak berubah
- Tanpa blok ini, eksekusi pertama DILARANG

## INTEGRASI PIPELINE
```
RECALL → SCAN ← posisi skill ini → THINK → IMAGINE → PLAN → ...
```
- Sebelum: recall (memori jangka panjang)
- Sesudah: think (analisa masalah), imagine (visualisasi), plan (rencana)
- Berkaitan: `skill convention` (ekstrak konvensi), `skill metrics` (ukuran project)

## EDGE CASE
- Project kosong/baru → scan hasil: "project baru, stack: X, siap scaffold"
- Monorepo → scan root + package utama
- Project dengan banyak bahasa → scan semua yang terdeteksi
- Framework tidak dikenali → catat ekstensi file, tebak stack dari kode

## ERROR HANDLING
- File manifest corrupt/tidak ada → scan manual dari kode sumber
- Package manager tidak terdeteksi → catat, jalankan test manual
- Permission denied untuk beberapa file → skip, catat di SELAIN
- Project terlalu besar (>1000 file) → scan root + src/, skip detail

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip scan → "sudah tahu project-nya" = ingatan palsu, project berubah
- ❌ Scan tanpa membaca file → mengarang = peta palsu
- ❌ Scan terlalu detail (>10 baris) → scan = ringkas, bukan dokumentasi
- ❌ Scan project lain → peta harus project yang SEDANG dikerjakan
- ❌ Scan tanpa update → project berubah, scan harus segar

## MASTERY — ALL-ROUNDER MAX
Pemetaan kelas atas:
- 30 detik pertama: entry point + manifest (package.json/requirements/Makefile) + struktur folder — itu wajah project
- Bau kode tersembunyi: file 1000+ baris, folder "misc/util/new", dua config sama nama
- Stack sadar: framework = konvensi = cara cepat paham maksud kode — catat versi, bukan cuma nama
- Output scan = peta navigasi: mana aman dilewati, mana wajib dibaca utuh, mana mencurigakan
