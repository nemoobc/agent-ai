#!/usr/bin/env bash
# web/run.sh — cek tooling browser automation yang tersedia
set -u
echo "  ▸ browser automation tools:"
command -v playwright >/dev/null 2>&1 && echo "  ✔ playwright" || echo "  · playwright: npx playwright install"
command -v puppeteer >/dev/null 2>&1 && echo "  ✔ puppeteer" || echo "  · puppeteer: npm i puppeteer"
command -v chromium >/dev/null 2>&1 && echo "  ✔ chromium" || echo "  · chromium: sudo apt install chromium-browser"
command -v chromium-browser >/dev/null 2>&1 && echo "  ✔ chromium-browser" || true
command -v google-chrome >/dev/null 2>&1 && echo "  ✔ google-chrome" || true
echo "  → gunakan npx playwright install chromium bila belum ada browser"