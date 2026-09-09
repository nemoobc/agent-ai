---
description: ROUTE — router intensitas: klasifikasi prompt user jadi jalur NORMAL / FULL / ULTRA sebelum eksekusi. Respon default = biasa (tanpa panggil agent/skill/caveman); skill hanya bila dibutuhkan; summons eksplisit ("panggil semuanya") = PANGGIL SEMUA — 9 agent + hermes + caveman ULTRA. FASE 0 pipeline.
---

# ROUTE (FASE 0 — ROUTER INTENSITAS)

Satu klasifikasi, tiga jalur. Sumber kebenaran = `run.sh` (detektor kata pemicu). Default semua tugas = NORMAL.

## URUTAN
1. Ambil prompt user mentah → `bash skills/route/run.sh "<prompt>"` — output jalur + alasan.
2. Jalur menentukan cakupan, bukan mood:
   - **NORMAL** — respon biasa: jawab/kerja langsung, tanpa delegasi agent, tanpa marker pipeline, gaya bicara biasa. Skill hanya kalau dibutuhkan nyata (test, git-guard, debug). User tanya/minta hal biasa → perlakukan biasa.
   - **FULL** — kerja lebih dalam: riset + test + dok + critic ringan. Respon TETAP biasa (bukan caveman), delegasi seperlunya bila kerjanya beneran butuh. BUKAN summon.
   - **ULTRA** — PANGGIL SEMUA: 9 agent terdaftar (architect/coder/tester/auditor/fixer/critic/hermes/memory) + caveman mode ULTRA + skill gerbang wajib (scan/think/imagine/plan/test-design/estimate/milestone/threat-model/red-team/test-full/audit-full/fix-full/doc-full/critique/clean/deliver). Verifikasi penuh 10 gerbang SEBELUM lapor.
3. Pemicu ada 2 kelas (daftar eksekusi = regex di `run.sh`, satu sumber; di sini contoh — kosakata luas, ID + EN):
   - **KELAS ULTRA** = SUMMONS eksplisit: "panggil/kerahkan/summon + semua/semuanya/all (+ agent/skill/kemampuan/tim)", "tunjukkan/pamerin semua kemampuan/bakat(mu)", "kemampuanmu/bakatmu", "gabungin semua", "ultra/ultra mode", "all-out", "mode terkuat", "gpt-5/6".
   - **KELAS FULL** = minta kerja lebih dalam: "lengkapin/lengkapi", "bagusin/perbagus", "matangkan", "sempurnakan", "upgrade", "maksimalkan", "pertajam/perdalam/pertebal", "rapikan", "tuntaskan/kerjain abis", "lebih detail/dalam", "full" — TETAP respon biasa, TIDAK summon agent.
   - Kalimat biasa yang kebetulan mengandung kata mirip ("dia punya bakat coding", "show off dikit") → NORMAL — konteks kalimat menang (lihat eval).
4. Konflik → ambil tertinggi. Prompt gak match → NORMAL.
5. Jalur tertulis di GODOK blok 1 + marker `[ROUTE]` di laporan. Caveman ULTRA hanya nyala di jalur ULTRA.

## FORMAT
```
[ROUTE] <jalur> — pemicu: <kata/frasa> (<kelas>)
```

## GERBANG
- Prompt biasa ditanggapi dengan summon agent/skill = DILARANG — respon biasa dulu, skill menyusul hanya bila dibutuhkan.
- Prompt FULL diperlakukan ULTRA (summon semua) = DILARANG — kerja lebih dalam ≠ parade agent.
- Prompt ULTRA (summons) dijawab jalur NORMAL = DILARANG — user minta semua, kasih semua.
- Prompt biasa dipaksa ULTRA = DILARANG — boros, bukan kesetiaan.
- `run.sh` gak ada / exit ≠ 0 → jalur dianggap NORMAL, catat di SELAIN.
- Route hanya menentukan CAKUPAN — hukum, gerbang, bukti tetap sama semua jalur.
