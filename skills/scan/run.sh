#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  SCAN-RUN — peta project dari shell: bahasa, framework, test,
#  entry point. Output blok peta, exit 0.
#  Jalankan: bash skill/scan/run.sh [dir]
# ═════════════════════════════════════════════════════════════════
set -u
ROOT="${1:-.}"; cd "$ROOT" 2>/dev/null || exit 1
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }

# 1. bahasa & manifest
LANG="?"
[ -f package.json ] && LANG="node"
[ -f pyproject.toml ] || [ -f requirements.txt ] && LANG="python"
[ -f go.mod ] && LANG="go"
[ -f Cargo.toml ] && LANG="rust"
[ -f composer.json ] && LANG="php"
[ -f Gemfile ] && LANG="ruby"
[ -f mix.exs ] && LANG="elixir"
[ -f pom.xml ] || [ -f build.gradle ] && LANG="java"
[ -f *.csproj ] 2>/dev/null && LANG="dotnet"

# 2. framework (heuristic dari manifest)
FW="?"
if [ -f package.json ]; then
  grep -q '"react"' package.json 2>/dev/null && FW="react"
  grep -q '"next"' package.json 2>/dev/null && FW="next"
  grep -q '"vue"' package.json 2>/dev/null && FW="vue"
  grep -q '"express"' package.json 2>/dev/null && FW="express"
fi
[ -f manage.py ] && FW="django"
[ -f Cargo.toml ] && grep -qi 'actix\|axum\|rocket\|tokio' Cargo.toml 2>/dev/null && FW="rust-web"

# 3. test framework
TF="?"
if [ -f package.json ]; then
  grep -qE '"(jest|vitest|mocha|playwright)"' package.json 2>/dev/null && TF=$(grep -oE '"(jest|vitest|mocha|playwright)"' package.json 2>/dev/null | head -1 | tr -d '"')
fi
[ -f pytest.ini ] || grep -q 'pytest' pyproject.toml 2>/dev/null && TF="pytest"
[ -f go.mod ] && TF="go test"
[ -f Cargo.toml ] && TF="cargo test"
[ -f phpunit.xml ] 2>/dev/null && TF="phpunit"
[ -f Rakefile ] 2>/dev/null && TF="rspec"

# 4. entry point
ENTRY="?"
[ -f package.json ] && ENTRY=$(grep -oE '"(main|bin)": *"[^"]+"' package.json 2>/dev/null | head -1)
[ -f manage.py ] && ENTRY="manage.py"
[ -f main.py ] && ENTRY="main.py"
[ -f src/main.rs ] && ENTRY="src/main.rs"
[ -f main.go ] && ENTRY="main.go"

# 5. struktur
STR=$(find . -maxdepth 1 -type d -not -path './.git' -not -path './node_modules' 2>/dev/null | sed 's|^\./||' | grep -v '^\.$' | sort | tr '\n' ' ')

p "▮ SCAN: $LANG / $FW / test:$TF" 213
p "  MANIFEST : $(ls package.json pyproject.toml go.mod Cargo.toml composer.json Gemfile mix.exs pom.xml build.gradle 2>/dev/null | tr '\n' ' ')" 45
p "  FRAMEWORK: $FW   TEST: $TF" 45
p "  ENTRY    : $ENTRY" 45
p "  STRUKTUR : ${STR:-—}" 45
p "SCAN_RESULT: blok di atas → skill scan & plan" 45
exit 0