---
name: wake-lock
description: WAKE-LOCK — hidupkan termux-wake-lock otomatis saat AI mulai kerja, matikan saat selesai. No-op (exit 0) di luar Termux. Dipanggil pipeline: on sebelum eksekusi, off setelah lapor.
---
# WAKE-LOCK — layar tetap hidup saat AI kerja

## Tujuan
Saat user minta AI mengerjakan sesuatu (proses panjang: install, test, build), layar Termux jangan mati di tengah jalan. `termux-wake-lock` menahan lock; `termux-wake-unlock` melepasnya.

## Penggunaan
```bash
bash ~/.config/opencode/skills/wake-lock/run.sh on    # sebelum eksekusi tugas
bash ~/.config/opencode/skills/wake-lock/run.sh off   # setelah selesai/gagal/lapor
```

## Aturan pipeline (doktrin)
1. FASE 0 ROUTE setelah prompt masuk → **ON** (kalau route = NORMAL/FULL/ULTRA dan akan eksekusi kerja).
2. Segala selesai (SELESAI / TITIK-PUTUS / GAGAL) + laporan terkirim → **OFF**.
3. Percakapan biasa (bukan tugas) → jangan nyalakan (boros baterai).
4. Bukan Termux / `termux-wake-lock` tidak ada → no-op, tetap exit 0.

## Error Cases
| Kondisi | Perilaku |
|---------|----------|
| `termux-wake-lock` tidak ada | print skip, exit 0 (tidak menghambat pipeline) |
| `termux-wake-unlock` tidak ada | print skip, exit 0 |
| Argumen selain `on`/`off` | treat sebagai `on` + warning |
| Wake-lock gagal diaktifkan | print peringatan, exit 0 — AI tetap kerja |

## Related Commands
| Command | Kaitan |
|---------|--------|
| `/verify` | jalankan setelah semua gerbang |
| `/status` | lihat state AI |