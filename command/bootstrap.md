---
description: BOOTSTRAP — pasang DEV-BRAIN ke project ini TANPA install global: .opencode/ project + AGENTS.md project-level.
agent: dev
---
TUGAS: $ARGUMENTS

1. Cek `~/.config/opencode/` — bila DEV-BRAIN sudah terpasang global → lanjut langkah 3.
2. Belum ada → jalankan `bash install.sh` dulu (installer kit ini).
3. Jalankan `bash install.sh --project .` → tulis `.opencode/` di project ini + AGENTS.md project-level.
4. `bash install.sh --check` → pastikan instalasi sehat.
5. Lapor gaya caveman: file yang ditulis, status check, cara pakai (buka opencode di folder ini).

## Usage

```
/bootstrap
```

- Tidak ada argument — bootstrap ke direktori kerja saat ini.

## Triggers

- **install.sh** — installer kit DEV-BRAIN
- **install.sh --project .** — tulis .opencode/ level project
- **install.sh --check** — validasi instalasi

## Example

```
/bootstrap
```

## Expected Output

```
BOOTSTRAP: SELESAI
├── ~/.config/opencode/DEV-BRAIN.md    → terpasang (global)
├── .opencode/                          → terpasang (project)
├── AGENTS.md                           → terpasang (project-level)
├── CHECK: ALL PASS (skills, commands, agents)
└── CARA PAKAI: buka opencode di folder ini, jalan /ship
```

## Error Cases

- **install.sh tidak ditemukan** → lapor "install.sh missing, clone repo dulu"
- **--check gagal** → lapor detail check yang fail
- **Permission ditolak** → lapor izin yang dibutuhkan
- **--project di luar repo** → konfirmasi user (HUKUM 5)

## Related Commands

- `/upgrade` — update DEV-BRAIN yang sudah terpasang
- `/doctor** — diagnosa lebih dalam
- `/onboard** — peta project untuk agent/user baru
