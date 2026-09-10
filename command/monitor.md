---
description: monitor — health check, uptime, alert threshold via DEV
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan skill monitor: pantau service, deteksi anomali, trigger alert saat down.

## Usage

```
/monitor [target] [opsi]
```

- `target` — URL service, port, atau endpoint untuk dipantau
- `opsi` — once (sekali), watch (continuously), status (cek terakhir)

## Triggers

- **skill monitor** — health check + anomali detection
- **skill notify** — trigger alert saat down

## Example

```
/monitor http://localhost:3000/health once
/monitor http://api.example.com status
/monitor localhost:5432 watch
```

## Expected Output

```
MONITOR: http://localhost:3000/health
├── STATUS: UP (200 OK)
├── LATENCY: 45ms
├── UPTIME: 99.97% (last 24h)
├── LAST CHECK: 2026-09-10 14:30:00
└── ALERTS: 0 active
```

## Error Cases

- **Target tidak merespons** → trigger alert + lapor DOWN
- **Timeout** → retry 1x, lapor latency tinggi
- **Skill tidak tersedia** → fallback curl manual

## Related Commands

- `/notify` — kirim alert ke channel
- `/hotfix** — bila DOWN = produksi rusak
- `/status** — status project (bukan service)
