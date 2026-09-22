# BACKLOG — agent-ai kit

Sumber: `/backlog` skill. Definisi selesai terukur di tiap item. Status: ANTRE / JALAN / SELESAI.

| ID | ITEM | SKOR | DEFINISI SELESAI | STATUS |
|----|------|------|------------------|--------|
| 1 | Deteksi OpenCode V1/V2 benar (channel Termux `opencode-termux`) | 20 | `detect_version` kembalikan v2 saat opencode-termux (upstream 2.x) terpasang — diuji unit test 3 kasus | SELESAI (12.2.2) |
| 2 | Anti-downgrade update flow | 18 | `install.sh --update` tolak versi lebih tua — diuji test-update.sh FLOW 2 | SELESAI (12.2.2) |
| 3 | Default permission granular (bukan allow-all) | 18 | install tanpa `--allow-all` → config `effect: ask` — diuji self-test | SELESAI (12.2.2) |
| 4 | Curl one-liner install & uninstall | 15 | `curl -fsSL …/curl-install.sh \| bash` pasang kit; `\| bash -s -- --uninstall` lepas — diuji dengan arsip lokal | SELESAI (12.3.0) |
| 5 | termux-wake-lock otomatis saat AI kerja | 16 | skill wake-lock on/off + doktrin dev.md/AGENTS.md; on saat mulai tugas, off saat selesai; no-op non-Termux | SELESAI (12.3.0) |
| 6 | Riset opencode.ai/v2/docs | 10 | docs/OPENCODE-V2.md memuat config, agents, skills, commands, permissions, cli.json + implikasi kit | SELESAI (12.3.0) |
| 7 | Instalasi nyata di Termux diuji ulang | 12 | `bash install.sh --check` sehat di perangkat nyata setelah 12.3.0 | ANTRE |

Skor = dampak (1–5) × usaha dibalik (1–5). Sumber: user, audit, perbaikan bug.