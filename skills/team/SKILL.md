---
description: TEAM — kerja paralel: pecah kerja jadi unit tak-bergantung, antrean sub-agent, verifikasi ulang, merge hasil. Satu niat per unit.
---

# TEAM

Satu antrian itu lambat. Kerja yang tak saling bergantung bisa jalan berdampingan — asal hasilnya diverifikasi ulang.

## KAPAN
Plan punya ≥ 3 unit kerja yang TIDAK saling menunggu (file/set area berbeda).
Yang saling menunggu tetap serial (skill milestone).

## CARA
1. **PECAH** — unit per area/file. Syarat: tak ada 2 unit menyentuh file yang sama.
2. **ANTREAN** — lempar tiap unit ke sub-agent serentak (architect/coder). Satu unit = satu niat = satu laporan.
3. **VERIFIKASI ULANG** — hasil paralel = dugaan sampai diverifikasi: skill test-full + audit-full menyatukan semuanya.
4. **MERGE** — bentrok (2 unit ubah file sama) → pilih satu arah, unit yang kalah diredo serial.
5. **LAPOR** — papan: unit → status → bukti.

## FORMAT PAPAN
```
U1 [SELESAI] module auth — test 4/4
U2 [SELESAI] module utils — test 3/3
U3 [JALAN  ] module UI
MERGE : test penuh 12/12, audit CLEAN
```

## GERBANG
- 2 unit menyentuh file sama = salah pecah → pecah ulang, jangan didorong paksa.
- Hasil paralel tanpa verifikasi ulang penuh = DILARANG dilapor SELESAI.
- Unit gagal → jangan tunda: fixer sekarang, paralel berhenti sampai aman.
