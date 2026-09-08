---
description: MILESTONE — pecah tugas besar jadi milestone bernomor dengan bukti per milestone. Tiap milestone = plan 8 blok mini + test + laporan pendek.
---

# MILESTONE

Tugas besar ≠ plan raksasa. Tugas besar = deretan milestone kecil yang masing-masing bisa dibuktikan.

## KAPAN
Plan > 15 baris, tugas > 10 file, atau > 1 hari kerja. (Selaras: skill plan pecah sub-tugas, skill cost tanda tugas besar.)

## CARA
1. **PETA** — pecah jadi milestone bernomor M1..Mn. Urutan: yang tidak bergantung dulu.
2. **DEFINISI** — tiap milestone WAJIB punya bukti selesai terukur: test N/N PASS, audit CLEAN, file X jadi.
3. **PAPAN** — tulis papan status: `M1 [SELESAI] M2 [JALAN] M3 [ANTRE]` — update tiap selesai satu.
4. **EKSEKUSI** — satu milestone = satu plan 8 blok mini = satu putaran test/audit penuh.
5. **GERBANG** — milestone belum hijau → milestone berikutnya DILARANG mulai. Tanpa tombol skip.
6. **LAPOR** — papan akhir + ringkas per milestone (1 baris per M).

## FORMAT PAPAN (update tiap fase)
```
M1 [SELESAI] auth core — test 5/5
M2 [JALAN  ] session + middleware
M3 [ANTRE  ] UI login + test e2e
```

## GERBANG
- Bukti milestone mengada-ada (tanpa exit code) = GAGAL.
- Scope creep antar milestone → masuk milestone baru, bukan diselipkan.
