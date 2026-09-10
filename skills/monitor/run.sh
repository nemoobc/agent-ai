#!/usr/bin/env bash
# monitor/run.sh — cek tooling monitoring yang tersedia
set -u
MODE="${1:-check}"
echo "  ▸ monitoring tools:"
command -v curl >/dev/null 2>&1 && echo "  ✔ curl: $(curl --version 2>&1 | head -1)"
command -v nc >/dev/null 2>&1 && echo "  ✔ nc (netcat)" || echo "  · nc tidak ada"
command -v wget >/dev/null 2>&1 && echo "  ✔ wget" || true
command -v ping >/dev/null 2>&1 && echo "  ✔ ping" || true

if [ "${MODE:-check}" = "run" ]; then
  URL="${2:-}"
  [ -z "$URL" ] && { echo "  ✖ usage: $0 run <URL>"; exit 1; }
  echo "  ▸ cek $URL ..."
  STATUS=$(curl -o /dev/null -s -w '%{http_code}' --connect-timeout 5 --max-time 10 "$URL" 2>/dev/null)
  if [ "$STATUS" = "200" ]; then echo "  ✔ $URL → HTTP $STATUS"; exit 0
  else echo "  ✖ $URL → HTTP ${STATUS:-timeout}"; exit 1; fi
fi
exit 0