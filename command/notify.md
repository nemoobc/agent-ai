---
description: notify — kirim notifikasi ke Email/Slack/Discord/Telegram via DEV
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan skill notify: kirim update atau alert ke channel yang kamu pilih.

## Usage

```
/notify [channel:pesan]
```

- `channel` — email, slack, discord, telegram. Kosong = default (telegram).
- `pesan` — isi notifikasi

## Triggers

- **skill notify** — pengiriman notifikasi
- **skill monitor** — trigger dari alert down

## Example

```
/notify slack:build selesai, test 24/24 PASS
/notify email:hotfix login endpoint dipush ke staging
/notify telegram:deploy produksi selesai
```

## Expected Output

```
NOTIFY: SELESAI
├── CHANNEL: slack
├── PESAN: "build selesai, test 24/24 PASS"
├── STATUS: delivered
└── TIMESTAMP: 2026-09-10 14:30:00 UTC
```

## Error Cases

- **Channel tidak dikonfigurasi** → lapor "konfigurasi [channel] tidak ditemukan"
- **API key tidak ada** → lapor "API key [channel] belum diset"
- **Jaringan down** → lapor "gagal mengirim, coba lagi nanti"

## Related Commands

- `/monitor** — trigger notifikasi dari alert
- `/release** — notifikasi saat rilis selesai
- `/hotfix** — notifikasi saat hotfix selesai
