#!/usr/bin/env bash
# AUTO TEST FULL — deteksi bahasa & jalankan semua test
ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || exit 1
FAILED=0; RAN=0
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
try(){ p "  ▸ $*" 45; "$@" || FAILED=1; RAN=1; }

if [ -f package.json ]; then
  p "▮ Node project" 213
  if command -v npm >/dev/null 2>&1; then
    if grep -q '"test"[[:space:]]*:' package.json 2>/dev/null; then
      try npm test --silent
    else
      [ -x node_modules/.bin/vitest ] && try node_modules/.bin/vitest run
      [ -x node_modules/.bin/jest ]   && try node_modules/.bin/jest
      [ -x node_modules/.bin/mocha ]  && try node_modules/.bin/mocha
    fi
  fi
fi
if [ -f pyproject.toml ] || [ -f setup.py ] || compgen -G '*.py' >/dev/null 2>&1; then
  p "▮ Python project" 213
  command -v pytest >/dev/null 2>&1 && try pytest -q
fi
[ -f go.mod ] && { p "▮ Go project" 213; command -v go >/dev/null 2>&1 && try go test ./...; }
[ -f Cargo.toml ] && { p "▮ Rust project" 213; command -v cargo >/dev/null 2>&1 && try cargo test -q; }
[ -f composer.json ] && { p "▮ PHP project" 213; [ -x vendor/bin/phpunit ] && try vendor/bin/phpunit; }
command -v bun >/dev/null 2>&1 && [ -f bunfig.toml ] && { p "▮ Bun project" 213; try bun test; }
command -v deno >/dev/null 2>&1 && compgen -G '*_test.*' >/dev/null 2>&1 && { p "▮ Deno project" 213; try deno test; }
if { [ -f Gemfile ] || compgen -G 'spec/*_spec.rb' >/dev/null 2>&1 || compgen -G 'test/*_test.rb' >/dev/null 2>&1; }; then
  p "▮ Ruby project" 213
  command -v rake >/dev/null 2>&1 && rake -n test >/dev/null 2>&1 && try rake test
  command -v rspec >/dev/null 2>&1 && compgen -G 'spec/*_spec.rb' >/dev/null 2>&1 && try rspec
fi
[ -f mix.exs ] && { p "▮ Elixir project" 213; command -v mix >/dev/null 2>&1 && try mix test; }
{ [ -f pom.xml ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; } && { p "▮ JVM project" 213; [ -f mvnw ] && try sh ./mvnw -q test; [ -x gradlew ] && try sh ./gradlew -q test; [ -f pom.xml ] && command -v mvn >/dev/null 2>&1 && try mvn -q test; }
compgen -G '*.csproj' >/dev/null 2>&1 || compgen -G '*.sln' >/dev/null 2>&1 && { p "▮ .NET project" 213; command -v dotnet >/dev/null 2>&1 && try dotnet test; }
[ -f Package.swift ] && { p "▮ Swift project" 213; command -v swift >/dev/null 2>&1 && try swift test; }
if [ -f Makefile ] && make -n test >/dev/null 2>&1; then p "▮ make test" 213; try make test; fi

echo
if [ $RAN -eq 0 ]; then p "TEST_RESULT: NO-TESTS — framework test tidak ada, tulis test dulu" 214; exit 2; fi
if [ $FAILED -eq 0 ]; then p "TEST_RESULT: PASS ✓" 82; exit 0; fi
p "TEST_RESULT: FAIL ✗" 196; exit 1
