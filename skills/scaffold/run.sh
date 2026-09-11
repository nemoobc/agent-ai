#!/usr/bin/env bash
# scaffold/run.sh — cek tooling scaffold yang tersedia
set -u
echo "  ▸ scaffold tools:"
command -v node >/dev/null 2>&1 && echo "  ✔ node: $(node --version 2>&1)" || echo "  · node tidak ada"
command -v npm >/dev/null 2>&1 && echo "  ✔ npm: $(npm --version 2>&1)" || true
command -v npx >/dev/null 2>&1 && echo "  ✔ npx" || true
command -v bun >/dev/null 2>&1 && echo "  ✔ bun: $(bun --version 2>&1)" || echo "  · bun: curl -fsSL https://bun.sh/install | bash"
command -v deno >/dev/null 2>&1 && echo "  ✔ deno: $(deno --version 2>&1 | head -1)" || true
command -v go >/dev/null 2>&1 && echo "  ✔ go: $(go version 2>&1)" || echo "  · go: https://go.dev/dl"
command -v cargo >/dev/null 2>&1 && echo "  ✔ cargo: $(cargo --version 2>&1)" || echo "  · rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
command -v python3 >/dev/null 2>&1 && echo "  ✔ python3: $(python3 --version 2>&1)" || true
echo "  → framework: npx create-react-app / create-next-app / bun create vue / etc"