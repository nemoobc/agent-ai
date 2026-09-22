#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  WAKE-LOCK — termux-wake-lock on/off untuk sesi kerja AI.
#  on  : nyalakan wake-lock (layar tidak mati saat kerja)
#  off : matikan wake-lock
#  No-op (exit 0) di luar Termux / tanpa termux-wake-lock.
# ═══════════════════════════════════════════════════════════
set -uo pipefail

CMD="${1:-on}"
case "$CMD" in
  off|--off|-off)
    if command -v termux-wake-unlock >/dev/null 2>&1; then
      termux-wake-unlock >/dev/null 2>&1 && echo "WAKE-LOCK: OFF" || echo "WAKE-LOCK: gagal matikan (lanjut)"
    else
      echo "WAKE-LOCK: skip (termux-wake-unlock tidak ada)"
    fi
    ;;
  on|--on|-on|*)
    case "$CMD" in on|--on|-on) ;; *) echo "WAKE-LOCK: arg tak dikenal '$CMD' — treat sebagai on" ;; esac
    if command -v termux-wake-lock >/dev/null 2>&1; then
      termux-wake-lock >/dev/null 2>&1 && echo "WAKE-LOCK: ON" || echo "WAKE-LOCK: gagal aktifkan (lanjut)"
    else
      echo "WAKE-LOCK: skip (termux-wake-lock tidak ada)"
    fi
    ;;
esac
exit 0