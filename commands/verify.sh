#!/usr/bin/env bash
# verify — run full verification (lint+self+eval+e2e+demo+mutation+bench+audit+doctor)
# Usage: bash commands/verify.sh
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
ok(){ p "  ✔ $1" 82; }
bad(){ p "  ✖ $1" 196; }
FAIL=0

p "═══ VERIFY — FULL GATE CHECK ═══" 213

run_gate() {
  local name="$1" cmd="$2"
  p "▶ $name" 213
  if eval "$cmd"; then
    ok "$name PASS"
  else
    bad "$name FAIL"
    FAIL=$((FAIL+1))
  fi
}

run_gate "LINT"     "bash $DIR/tests/lint-kit.sh"
run_gate "SELF"     "bash $DIR/tests/self-test.sh"
run_gate "EVAL"     "bash $DIR/tests/eval.sh"
run_gate "E2E"      "bash $DIR/tests/e2e-flow.sh"
run_gate "DEMO"     "bash $DIR/tests/run-demo.sh"
run_gate "UPDATE"   "bash $DIR/tests/test-update.sh"
run_gate "MUTATION" "bash $DIR/tests/mutation.sh"
run_gate "BENCH"    "bash $DIR/tests/bench.sh"
run_gate "AUDIT"    "bash $DIR/skills/audit-full/run.sh ."
run_gate "DOCTOR"   "bash $DIR/skills/doctor/run.sh ."

p "" 0
if [ "$FAIL" -eq 0 ]; then
  p "═══ VERIFY: SEMUA HIJAU ═══" 82
  exit 0
else
  p "═══ VERIFY: $FAIL GATE GAGAL — FIX DULU ═══" 196
  exit 1
fi
