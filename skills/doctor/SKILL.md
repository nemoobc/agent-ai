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

## APA YANG DILAKUKAN
Diagnosa menyeluruh terhadap kesehatan instalasi dan konfigurasi project. Doctor = stetoskop: mendengarkan tanda-tanda masalah sebelum menjadi krisis.

## CEK YANG DILAKUKAN

### 1. Tool Inti (WAJIB)
| Tool | Cek | Mengapa |
|---|---|---|
| bash | tersedia | Script berbasis bash |
| git | tersedia | Version control |
| grep / ripgrep | tersedia | Pencarian kode |

### 2. Dependensi Opsional
| Tool | Untuk | Bila tidak ada |
|---|---|---|
| npm / pnpm / yarn | Node.js | Limitasi skill tertentu |
| pip / uv | Python | Limitasi skill tertentu |
| shellcheck | Bash lint | Bash script tidak ter-lint |
| gitleaks | Secret scan | Audit kurang kedalaman |
| pip-audit / npm audit | Dependensi | Audit kurang kedalaman |

### 3. Type Check
- Bila ada `tsconfig.json` → `tsc --noEhit`
- Bila ada `pyproject.toml` dengan mypy/pyright → type check
- Bila ada `go.mod` → `go vet`

### 4. Status Git
- Branch aktif
- Ada uncommitted changes?
- Ada merge conflicts?

### 5. Memori DEV-BRAIN
- Jumlah entries di MEMORY.md, decisions.md, lessons.md
- **Deteksi secret yang bocor ke memori** → P0 (secret di memori = bahaya)

## KAPAN JALAN
1. **Awal sesi project yang sudah lama tidak disentuh** — cek apakah masih sehat
2. **Setelah install dependency baru** — pastikan tidak merusak yang sudah ada
3. **Bila ada yang terasa aneh** — error tidak jelas, performa turun, perilaku aneh
4. **Sebelum tugas besar** — pastikan fondasi kuat
5. **Setelah change environment** — OS update, Node version, Python version

## EXIT CODE & GERBANG

| Exit | Arti | Aksi |
|---|---|---|
| `0` | SEHAT — semua cek pass | Lanjut kerja tanpa masalah |
| `1` | ADA MASALAH — minimal 1 cek gagal | Baca output, fix masalah |

## OUTPUT FORMAT
```
DOCTOR: SEHAT
  tool   : bash ✓ git ✓ grep ✓
  optional: npm ✓ shellcheck ✗ gitleaks ✗
  type    : tsc ✓
  git     : branch main, clean
  memori  : 12 entries, 0 secret detected
```

Atau bila masalah:
```
DOCTOR: ADA MASALAH
  - [P0] Secret terdeteksi di memory/lessons.md baris 15
  - [P1] npm tidak terpasang — beberapa skill terbatas
  - [P2] shellcheck tidak ada — bash script tidak ter-lint
  SEMUA TEMUAN → FIXER
```

## INTEGRASI PIPELINE
```
SCAN → RECALL → DOCTOR ← posisi skill ini → THINK → PLAN
                    ↓
              FIX-FULL (masalah terdeteksi)
```
- Sebelum: scan (peta project), recall (memori)
- Sesudah: think, plan, atau eksekusi langsung
- Berkaitan: `skill env-guard` (secret di .env), `skill git-guard` (secret di staged)

## EDGE CASE
- Doctor sendiri gagal dijalankan → fallback: cek manual
- Type checker punya warning lama → hitung sebagai info, bukan error
- Memori kosong → catat sebagai info, bukan masalah
- Project sangat minimal (1 file) → doctor overkill, tapi tetap jalan

## ERROR HANDLING
- Doctor script tidak ada → cek manual yang sama
- Cek tertentu timeout → catat sebagai FAILED, lanjut cek lain
- Secret terdeteksi → P0, fix sekarang, jangan ditunda

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Menganggap doctor = optional → health check = preventif, bukan dekoratif
- ❌ Skip doctor karena "biasanya sehat" → environment berubah tanpa pemberitahuan
- ❌ Secret di memori diabaikan → P0 = langsung fix (rotasi + hapus dari memori)
- ❌ Doctor bilang masalah tapi tidak di-fix → masalah = masalah, fix atau catat
- ❌ Menganggap doctor = test → doctor = kesehatan lingkungan, test = kualitas kode

## MASTERY — ALL-ROUNDER MAX
Doctor kelas atas:
- Gejala → diagnosis → resep — bukan sekadar daftar "ada/tidak"
- Cek menyeluruh berurutan: struktur → script → test → integrasi → environment
- Resep = perintah yang bisa dijalankan + dampaknya — "perbaiki config" bukan resep, itu teka-teki
- Sehat = exit 0 + bukti — doctor yang bilang "kayaknya sehat" = dokter yang katanya lulus
