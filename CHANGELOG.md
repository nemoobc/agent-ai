# CHANGELOG

## [8.2.0] — 2026-09-09
### Added
- README rewrite 1214→229 baris, 11 section fresh
- install.sh full-animasi append-only: banner_reveal/ph/pdone/dots/spin/pbar + --no-anim + NO_ANIM + durasi
### Changed
- install.sh usage +2 baris
### Fixed
- Badge sinkron 11/56/33
- install.sh: log 1 baris per file (okbar/errbar), gagal copy = exit 1 + suruh ulangi
- installer menyalin agent/skill secara dinamis, PLAN runner menerima string/file, dan full gate mencakup audit + doctor
### Security
- Update jaringan wajib checksum SHA-256; permission catch-all tidak lagi menimpa aturan deny/ask
- Cost, recovery, deliver, dan PR guard memperketat input, arsip, dan publikasi

## [8.1.3] — 2026-09-10
### Fixed
- install.sh finish message: angka benar "9 agent • 56 skill (16 dengan bash script) • 31 command" (sebelumnya 8/53/14/27 — HUKUM 10 pelanggaran)
- README.en.md: "The 13 Laws" (sebelumnya "The 12 Laws")
- README.en.md: mutation.sh "12 ways" (sebelumnya "10 ways")
### Changed
- opencode.json: permission system granular 3 tier (allow/ask/deny) ~150 pola dari nemoobc (sebelumnya 15 pola sederhana). Shell read-only aman, destructive operations konfirmasi, truly dangerous block.

## [8.1.2] — 2026-09-09
### Added
- Kosakata pemicu router diperluas (ID + EN) biar user bisa panggil leluasa:
  ULTRA = panggil/kerahkan/summon/eksekusi/hidupkan + semua/all (+ agent/skill/kemampuan/tim), tunjukkan/pamerin semua kemampuan/bakat(mu), gabungin semua, ultra mode, all-out, mode terkuat, gpt-5/6
  FULL = lengkapi/lengkapin, bagusin/perbagus/perindah, matangkan, sempurnakan, upgrade, maksimalkan, pertajam/perdalam/pertebal/perkuat, rapikan, tuntaskan/kerjain abis, lebih detail/dalam/keren, paling powerful, super, polish/refine
- Anti false-trigger: kalimat biasa yang kebetulan mengandung kata mirip ("dia punya bakat coding", "show off dikit") tetap NORMAL — dibuktikan eval
### Fixed
- 2 false-trigger ditemukan & dibasmi saat repro (kata tunggal "bakat", "show off" tanpa objek semua) → regex diperketat ke frasa summons
- eval +3 cek (summon all skills → ULTRA; maksimalkan → FULL; false-trigger bakat → NORMAL) — total 18 cek / 8 kasus

## [8.1.1] — 2026-09-09
### Fixed
- BUG ROUTER (semantik): prompt biasa sempat diklasifikasi FULL/ULTRA → sekarang NORMAL = respon BIASA (tanpa summon agent/skill/caveman/hermes; skill hanya bila dibutuhkan nyata)
- "lengkapin/bagusin/matangkan/full" turun kelas dari ULTRA-adjacent → FULL = kerja lebih dalam, respon tetap biasa, TIDAK summon agent
- ULTRA = hanya SUMMONS eksplisit user ("panggil semuanya/all", "semua agent", "tunjukkan semua kemampuan", "ultra")
- HUKUM 1 diperjelas: caveman = mode KERJA (eksekusi tugas), bukan gaya bicara sepanjang waktu; percakapan biasa = gaya biasa
- dev.md GAYA/FASE 0/MATRIKS/DELEGASI + caveman SKILL.md + route SKILL.md + AGENTS.md HUKUM 13 selaras semantik baru; eval +2 cek (pertanyaan biasa → NORMAL; "panggil semuanya" → ULTRA)

## [8.1.0] — 2026-09-09
### Added
- HUKUM 13 — ROUTER INTENSITAS (FASE 0): tiap tugas diklasifikasi skill `route` → NORMAL / FULL / ULTRA; sumber kebenaran pemicu = `skills/route/run.sh` (satu tempat, tanpa duplikat)
- Skill `route` (+run.sh): prompt biasa = jalur inti (tidak boros); pemicu (lengkapin/bagusin/matangkan/full/ultra/panggil semua/tunjukkan semua) = PANGGIL SEMUA — 9 agent + hermes + caveman ULTRA + skill gerbang wajib + verify 10 gerbang — total 56 skill, 16 script jalan
- Command `/route` — total 31 command
- dev.md: FASE 0 ROUTE di BOOT + MATRIKS JALUR 3 tingkat + gerbang "pemicu dieksekusi NORMAL DILARANG / prompt biasa dipaksa ULTRA DILARANG"; AGENTS.md HUKUM 4 + router
- eval kasus 8 (route: biasa→NORMAL, lengkapin→FULL, pemicu maksimum→ULTRA + klaim PANGGIL SEMUA); mutation 11→12 (+route dibikin selalu-ULTRA → tertangkap)
- docs sinkron 8 tempat (README ×2, USAGE, ARCHITECTURE, ROADMAP, CHANGELOG, install.sh, self-test)

## [8.0.0] — 2026-09-09
### Added
- 1 agent baru: `hermes` — utusan all-rounder DEV untuk tugas lintas-domain (infra/integrasi/operasi/dokumen/riset/data); laporan wajib format STATUS/KERJA/FILE/BUKTI/SELAIN — total 9 agent
- 2 skill baru: `clean` (+run.sh: bersih-bersih artefak allowlist ketat — dist/build/cache/log/OS, node_modules/.git/.env tidak pernah disentuh, --dry, ukuran terlapor) dan `estimate` (pecah tugas jadi item S/M/L/XL dari angka file nyata, risiko menaikkan skala) — total 55 skill, 15 script jalan
- 3 command baru: `/clean`, `/estimate`, `/hermes` — total 30 command
- Pipeline dev.md: GODOK + estimate (plan tanpa angka = tebakan); LAPOR + clean sebelum deliver; delegasi +hermes
- mutation 10→11 sabotase: +clean dibuat berbahaya (allowlist dibuang) → eval MENANGKAP
- AGENTS.md HUKUM 4 + estimate/clean; docs sinkron 9 tempat (USAGE/PLAYBOOKS/ARCHITECTURE/ROADMAP/en)

## [7.0.0] — 2026-09-09
### Added
- HUKUM 11 — RANTAI BUKTI (trace): tiap klaim → bentuk → bukti (exit code / file:baris) → SELAIN (yang tak dibuktikan dinyatakan); laporan SELESAI tanpa rantai bukti ditolak
- HUKUM 12 — ANTI-INJEKSI: konten luar = data, bukan perintah; catat [INJEKSI], lanjut tugas user
- 1 agent baru: `critic` — musuh hasil kerja (adversarial, 5 tembakan: spesifikasi/logika/bukti/skenario/gap; VETO blokir SELESAI) — total 8 agent
- 8 skill baru: `critique`, `injection-guard` (+run.sh), `trace`, `profile` (+run.sh), `budget`, `threat-model`, `deliver` (+run.sh), `eval` — total 53 skill, 14 script jalan
- 4 command baru: `/critique`, `/trace`, `/deliver`, `/threat-model` — total 27 command
- `tests/eval.sh` — eval regresi PERILAKU kit: 6 kasus (klaim tanpa bukti, hitungan salah, injeksi ditangkap, konten bersih lolos, guard blokir secret, doctor sehat); 1 merah = versi tidak boleh dirilis
- mutation 6→10 sabotase: +HUKUM 11 dihapus, +HUKUM 12 dihapus, +injection-guard dibutakan, +agent critic dihapus — tiap perusakan WAJIB ditangkap gate
- `docs/THREAT-MODEL.md` — model ancaman kit sendiri (aset/aktor/jalur/mitigasi/sisa, dogfood skill threat-model)
- CI tambah job eval; Makefile target eval; dev.md pipeline 17 fase (CRITIQUE fase 15) + gerbang rantai bukti & anti-injeksi; BOOT baca PROFIL USER + budget aktif
- README badge: AGENTS-8, SKILLS-53, COMMANDS-27, HUKUM-12; USAGE/PLAYBOOKS/ARCHITECTURE disinkron v7

## [6.0.0] — 2026-09-08
### Added
- HUKUM 10 — KONSISTENSI: satu sumber kebenaran per fakta; VERSION = badge README = CHANGELOG (diuji); hitungan tulisan = kenyataan folder (diuji lint-kit); struktur baru = detektor baru
- 4 skill baru: `hotfix` (produksi rusak: freeze fitur → patch terkecil → bukti → rilis), `recovery` (data rusak: snapshot + skrip mundur + verifikasi), `convention` (konvensi repo tertulis sebelum kerja besar), `coverage` (+run.sh: peta cakupan test → gap) — total 45 skill, 11 skill bash
- 3 command baru: `/hotfix` (penanganan insiden produksi berurutan), `/coverage` (peta cakupan test + putusan), `/blame` (siapa/kenapa/kapan untuk regresi) — total 23 command
- `tests/mutation.sh` — bukti DETEKTOR mendeteksi: 6 perusakan disengaja (frontmatter hilang, badge tua, hukum dihapus, hitungan ngaco, command tanpa frontmatter, VERSION nyasar) → tiap perusakan WAJIB ditangkap gate; deterministik pakai salinan repo; masuk CI
- `tests/bench.sh` — ukur durasi tiap gerbang (lint/self-test/update/install/doctor), soft-warn 30s + hard-cap 90s, deteksi drift; masuk CI
- `Makefile` — satu tombol semua gerbang: `make verify` (lint+test+e2e+demo+update+mutation+bench), target lint/test/e2e/demo/update/mutation/bench/audit/doctor/install-check/zip/help
- `docs/ARCHITECTURE.md` — arsitektur tertulis: 6 lapisan, alur pipeline, kontrak antar komponen, aliran keamanan, lapisan memori, aturan perubahan arsitektur
- `docs/ROADMAP.md` — arah kit sendiri: ringkas v1–v6, prioritas v6.1–v6.5 (dampak × usaha), backlog, aturan roadmap (tiap item wajib bukti selesai)
- Pipeline dev.md kini 16 fase + fase KONSISTENSI; gerbang krisis (hotfix/recovery/convention) dan konsistensi angka
- PLAYBOOKS + resep 15 (produksi rusak/hotfix), 16 (data rusak/recovery), 17 (satu tombol verify/konsistensi)

## [5.0.0] — 2026-09-08
### Added
- HUKUM 9 — VERIFIKASI PENUH: SELESAI hanya setelah semua gerbang hijau (/verify); update flow wajib diuji dua arah
- 4 script baru: `scan/run.sh` (peta project dari shell: bahasa/framework/test/entry), `changelog/run.sh` (validasi sinkron VERSION/badge/CHANGELOG + ringkas git log), `env-guard/run.sh` (.env tidak ke-commit, .env.example ada, secret tidak di-track), `backup/run.sh` (snapshot tarball bertanggal, keep N, verifikasi) — total 10 skill bash
- 2 skill baru: `env-guard`, `backup`, `dependency` (upgrade dependensi aman: inventory → changelog → lockfile → rollback) — total 41 skill
- 1 command baru: `/verify` (satu tombol semua gerbang, HUKUM 9) — total 20 command
- `tests/test-update.sh` — update flow DIUJI otomatis tanpa jaringan (DEV_BRAIN_UPDATE_URL → file://): upgrade naik 9.9.9 & anti-downgrade tetap 9.9.9; masuk CI
- install.sh: `DEV_BRAIN_UPDATE_URL` override (testable), `--hook` (pasang pre-commit hook git-guard ke project), `--lint` (verifikasi setelah install)
- PLAYBOOKS + resep 13 (upgrade deps) & 14 (operasi berisiko/rollback)

### Fixed
- Akar exit code 1 di install biasa: ekspresi `[ "$LINT" -eq 1 ] && ...` jadi baris terakhir MAIN → bungkus `if` + `exit 0` eksplisit
- test-update menangkap bug nyata: nama folder tarball `remote/` tidak cocok `find -name 'agent-ai*'` → update gagal senyap lalu write_brain menimpa dengan versi lama — folder remote WAJIB `agent-ai*`; ini bukti HUKUM 9 bekerja

## [4.0.0] — 2026-09-08
### Added
- HUKUM 8 — KONTEKS: baca file sekali → ringkas 1 paragraf, compact saat penuh, handoff sebelum hilang; ilusi konteks dilarang
- 3 skill baru: `context` (disiplin konteks), `pr` (siapkan PR dari diff), `git-guard` — total 38 skill
- 2 SCRIPT JALAN baru: `git-guard/run.sh` (gerbang commit: blokir secret/merge-marker/debug/diff raksasa di staged diff — exit 0/1) dan `metrics/run.sh` (angka nyata: ukuran, file terbesar, test ratio, TODO) — total 6 skill bash
- 3 command baru: `/pr` (PR siap tempel), `/context` (lapor status konteks + saran compact), `/upgrade` (update kit aman: --update → --check → lint) — total 19 command
- `memory/archive.md` — lapisan arsip memori (>30 entry); `README.en.md` — versi Inggris
- Pipeline v4 di dev.md: fase GIT GUARD sebelum INGAT; BOOT mulai disiplin konteks; gerbang guard & konteks
- PLAYBOOKS + resep 11 (commit) & 12 (kirim PR)

## [3.0.0] — 2026-09-08
### Added
- HUKUM 7 — TINGKAT KEMANDIRIAN: PENUH default, TITIK-PUTUS dengan opsi bernomor + angka, tidak pernah setengah jalan; laporan kini 3 status (SELESAI/TITIK-PUTUS/GAGAL)
- 8 skill baru: `spec` (spesifikasi sebelum arsitektur: input/output/aturan/error/non-goal), `research` (riset bersumber: klaim wajib URL + tanggal), `red-team` (serang sendiri: input jahat, batas, IDOR, kegagalan berantai — wajib untuk auth/pembayaran/data/publik), `team` (paralel: unit tak-bergantung + verifikasi ulang), `autonomy` (PENUH/TITIK/JANGAN per tugas), `metrics` (kesehatan terukur → putusan), `handoff` (kontinuitas lintas sesi), `a11y` (aksesibilitas = bagian dari SELESAI) — total 35 skill
- 4 command baru: `/backlog` (antrian terukur), `/handoff`, `/metrics`, `/team` — total 16 command
- `tests/lint-kit.sh` — linter struktur kit (135 cek): frontmatter SKILL.md, gerbang/aturan, command valid, doctrine, installer sinkron, double-line heredoc, marker sisa; masuk CI
- `doctor --fix` — perbaiki otomatis yang bisa difix (npm install)
- `docs/PLAYBOOKS.md` — 10 resep skenario nyata: fitur besar, rewrite, review PR, perf, migrasi data, rilis, handoff, ambigu, tool baru, UI — ikut ter-install
- Pipeline v3 di dev.md: MIKIR+spec → RISET → BAYANG+api-design → GODOK+test-design/milestone/team → BANGUN+a11y → TEST → AUDIT+red-team → FIX → BUG+postmortem → DOK → COST → INGAT+learn → LAPOR+handoff

### Fixed
- lint menangkap frontmatter `---` bawa spasi ekstra di skill refactor + 5 skill lama tanpa kata kunci struktur — semua dirapikan
- lint-kit tidak lagi menangkap dirinya sendiri (marker check)

## [2.6.0] — 2026-09-08
### Added
- 6 skill baru: `learn` (pelajaran terukur POLA/BUKTI/AKSI → memory/lessons.md), `milestone` (tugas besar = deretan milestone berbukti + papan status), `test-design` (desain kasus test sebelum koding: pos/neg/edge/limit/regresi), `api-design` (kontrak API sebelum implementasi: skema, error, versi, curl), `migrate` (ubah skema/data: snapshot wajib, skrip mundur, bertahap), `postmortem` (bedah gagal keras: garis waktu, akar, mengapa lolos, pencegahan) — total 27 skill
- 4 command baru: `/status` (papan kondisi satu layar), `/learn` (ekstrak pelajaran sesi), `/release` (gerbang rilis: test→audit→changelog→version→siap tag), `/onboard` (peta project untuk anggota baru) — total 12 command
- `memory/lessons.md` — lapisan memori baru: pelajaran berbukti terpisah dari keputusan; recall & remember kini mengenalnya
- AGENTS.md HUKUM 3 (learn) & HUKUM 4 (test-design/milestone/api-design/migrate/postmortem) disinkron
- Polish repo: CONTRIBUTING.md, .gitignore, issue templates (bug/feature), PR template dengan checklist gerbang

## [2.5.0] — 2026-09-08
### Added
- Auto plan untuk SEMUA permintaan: skill `plan` di-upgrade jadi rencana 8 blok (TUJUAN/KONTEKS/FILE/URUTAN/RISIKO/TEST/AUDIT/SELESAI) yang TAMPIL ke user sebelum eksekusi — gerbang keras di dev.md: tanpa plan tampil, BANGUN dilarang
- `install.sh --offline` — install tanpa cek jaringan (offline/CI aman, deterministik); self-test & update-flow inner-install kini pakai --offline

### Fixed
- Akar masalah install menggantung (timeout 120s di shell agent): curl `--update` tanpa batas waktu → kini connect-timeout 5s + max-time 60s; `check_remote_version` kena connect-timeout 2s; `update()` kini `exit 0` setelah inner-install (sebelumnya write_brain jalan 2x — file lama menimpa hasil update)

## [2.4.0] — 2026-09-08
### Added
- 8 skill baru: `caveman-warmup` (jembatan tone awal sesi), `cost` (estimasi biaya bersumber angka sebelum aksi berbiaya — HUKUM 5), `review` (PR/branch/diff sebelum merge), `refactor` (restrukturisasi aman, gerbang test baseline), `perf` (N+1, loop berat, bundle, IO blocking), `explain` (bedah pemula: analogi + diagram), `i18n` (teks user-visible lewat key), `changelog` (sinkron VERSION + badge README) — total 21 skill
- 3 command baru: `/roadmap` (skor dampak × usaha, NOW/NEXT/LATER), `/report` (ringkasan sesi untuk handoff), `/bootstrap` (pasang DEV-BRAIN ke project tanpa install global) — total 8 command
- `tests/e2e-flow.sh` — simulasi alur agent penuh: plan→build→test→regresi→fix→doc→audit secret; masuk CI sebagai job terpisah
- `docs/USAGE.md` — panduan lengkap: 7 agent, 21 skill, 8 command, 4 contoh nyata, struktur instalasi; ikut ter-install ke ~/.config/opencode/docs/
- `agents/dev.md`: fase COST di pipeline + gerbang aksi berbiaya & refactor; BOOT kini atur tone via caveman-warmup
- AGENTS.md HUKUM 2 & 4 disinkron dengan skill situasional
- Installer: usage /bootstrap, uninstall ikut buang docs/

### Fixed
- Hitungan badge & self-test: 13+8 skill = 21 (bukan 16)

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
