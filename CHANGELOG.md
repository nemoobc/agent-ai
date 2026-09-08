# CHANGELOG

## [Unreleased]

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
