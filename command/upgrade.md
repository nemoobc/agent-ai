---
description: UPGRADE — update DEV-BRAIN dengan aman: --update → --check → lint → lapor. Memori tetap aman.
agent: dev
---
TUGAS: $ARGUMENTS

1. `bash install.sh --update` (unduh master, banding versi, install ulang, memori aman).
2. `bash install.sh --check` — instalasi sehat.
3. Bila kit repo ini tersedia: `bash tests/lint-kit.sh` + `bash tests/self-test.sh` — verifikasi struktur & detektor.
4. Lapor: versi lama → baru, status check, hasil lint/self-test.
5. Bila update menolak (sudah terbaru / remote tidak lebih baru) → lapor saja, jangan paksa (anti-downgrade sudah built-in).

## Usage

```
/upgrade
```

- Tidak ada argument — update ke versi terbaru dari remote.

## Triggers

- **bash install.sh --update** — update otomatis
- **bash install.sh --check** — validasi instalasi
- **bash tests/lint-kit.sh** — verifikasi struktur
- **bash tests/self-test.sh** — verifikasi detektor

## Example

```
/upgrade
```

## Expected Output

```
UPGRADE: SELESAI
├── VERSION: 1.2.3 → 1.3.0
├── CHECK: ALL PASS (skills, commands, agents)
├── LINT: LOLOS (24 cek)
├── SELF-TEST: PASS (56 cek)
└── STATUS: upgrade berhasil, memori aman
```

## Error Cases

- **Sudah versi terbaru** → lapor "sudah terbaru, tidak ada yang di-update"
- **Remote lebih tua** → anti-downgrade menolak
- **Update gagal** → lapor error + saran manual
- **Memory corrupt setelah update** → backup + restore

## Related Commands

- `/bootstrap** — pasang dari awal
- `/doctor** — diagnosa setelah upgrade
- `/verify** — verifikasi penuh setelah upgrade
