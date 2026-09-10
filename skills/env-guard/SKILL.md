---
description: ENV-GUARD — hygiene environment: .env tidak ikut ke-commit, .env.example ada dan sinkron, secret tidak masuk git. Wajib untuk project dengan secret. run.sh jalan otomatis di audit.
---

# ENV-GUARD

Secret yang ke-commit = satu peristiwa, selamanya di history. Guard menjaga pintunya.

## APA YANG DILAKUKAN
Memastikan environment variable dan secret tidak bocor ke version control. Env-guard = penjaga gerbang keamanan: .env aman, .env.example lengkap, secret tidak di kode.

## KAPAN WAJIB JALAN
1. **Project dengan secret** — API key, token, password
2. **Sebelum commit** — bersama git-guard
3. **Setelah tambah dependency baru** — dependency baru mungkin butuh env baru
4. **Saat audit** — bagian dari audit-full
5. **User tambah .env baru** — pastikan ter-cover

## JALANKAN
```bash
bash ~/.config/opencode/skill/env-guard/run.sh
```
(atau terpasang di project: `bash .opencode/skill/env-guard/run.sh`)
Exit 0 = bersih. Exit 1 = masalah.

## CEK YANG DILAKUKAN run.sh

### 1. .gitignore Coverage
`.gitignore` memuat `.env` (dan `.env.*` kecuali `.env.example`).

### 2. Tracked .env Check
Tidak ada file `.env` yang ter-track di git (`git ls-files`).

### 3. .env.example Existence
`.env.example` ada (template key tanpa nilai) — kalau project pakai env.

### 4. Secret Scan
Scan file ter-track untuk pola secret (API key, token, private key).

## SETELAH TEMUAN

### .env Ter-Track
```bash
git rm --cached .env
echo ".env" >> .gitignore
```
+ ROTASI secret (bukan cuma hapus!)

### .env.example Hilang
Bikin dari key yang dipakai (nilai kosong):
```
API_KEY=          # Required: your API key
DATABASE_URL=     # Required: database connection
SECRET_KEY=       # Required: session secret
```

### Secret Bocor ke History
Rotasi + pertimbangkan gitleaks/rewrite hanya dengan persetujuan user (HUKUM 5 — rewrite history dilarang tanpa izin).

## GERBANG
- `.env` ter-track → commit DILARANG (gabung dengan git-guard)
- `.env.example` tidak sinkron dengan key asli → temuan P2
- Secret bocor → P0. Rotasi wajib, bukan sekadar hapus file

## INTEGRASI PIPELINE
```
ENV-GUARD ← posisi skill ini → GIT-GUARD → COMMIT
              ↓
         AUDIT-FULL (gabungan)
         ROTASI SECRET (bila bocor)
```
- Sebelum: tambah env, dependency baru
- Sesudah: git-guard (pre-commit), audit-full
- Berkaitan: `skill git-guard` (staged diff check), `skill audit-full` (audit menyeluruh)

## EDGE CASE
- Project tidak pakai env → .env.example tidak wajib
- .env.example sudah outdated → update sesuai key aktual
- Multi-environment (.env.development, .env.production) → semua harus di .gitignore
- Secret di hardcoded di kode → itu temuan P0 lain, fix juga

## ERROR HANDLING
- .gitignore tidak bisa di-edit → catat di SELAIN
- git rm --cached gagal → force add ke .gitignore
- Tidak yakin key mana yang asli → baca .env, jangan tebak

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Hapus .env tanpa rotasi → secret masih beredar
- ❌ .env.example tidak sinkron → developer baru tidak tahu key apa yang dibutuhkan
- ❌ Skip env-guard → secret bisa bocor tanpa disadari
- ❌ Menganggap .gitignore = aman → git rm --cached tetap perlu
- ❌ Secret di hardcoded → itu juga P0, fix juga
