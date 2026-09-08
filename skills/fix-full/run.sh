#!/usr/bin/env bash
# AUTO FIX FULL — format + lint-fix + re-test
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

p "▮ FIX: formatter" 213
[ -x node_modules/.bin/prettier ] && { node_modules/.bin/prettier --write "**/*.{js,ts,jsx,tsx,json,css,md}" --ignore-path .gitignore >/dev/null 2>&1 && p "  ✔ prettier" 82; }
command -v black >/dev/null 2>&1 && { black --quiet . >/dev/null 2>&1 && p "  ✔ black" 82; }
[ -f go.mod ] && command -v go >/dev/null 2>&1 && { gofmt -w . >/dev/null 2>&1; p "  ✔ gofmt" 82; }

p "▮ FIX: linter" 213
[ -x node_modules/.bin/eslint ] && { node_modules/.bin/eslint . --fix >/dev/null 2>&1; p "  ✔ eslint --fix" 82; }
command -v ruff >/dev/null 2>&1 && { ruff check . --fix --quiet >/dev/null 2>&1; p "  ✔ ruff --fix" 82; }

p "▮ FIX: re-test" 213
bash "$DIR/../test-full/run.sh" "$ROOT"
exit $?
