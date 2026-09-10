---
description: Jalankan serangan adversarial critic ke hasil kerja sebelum lapor SELESAI
agent: dev
---
TUGAS: /critique

1. Kumpulkan klaim yang akan dilaporkan (status, angka test, file, fitur).
2. Panggil task `critic` — serang 5 tembakan: spesifikasi → logika → bukti → skenario tak-teruji → gap.
3. Output: daftar `[VETO|TEMUAN|CATATAN] temuan — bukti (file:baris/exit code)`.
4. VETO ada → task `fixer` → ulang critique → sampai `VERDICT: CLEAN`.
5. Lapor singkat caveman + rantai bukti (HUKUM 11).

## Usage

```
/critique
```

- Tidak ada argument — serang klaim terakhir yang akan dilaporkan.

## Triggers

- **task critic** — serangan adversarial 5 tembakan
- **task fixer** — perbaiki VETO yang ditemukan
- **HUKUM 11** — rantai bukti wajib untuk setiap klaim

## Example

```
/critique
```

## Expected Output

```
CRITIQUE — 5 tembakan
├── [TEMUAN] Spesifikasi: test tidak cover edge case login — tests/auth.js:23
├── [TEMUAN] Logika: race condition di concurrent update — src/lock.js:45
├── [CATATAN] Bukti: exit code cocok tapi coverage rendah
├── [TEMUAN] Skenario: retry mechanism tidak diuji
└── [VETO] Gap: error 500 tidak di-test sama sekali — src/api.js:67
VERDICT: 4 TEMUAN + 1 VETO → task fixer → ulang
```

## Error Cases

- **Tidak ada klaim aktif** → lapor "tidak ada yang dikritik, jalankan tugas dulu"
- **critic agent tidak tersedia** → fallback manual serangan 5 tembakan
- **VETO ditemukan tapi fixer gagal** → lapor status + minta user putuskan

## Related Commands

- `/audit** — serangan otomatis sebelum kritis manual
- `/verify** — critique masuk pipeline verify
- `/trace** — buktikan klaim sebelum dikritik
