# MEMORY — DEV-BRAIN (ingatan jangka panjang)

## 2026-09-08 — Distribusi v2.3.0 (auto-update + multi-bahasa)
- konteks: user minta lagi — level berikutnya = jangkauan & distribusi
- keputusan: install.sh --update (tarball GitHub, banding versi, memori aman), --version, cek versi remote non-blokir, VERSION tercatat di instalasi, test-full +7 stack (bun/deno/ruby/elixir/JVM/.NET/swift), audit-full + cargo fmt/clippy
- pembelajaran: sort -V untuk compare semver di bash murni; UJI update-flow dengan remote ASLI langsung menangkap bug downgrade (remote 2.0.0 < lokal 2.3.0 tetap terinstall) — testing terhadap sistem nyata > testing terhadap mock

## 2026-09-08 — Showcase v2.2.0 (tantangan "tunjukkan kemampuan")
- konteks: user tantang tunjukkan semua kemampuan — bukan cuma nambah file md
- keputusan: skill doctor (run.sh + SKILL.md + /doctor), audit-full +8 pola secret & shellcheck opsional, release workflow (tag→test→GitHub Release dari CHANGELOG), tests/run-demo.sh (pipeline dibuktikan hidup: fixture bugged→merah→fix→hijau→CLEAN)
- pembelajaran: nilai kit = yang bisa EKSEKUSI, bukan yang bisa didokumentasi; self-test menangkap drift badge VERSION saat upgrade → gate-nya bekerja nyata; `set -u` menangkap bug fungsi warn yang akses var tak didefinisi; sed -i/perl tidak portable (Termux/macOS) → pakai heredoc bash murni

## 2026-09-08 — Upgrade kit v2.0.0 (paket SEMUANYA)
- konteks: user pilih paket lengkap — skill baru + caveman ULTRA + mateng agents + struktur
- keputusan: 4 skill baru (debug/scan/plan/doc-full) biar pipeline 100% tercover; TIDAK tambah agent (7 cukup, tambah agent = overhead); gerbang fase keras di dev.md; command /audit; VERSION 2.0.0 + CHANGELOG
- pembelajaran: skill = leverage murah, agent = biaya orkestrasi; badge README kini dikunci self-test (badge ≠ isi repo = FAIL); bash ls dengan glob ke-quote ("*.md") jadi literal → count 0

## 2026-09-10 — Rombak README + animasi install append-only v8.2.0
- konteks: user "panggil semuanya full, rombak full readme md buat baru, animasi installnya rombak lagi yang baru buat full animasi ada animasi loadingnya tanpa timpa teks" → ROUTE ULTRA (panggil semuanya), 9 subagent dipanggil (architect/explore/hermes-research/memory/coder-x2/hermes-docs/tester/auditor/fixer/critic-x2)
- keputusan: README 1214→231 baris 10 section fresh (badge tunggal header :7-10, footer teks manusia :227); install 472→595 baris anim append-only (banner_reveal/ph/pdone/dots/spin/pbar, --no-anim/NO_ANIM, trap, can_anim TTY/CI/NO_ANIM/dumb/NO_COLOR) + MAIN propagasi exit1; VERSION 8.2.0 + CHANGELOG + README.en sync; self-test ketat varian-unik (badge ganda/beda FAIL)
- pembelajaran: badge tunggal parsable + test sort -u; MAIN if || exit 1; animasi append-only newline + auto-disable non-TTY; angka: lint 240 LOLOS, self 174 PASS, eval 18/8 PASS, e2e 7 UTUH, demo 6 TERBUKTI, update 5 TERBUKTI, mutation 12/12, audit CLEAN, doctor SEHAT, critic CLEAN (VETO 2 tertutup)

Format entry (ditulis otomatis oleh DEV di akhir tugas penting):

## YYYY-MM-DD — judul singkat
- konteks:
- keputusan:
- pembelajaran:

## 2026-09-08 — Audit penuh + perbaikan agent-ai
- konteks: repo agent-ai = kit konfigurasi opencode (agents/skills/command/memory + install.sh), branch master, remote nemoobc/agent-ai
- keputusan: perbaiki 14 temuan audit — false-positive npm audit, permission bash granular (allowlist run.sh + git read-only), uninstall bersih, tsc guard, regex password ketat, pattern TODO komentar, LICENSE MIT, self-test suite, CI Actions
- pembelajaran: output sehat `npm audit` tetap mengandung kata "vulnerabilities" → grep harus menuju angka ≥1; installer yang menulis config wajib punya marker ("devbrain") supaya uninstall bisa bedakan config milik kit vs config user

## 2026-09-10 — install 1-baris-per-file (okbar/errbar) v8.2.0
- konteks: user "animasi loading berjalan, teksnya masih nimpa, full panggil semuanya" → ROUTE ULTRA; bukti hermes: output --offline 232 baris, 96 pasang ok+pbar label sama
- keputusan: gabung ok+pbar jadi okbar/errbar 1 baris (232→136 baris); _FAIL lanjut-lalu-exit1 + pesan "ulangi install"; SKILL.md wajib; counter-nol → exit1; pbar mati dihapus; CHANGELOG entry (VERSION tetap 8.2.0)
- pembelajaran: cetak ganda ok+pbar dibaca sebagai nimpa; fail-fast tinggalkan setengah-tulis → kumpul-akhir-exit1; glob-nol butuh guard counter; angka: lint 240, self 174, eval 18/8, e2e 7, demo 6, update 5, mutation 12/12, bench 6 PASS, audit CLEAN, doctor SEHAT, critic CLEAN (VETO 2 tertutup)
