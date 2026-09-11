---
description: allow-all — buka semua izin opencode dengan animasi & backup otomatis
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan pembukaan izin penuh dengan animasi: backup `opencode.json` dulu, tulis konfigurasi allow-all, tampilkan hasil dengan box animation. Via shell: `bash commands/allow-all.sh`.

## Usage

```
/allow-all
```

## Triggers

- **bash commands/allow-all.sh** — eksekusi langsung dari shell
- **skill autonomy** — DEV tetap patuh HUKUM 5

## Example

```
/allow-all

╔══════════════════════════════════════════════════════════╗
║         🔓 ALLOW-ALL — BUKA SEMUA IZIN                  ║
╚══════════════════════════════════════════════════════════╝

  ✔ Memeriksa folder config...
  ✔ Backup tersimpan: ~/.config/opencode/opencode.json.bak.xxx
  ✔ Menulis konfigurasi allow-all...

╔══════════════════════════════════════════════════════════╗
║                   HASIL IZIN                             ║
╠══════════════════════════════════════════════════════════╣
  ✔ EDIT     : allow
  ✔ WRITE    : allow
  ✔ WEBFETCH : allow
  ✔ BASH     : * → allow
╚══════════════════════════════════════════════════════════╝

  🔓 SEMUA IZIN TERBUKA — SIAP KERJA!
```

## Expected Output

```
ALLOW-ALL: SEMUA IZIN TERBUKA
├── BACKUP : <path backup>
├── IZIN   : edit/write/webfetch/bash(*) = allow
└── REVERT : mv <backup> opencode.json
```

## Error Cases

- **opencode.json tidak bisa ditulis** → lapor path + izin folder
- **Folder config tidak ada** → buat `~/.config/opencode/` dulu
- **User minta revert** → pulihkan backup terbaru

## Related Commands

- `/bootstrap` — pasang DEV-BRAIN ke project
- `/status` — cek status instalasi + izin
- `/doctor` — cek kesehatan kit
