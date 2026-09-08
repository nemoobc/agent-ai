# MEMORY — DEV-BRAIN (ingatan jangka panjang)

## 2026-09-08 — Upgrade kit v2.0.0 (paket SEMUANYA)
- konteks: user pilih paket lengkap — skill baru + caveman ULTRA + mateng agents + struktur
- keputusan: 4 skill baru (debug/scan/plan/doc-full) biar pipeline 100% tercover; TIDAK tambah agent (7 cukup, tambah agent = overhead); gerbang fase keras di dev.md; command /audit; VERSION 2.0.0 + CHANGELOG
- pembelajaran: skill = leverage murah, agent = biaya orkestrasi; badge README kini dikunci self-test (badge ≠ isi repo = FAIL); bash ls dengan glob ke-quote ("*.md") jadi literal → count 0

Format entry (ditulis otomatis oleh DEV di akhir tugas penting):

## YYYY-MM-DD — judul singkat
- konteks:
- keputusan:
- pembelajaran:

## 2026-09-08 — Audit penuh + perbaikan agent-ai
- konteks: repo agent-ai = kit konfigurasi opencode (agents/skills/command/memory + install.sh), branch master, remote nemoobc/agent-ai
- keputusan: perbaiki 14 temuan audit — false-positive npm audit, permission bash granular (allowlist run.sh + git read-only), uninstall bersih, tsc guard, regex password ketat, pattern TODO komentar, LICENSE MIT, self-test suite, CI Actions
- pembelajaran: output sehat `npm audit` tetap mengandung kata "vulnerabilities" → grep harus menuju angka ≥1; installer yang menulis config wajib punya marker ("devbrain") supaya uninstall bisa bedakan config milik kit vs config user
