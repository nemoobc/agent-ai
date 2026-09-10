#!/usr/bin/env bash
# notify/run.sh — cek konfigurasi notifikasi yang tersedia
set -u
echo "  ▸ notification channels:"
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then echo "  ✔ Slack webhook"; else echo "  · Slack: set SLACK_WEBHOOK_URL"; fi
if [ -n "${DISCORD_WEBHOOK_URL:-}" ]; then echo "  ✔ Discord webhook"; else echo "  · Discord: set DISCORD_WEBHOOK_URL"; fi
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "  ✔ Telegram bot"
else
  echo "  · Telegram: set TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID"
fi
if [ -n "${SMTP_HOST:-}" ]; then echo "  ✔ Email SMTP"; else echo "  · Email: set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS"; fi
echo "  → minimum: 1 channel active"