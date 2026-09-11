---
description: allow-all — buka semua izin opencode (edit/write/webfetch/bash = allow) dengan backup otomatis
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan pembukaan izin penuh: backup `opencode.json` dulu, tulis konfigurasi allow-all, lapor cara kembalikan. Via shell: `bash commands/allow-all.sh`.

## Usage

```
/allow-all
```

- Tanpa argumen — set semua izin ke `allow` (edit, write, webfetch, bash `*`)
- Backup lama otomatis dibuat: `opencode.json.bak.<timestamp>`

## Triggers

- **bash commands/allow-all.sh** — eksekusi langsung dari shell
- **skill autonomy** — DEV tetap patuh HUKUM 5 (destruktif/force-push/install/berbiaya tetap berhenti)

## Example

```
/allow-all

ALLOW-ALL: SEMUA IZIN TERBUKA
├── BACKUP : ~/.config/opencode/opencode.json.bak.1760000000
├── EDIT   : allow
├── WRITE  : allow
├── WEBFETCH: allow
├── BASH   : * → allow
└── REVERT : mv opencode.json.bak.1760000000 opencode.json
```

## Expected Output

```
ALLOW-ALL: SEMUA IZIN TERBUKA
├── BACKUP : <path backup>
├── IZIN   : edit/write/webfetch/bash(*) = allow
└── REVERT : mv <backup> opencode.json
```

## Error Cases

- **opencode.json tidak bisa ditulis** → lapor path + izin folder, jangan lanjut
- **Folder config tidak ada** → buat `~/.config/opencode/` dulu, lalu tulis
- **User minta revert** → pulihkan backup terbaru, lapor yang dipulihkan

## Related Commands

- `/bootstrap** — pasang DEV-BRAIN ke project
- `/status** — cek status instalasi + izin
- `/doctor** — cek kesehatan kit
