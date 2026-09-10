---
description: ROUTE — router intensitas: klasifikasi prompt user jadi jalur NORMAL / FULL / ULTRA sebelum eksekusi. Respon default = biasa. FASE 0 pipeline.
---

# ROUTE (FASE 0 — ROUTER INTENSITAS)

Satu klasifikasi, tiga jalur. Sumber kebenaran = `run.sh` (detektor kata pemicu). Default semua tugas = NORMAL.

## APA YANG DILAKUKAN
Mengklasifikasikan permintaan user ke jalur eksekusi yang sesuai: NORMAL (biasa), FULL (lebih dalam), atau ULTRA (panggil semua). Route = traffic control: arahkan ke jalur yang tepat.

## KAPAN JALAN
1. **Setiap permintaan user** — FASE 0 pipeline
2. **Sebelum eksekusi** — tentukan cakupan
3. **User memberi sinyal** — "panggil semua", "lengkapin", "ultra"

## URUTAN

### 1. JALANKAN ROUTER
```bash
bash skills/route/run.sh "<prompt>"
```
Output: jalur + alasan.

### 2. TENTUKAN JALUR

| Jalur | Kapan | Cakupan |
|---|---|---|
| **NORMAL** | Default semua tugas | Respon biasa, tanpa delegasi agent, tanpa marker pipeline |
| **FULL** | "lengkapin", "bagusin", "matangkan", "lebih detail" | Riset + test + dok + critic ringan. Respon TETAP biasa |
| **ULTRA** | "panggil semuanya", "semua agent", "ultra", "tunjukkan semua" | PANGGIL SEMUA: 11 agent + caveman ULTRA + semua skill gerbang |

### 3. TULIS DI Laporan
```
[ROUTE] <jalur> — pemicu: <kata/frasa> (<kelas>)
```

## PEMICU

### KELAS ULTRA (summons eksplisit)
- "panggil/kerahkan/summon + semua/semuanya/all"
- "tunjukkan/pamerin semua kemampuan/bakat(mu)"
- "ultra/ultra mode/all-out/mode terkuat"

### KELAS FULL (kerja lebih dalam)
- "lengkapin/lengkapi", "bagusin/perbagus", "matangkan"
- "sempurnakan", "upgrade", "maksimalkan"
- "pertajam/perdalam/pertebal", "rapikan"

### NORMAL (default)
- Semua yang tidak match di atas

## ATURAN
- Kalimat biasa yang kebetulan mengandung kata mirip → NORMAL (konteks kalimat menang)
- Konflik → ambil tertinggi
- Prompt gak match → NORMAL
- Caveman ULTRA hanya nyala di jalur ULTRA
- adapter /plan|/build|/ship bypass route-summon (HUKUM 13 hanya bahasa bebas)

## GERBANG
- Prompt biasa ditanggapi dengan summon agent/skill = DILARANG
- Prompt FULL diperlakukan ULTRA (summon semua) = DILARANG
- Prompt ULTRA (summons) dijawab jalur NORMAL = DILARANG
- Prompt biasa dipaksa ULTRA = DILARANG — boros
- `run.sh` gak ada / exit ≠ 0 → jalur dianggap NORMAL

## INTEGRASI PIPELINE
```
USER PROMPT → ROUTE ← posisi skill ini → SCAN/THINK/PLAN/EXECUTE
```
- Sebelum: user prompt
- Sesudah: eksekusi sesuai jalur
- Berkaitan: `skill scan` (peta project), `skill think` (analisa), `skill plan` (rencana)

## EDGE CASE
- Prompt ambigu → ambil NORMAL, bila perlu konfirmasi
- Route salah →自我修正, update regex di run.sh
- User berubah pikiran → route ulang

## ERROR HANDLING
- run.sh tidak ada → jalur dianggap NORMAL, catat di SELAIN
- run.sh exit ≠ 0 → jalur dianggap NORMAL, catat di SELAIN
- Tidak yakin jalur → konservatif: NORMAL

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Prompt biasa ditanggapi ULTRA → boros, bukan loyal
- ❌ Prompt ULTRA dijawab NORMAL → user minta semua, kasih semua
- ❌ Skip route → semua tugas dianggap sama
- ❌ Route salah → periksa regex di run.sh
- ❌ Route menentukan kualitas → route menentukan CAKUPAN, kualitas = konstan
