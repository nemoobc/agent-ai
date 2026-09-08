# CHANGELOG

## [Unreleased]

## [2.3.0] — 2026-09-08
### Added
- `install.sh --update` — update otomatis dari GitHub (unduh tarball master, banding versi, install ulang, memori aman)
- `install.sh --version` + cek versi remote non-blokir di tiap install (offline aman, timeout 3s)
- VERSION tercatat di instalasi → `--check` dan doctor kini tampilkan versi terpasang + deteksi drift
- `test-full`: +7 stack (bun, deno, ruby rake/rspec, elixir mix, JVM mvnw/gradlew/mvn, .NET dotnet, swift) — total 12
- `audit-full`: cargo fmt --check + clippy (opsional) untuk project Rust

## [2.2.0] — 2026-09-08
### Added
- Skill `doctor` (SKILL.md + run.sh) + command `/doctor` — diagnosa lingkungan, dependensi opsional, typecheck, memori + deteksi secret di memori (P0)
- `audit-full`: +8 pola secret baru (Anthropic, GitHub OAuth/App, Google, GitLab, DigitalOcean, npm) + shellcheck opsional untuk script shell
- Release workflow: tag `v*` → self-test sebagai gate → GitHub Release otomatis dari CHANGELOG
- `tests/run-demo.sh` — demo 60 detik: fixture bugged → test merah → fix → hijau → audit CLEAN (section DEMO di README)

### Fixed
- `doctor/run.sh`: fungsi warn kena `set -u` bila dipanggil sebelum init
- `run-demo.sh`: ganti `sed -i`/`perl` → pure bash heredoc (Termux/macOS aman)

## [2.1.0] — 2026-09-08
### Added
- `install.sh --check` — verifikasi kesehatan instalasi (tanpa menulis file)
- `install.sh --project` kini backup AGENTS.md project (marker-detected) + prune instalasi lama
- Self-test kini juga mengunci badge VERSION README ke file VERSION

### Fixed
- Path README `skills/` → `skill/` (sesuai installer & agents)
- `agents/dev.md` description belum menyebut pipeline v2

### Changed
- AGENTS.md HUKUM 4 + `/ship` disinkron penuh dengan pipeline 11 fase

## [2.0.0] — 2026-09-08
### Added
- Skill baru: `debug`, `scan`, `plan`, `doc-full` — pipeline 100% tercover
- Command `/audit` — simetris dengan /ship, /fix, /memory
- `VERSION` + `CHANGELOG.md` + `tests/self-test.sh` + CI GitHub Actions
- Skill `caveman` level ULTRA: marker wajib, budget baris, blacklist kata lunak
- agents: gerbang fase di dev, aturan flaky di tester, scope creep di coder, gerbang P0/P1 di auditor

### Fixed
- False-positive `npm audit` di audit-full (grep angka vuln ≥1, bukan kata)
- SKILL.md audit-full & fix-full tanpa command jalan
- `command/fix.md` — `$ARGUMENTS` salah tempat
- Uninstall: config buatan DEV-BRAIN dihapus, config user di-restore (marker `"devbrain"`)
- tsc guard, regex password lebih ketat, pattern TODO hanya bentuk komentar
- Typo "arsispace" → "arsipkan"

### Changed
- Permission bash granular: allowlist skill/run.sh + git read-only, sisanya `ask`
- Installer prune instalasi lama, backup HANYA config user (bukan config kit)
- prettier glob `**` + hormati .gitignore

## [1.0.0] — rilis awal
- 7 agent, 8 skill, 3 command, memori persisten, installer
