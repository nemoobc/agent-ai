---
description: GIT-GUARD — gerbang sebelum commit yang JALAN: blokir secret, merge marker, debug statement, diff raksasa di staged changes. Jalankan run.sh otomatis sebelum commit.
---

# GIT-GUARD

Commit adalah gerbang terakhir sebelum kode pergi. Satu secret di commit = sakit panjang. Guard menutup pintunya.

## APA YANG DILAKUKAN
Memeriksa staged changes sebelum commit untuk memblokir masalah keamanan dan kualitas: secret, merge marker, debug statement, diff terlalu besar. Git-guard = pre-commit gatekeeper.

## KAPAN WAJIB JALAN
1. **Setiap commit** — otomatis via pre-commit hook
2. **Sebelum push** — pastikan commit aman
3. **Sebelum merge** — pastikan tidak ada masalah
4. **Saat /ship atau /release** — git-guard wajib

## JALANKAN
```bash
bash ~/.config/opencode/skill/git-guard/run.sh
```
(atau terpasang di project: `bash .opencode/skill/git-guard/run.sh`)

Exit 0 = CLEAN (aman di-commit). Exit 1 = BLOKIR (ada masalah di staged diff).

## YANG DIBLOKIR (run.sh)

### 1. SECRET
Pola API key/token/private key di staged diff:
- OpenAI: `sk-...`
- Anthropic: `sk-ant-...`
- GitHub: `ghp_...`, `gho_...`
- Google: `AIza...`
- Slack: `xoxb-...`, `xoxp-...`
- Generic: `password=`, `secret=`, `token=`

### 2. MERGE MARKER
`<<<<<<<` / `=======` / `>>>>>>>` tersisa di staged.

### 3. DEBUG STATEMENT
`console.log(...)`, `print(...)`, `var_dump(...)`, `pdb.`, `debugger` yang DITAMBAHKAN (baris `+`).

### 4. DIFF RAKSASA
Satu file > 1000 baris ditambahkan → pecah commit dulu.

## SETELAH BLOKIR
1. Fixer membersihkan (buang secret, ganti ke env; hapus debug; pecah commit)
2. Ulangi guard sampai CLEAN
3. Baru commit boleh lahir
4. Secret yang pernah ter-commit = BUKAN selesai dengan hapus file: rotasi secret + catat ke postmortem bila parah

## GERBANG
- Guard BLOKIR → commit DILARANG jalan. Tidak ada pengecualian "sekali aja"
- Guard tidak ada di kit → taruh di pre-commit hook project (`git config core.hooksPath` atau `.git/hooks/pre-commit`)
- Commit yang lolos guard tapi masih secret (pola baru) → tambah pola ke run.sh, itu pelajaran → lessons.md

## INTEGRASI PIPELINE
```
CODE → STAGE → GIT-GUARD ← posisi skill ini → COMMIT → PUSH
                ↓
          FIX (bersihkan)
          ULANG (sampai CLEAN)
```
- Sebelum: kode ditulis, di-stage
- Sesudah: commit (bila CLEAN), push
- Berkaitan: `skill env-guard` (.env check), `skill audit-full` (audit menyeluruh)

## EDGE CASE
- Guard tidak ada → setup pre-commit hook manual
- Pola baru tidak terdeteksi → tambah pola ke run.sh
- Diff besar tapi legitimate → pecah commit atau minta override (dengan alasan)
- Merge marker dari rebase → resolve dulu

## ERROR HANDLING
- run.sh tidak ada → check manual sesuai daftar pola
- Guard timeout → ulang
- Guard false positive → verifikasi manual, bila aman catat sebagai exception

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip git-guard → secret bisa bocor ke commit
- ❌ "Sekali aja" → tidak ada pengecualian untuk guard
- ❌ Guard ada tapi tidak jalan → pastikan pre-commit hook terpasang
- ❌ Mengabaikan debug statement → debug di produksi = exposure
- ❌ Pola baru tidak ditambah → pelajaran hilang
