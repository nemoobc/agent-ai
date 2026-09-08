---
description: HOTFIX — produksi rusak, prioritas satu: stop bleeding → repro → fix sempit → bukti → verify → postmortem. Tanpa eksperimen.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill hotfix — jalankan urutan krisis: STOP BLEEDING → REPRO (debug) → FIX SEMPIT → BUKTI (test merah→hijau) → git-guard → /verify.
2. Satu niat saja. Perubahan lain = commit terpisah, DILARANG dibawa.
3. Setelah hijau: postmortem → lessons.md (mengapa lolos, pencegahan).
4. Lapor format HOTFIX. Bila > 30 menit tanpa progress → lapor status + bukti ke user.