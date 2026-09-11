---
description: AUTO AUDIT FULL — audit dependensi, typecheck, lint, scan secret bocor, higiene TODO. Wajib setelah test hijau. Semua temuan → FIXER. Exit code menentukan gerbang.
---

# AUDIT-FULL

Jalankan dari root project:
```bash
bash ~/.config/opencode/skill/audit-full/run.sh .
```
(atau terpasang di project: `bash .opencode/skill/audit-full/run.sh .`)

## APA YANG DILAKUKAN
Menjalankan serangkaian audit otomatis terhadap kode dan konfigurasi project:

| Audit | Tool | Target |
|---|---|---|
| Dependensi | npm audit / pip-audit / cargo audit / govulncheck | Kerentanan diketahui |
| Type Check | tsc --noEmit / mypy / pyright / go vet | Kesalahan tipe |
| Lint | eslint / ruff / clippy / golangci-lint | Masalah kode |
| Secret Scan | gitleaks / grep pola | Secret yang bocor ke kode |
| TODO Hygiene | grep TODO/FIXME | Utang teknis terbuka |
| Git Status | git status | File tidak ter-track, perubahan menggantung |

## EXIT CODE & GERBANG

| Exit | Arti | Aksi |
|---|---|---|
| `0` | CLEAN — tidak ada temuan | Lanjut ke review manual / critique |
| `1` | ADA TEMUAN — ada yang perlu diperbaiki | Semua temuan → agent FIXER |

## SETELAH EXIT 1: AUDIT MANUAL WAJIB
Script hanya menangani audit otomatis. **Review manual** harus menyusul:
1. **Validasi input** — semua input user sudah divalidasi?
2. **Otorisasi** — hak akses sudah dicek?
3. **Injection** — SQL/HTML/SSRF/command injection?
4. **Secret** — API key, token, password tertulis di kode?
5. **Error handling** — error tidak ditelan, tidak crash tanpa pesan?
6. **Race condition** — concurrent access aman?

## KAPAN WAJIB JALAN
1. **Setelah test-full hijau** — test-pass ≠ aman, audit ≠ test
2. **Sebelum deliver/PR** — pastikan kode bersih dari masalah tersembunyi
3. **Setelah perubahan besar** — multi-file, logic baru, dependency berubah
4. **Sebelum release** — audit penuh + manual
5. **Setelah hotfix** — hotfix harus melewati audit juga

## OUTPUT WAJIB
```
AUDIT: CLEAN (semua audit pass)
```
Atau:
```
AUDIT: X temuan
  - [P0] secret di file:baris
  - [P1] type error di file:baris
  - [P2] TODO terbuka: X item
  - [P3] warning lint: Y item
Semua temuan → FIXER
```

## INTEGRASI PIPELINE
```
TEST-FULL (hijau) → AUDIT-FULL ← posisi skill ini → CRITIQUE (bila ULTRA)
                           ↓
                     FIX-FULL (temuan)
                     RED-TEAM (permukaan publik)
                     A11Y (perubahan UI)
```
- Sebelum: test-full harus hijau dulu
- Sesudah: fix-full untuk temuan, lalu ulang audit sampai CLEAN
- Berkaitan: `skill env-guard` (secret di .env), `skill git-guard` (secret di staged), `skill injection-guard` (injeksi prompt)

## EDGE CASE
- Project tanpa type checker → skip typecheck, catat di SELAIN
- Dependency audit punya vulnerability tapi tidak fixable → catat sebagai known, damping risk
- Lint warnings yang sudah lama → hitung, jangan skip tanpa alasan
- Monorepo → audit semua package, bukan cuma root
- TODO dengan deadline lewat → eskalasi ke P2

## ERROR HANDLING
- Audit tool tidak terpasang → skip audit itu, catat di SELAIN, lanjut yang lain
- False positive diketahui → tandai sebagai known-false-positive, jangan hapus
- Audit timeout → catat sebagai FAILED, ulang dengan opsi verbose
- File terlalu besar untuk audit → split atau skip dengan alasan

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Menganggap test hijau = aman → test dan audit menguji hal yang BERBEDA
- ❌ Skip audit manual → script hanya permukaan, review manual = kedalaman
- ❌ Menyembunyikan temuan P0/P1 → temuan = temuan, laporkan terang-terangan
- ❌ Mengulangi audit tanpa fix dulu → fix dulu, baru audit ulang
- ❌ Menganggap "sedikit warning tidak masalah" → semua temuan ke FIXER, semua

## MASTERY — ALL-ROUNDER MAX
Audit kelas atas:
- Berlapis: struktur → logika → keamanan → dependensi → performa — tiap lapis ada daftar wajib
- Tiap temuan: P0-P3 + file:baris + saran perbaikan konkret — temuan tanpa lokasi = opini
- Secret scan: pattern (sk-, ghp_, AKIA, key=) + file .env — satu bocor = P0 selesai
- Audit sendiri di-audit: false-positive dihapus sebelum lapor — presisi itu reputasi
