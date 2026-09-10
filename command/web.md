---
description: web — browser automation: scrape, screenshot, isi form, testing via DEV
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan skill web: otomatisasi browser — navigasi, screenshot, ekstrak data, atau isi form.

## Usage

```
/web [aksi] [target]
```

- `aksi` — navigate, screenshot, scrape, fill, click, wait
- `target` — URL atau selector

## Triggers

- **skill web** — otomatisasi browser
- **skill notify** — kirim screenshot/alert

## Example

```
/web screenshot https://example.com
/web scrape https://api.github.com/repos/user/repo
/web navigate https://localhost:3000
/web fill "input[name=email]" "user@example.com"
```

## Expected Output

```
WEB: SELESAI
├── AKSI: screenshot
├── TARGET: https://example.com
├── HASIL: screenshot_2026-09-10.png (1920x1080, 245KB)
├── STATUS: success
└── DURATION: 3.2s
```

## Error Cases

- **URL tidak valid** → lapor "URL tidak valid"
- **Selector tidak ditemukan** → lapor "element tidak ditemukan: [selector]"
- **Timeout** → retry 1x, lapor
- **Browser tidak tersedia** → lapor dependency yang dibutuhkan

## Related Commands

- `/monitor** — health check (bukan visual)
- `/data** — analisis data hasil scrape
- `/notify** — kirim screenshot ke channel
