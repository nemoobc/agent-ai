#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#  BENCH — ukur durasi tiap gerbang, deteksi drift (HUKUM 10).
#  Soft-warn di atas WARN_S, hard-cap di atas CAP_S (gagal).
#  Jalankan: bash tests/bench.sh   (exit 0 = semua gate di bawah cap)
# ═════════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")/.." && pwd)"
p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
WARN_S=30   # di atas ini = peringatan drift
CAP_S=90    # di atas ini = GAGAL (bench sendiri juga harus cepat)

total_s=0
PASS=0; FAIL=0

bench_gate(){ # $1=nama $2=cap_s(opsional, default CAP_S) $3=command...
  local name="$1"; shift
  local cap="$CAP_S"
  # bila argumen kedua numerik → itu cap khusus gate ini
  if [[ "$1" =~ ^[0-9]+$ ]]; then cap="$1"; shift; fi
  local t0 t1 dt
  t0=$(date +%s.%N 2>/dev/null || echo 0)
  "$@" >/dev/null 2>&1
  local rc=$?
  t1=$(date +%s.%N 2>/dev/null || echo 0)
  dt=$(awk -v a="$t0" -v b="$t1" 'BEGIN{printf "%.1f", b-a}' 2>/dev/null || echo 0)
  total_s=$(awk -v a="$total_s" -v b="$dt" 'BEGIN{printf "%.1f", a+b}' 2>/dev/null || echo "$total_s")
  local verdict="OK"
  [ "$rc" -ne 0 ] && verdict="RC$rc"
  if awk -v d="$dt" -v c="$cap" 'BEGIN{exit !(d>c)}' 2>/dev/null; then
    p "  ✖ $name: ${dt}s > cap ${cap}s ($verdict)" 196; FAIL=$((FAIL+1))
  elif awk -v d="$dt" -v w="$WARN_S" 'BEGIN{exit !(d>w)}' 2>/dev/null; then
    p "  ⚠ $name: ${dt}s (di atas soft-warn ${WARN_S}s, $verdict)" 214; PASS=$((PASS+1))
  else
    p "  ✔ $name: ${dt}s ($verdict)" 82; PASS=$((PASS+1))
  fi
}

p "▮ BENCH — durasi tiap gerbang (warn > ${WARN_S}s, gagal > ${CAP_S}s)" 213

# ── Gerbang inti kit ──
bench_gate "lint-kit"       bash "$DIR/tests/lint-kit.sh"
bench_gate "self-test"      bash "$DIR/tests/self-test.sh"
bench_gate "eval"           bash "$DIR/tests/eval.sh"
bench_gate "e2e-flow"       bash "$DIR/tests/e2e-flow.sh"
bench_gate "run-demo"       bash "$DIR/tests/run-demo.sh"
bench_gate "update-flow"    bash "$DIR/tests/test-update.sh"
bench_gate "mutation" 180   bash "$DIR/tests/mutation.sh"   # 15 mutasi penuh — cap lebih longgar

# ── Gerbang komponen ──
bench_gate "install --offline" bash -c "T=\$(mktemp -d); HOME=\"\$T\" bash \"$DIR/install.sh\" --offline; rm -rf \"\$T\""
bench_gate "doctor"         bash "$DIR/skills/doctor/run.sh" .
bench_gate "scan"           bash "$DIR/skills/scan/run.sh" "$DIR" 2>/dev/null || true

# ── Gerbang skills ringan ──
bench_gate "metrics"        bash "$DIR/skills/metrics/run.sh" "$DIR"
bench_gate "clean --dry"    bash "$DIR/skills/clean/run.sh" "$DIR" --dry
bench_gate "git-guard"      bash "$DIR/skills/git-guard/run.sh" "$DIR"

# ── Micro-bench: operasi tunggal cepat ──
bench_gate "bash -n install.sh" bash -n "$DIR/install.sh"
bench_gate "bash -n self-test.sh" bash -n "$DIR/tests/self-test.sh"
bench_gate "bash -n mutation.sh"  bash -n "$DIR/tests/mutation.sh"
bench_gate "bash -n eval.sh"      bash -n "$DIR/tests/eval.sh"
bench_gate "bash -n bench.sh"     bash -n "$DIR/tests/bench.sh"
bench_gate "bash -n lint-kit.sh"  bash -n "$DIR/tests/lint-kit.sh"

# ── Ringkasan ──
echo
p "▮ BENCH — ringkasan" 213
echo "  Total gerbang : $((PASS+FAIL))"
echo "  Pass          : $PASS"
echo "  Fail          : $FAIL"
echo "  Durasi total  : ${total_s}s"
echo "  Hard-cap      : ${CAP_S}s per gate"
echo "  Soft-warn     : ${WARN_S}s per gate"

echo
if [ "$FAIL" -eq 0 ]; then p "BENCH: PASS ($PASS gate aman, ${total_s}s total)" 82; exit 0; fi
p "BENCH: FAIL — $FAIL gate melewati hard-cap" 196; exit 1
