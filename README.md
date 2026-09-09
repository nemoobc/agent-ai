<h1 align="center">
<a href="docs/logo.html"><img src="docs/logo.svg" alt="AGENT AI" width="400"></a>
</h1>

![Pipeline](https://img.shields.io/badge/PIPELINE-SCAN→MIKIR→BAYANG→GODOK→BANGUN→TEST→AUDIT→FIX→BUG→DOK→INGAT-764ba2?style=for-the-badge)
![Version](https://img.shields.io/badge/VERSION-6.0.0-4facfe?style=for-the-badge)
![Agents](https://img.shields.io/badge/AGENTS-7-00d2ff?style=for-the-badge)
![Skills](https://img.shields.io/badge/SKILLS-45-82d815?style=for-the-badge)
![Commands](https://img.shields.io/badge/COMMANDS-23-ffd700?style=for-the-badge)
![Memory](https://img.shields.io/badge/MEMORY-PERSISTENT-ff6b6b?style=for-the-badge)

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-termux%20%7C%20linux%20%7C%20macos-lightgrey?style=flat-square)]()

</div>

---

## INSTAL INSTAN

**Via curl (recommended):**
```bash
curl -fsSL https://raw.githubusercontent.com/nemoobc/agent-ai/master/install.sh | bash
```

**Via bash langsung:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nemoobc/agent-ai/master/install.sh)
```

**Clone & install:**
```bash
git clone https://github.com/nemoobc/agent-ai.git && cd agent-ai && bash install.sh
```

**Install ke project tertentu:**
```bash
bash install.sh --project ~/my-app
```

---

## APA INI

AGENT AI adalah **otak permanen** untuk opencode. Sekali install, selalu aktif di semua sesi. Tidak perlu pilih agent. Ketik tugas → DEV jalan sendiri.

---

## PIPELINE

```
User: "buat login page, testnya sekalian"
         │
         ▼
    ┌─────────┐
    │  MIKIR  │  ← skill think
    └────┬────┘
         ▼
    ┌──────────┐
    │ BAYANGAN │  ← skill imagine + task architect
    └────┬─────┘
         ▼
    ┌──────────┐
    │  GODOK   │  ← skill plan (rencana 8 blok, TAMPIL dulu)
    └────┬─────┘
         ▼
    ┌──────────┐
    │  BANGUN  │  ← task coder
    └────┬─────┘
         ▼
    ┌──────────┐
    │   TEST   │  ← skill test-full (bash auto)
    └────┬─────┘
         ▼
    ┌──────────┐
    │  AUDIT   │  ← skill audit-full (bash auto)
    └────┬─────┘
         ▼
    ┌──────────┐
    │   FIX    │  ← task fixer + skill fix-full
    └────┬─────┘
         ▼
    ┌──────────┐
    │  INGAT   │  ← task memory
    └────┬─────┘
         ▼
    ┌──────────┐
    │  LAPOR   │  ← ringkasan caveman
    └──────────┘
```

---

## AGENTS

| Agent | Mode | Fungsi |
|-------|------|--------|
| **DEV** | primary | Otak utama. Orkestrator. Satu-satunya yang bicara ke user. |
| **ARCHITECT** | subagent | Perancang struktur, data flow, edge case. |
| **CODER** | subagent | Implementasi bersih sesuai desain. |
| **TESTER** | subagent | Jalankan test, analisa kegagalan. |
| **AUDITOR** | subagent | Audit keamanan, kualitas, dependensi, secret. |
| **FIXER** | subagent | Perbaiki semua temuan sampai hijau. |
| **MEMORY** | subagent | Simpan ingatan jangka panjang. |

---

## SKILLS

| Skill | Bash Script | Fungsi |
|-------|:-----------:|--------|
| think | — | Mikir mendalam sebelum eksekusi |
| imagine | — | Bayangkan hasil akhir sebelum bangun |
| remember | — | Simpan keputusan & pembelajaran |
| recall | — | Muat ingatan di awal sesi |
| caveman | — | Gaya bicara ULTRA: pendek, marker wajib, tanpa kata lunak |
| caveman-warmup | — | Jembatan tone awal sesi: profil A/B/C, kerja tetap caveman |
| scan | — | Peta project saat BOOT: bahasa, framework, entry, test |
| plan | — | Rencana 8 blok (TUJUAN→SELESAI) tampil ke user sebelum eksekusi — semua permintaan |
| debug | — | Debug sistematis: reproduksi → isolasi → bukti → fix |
| cost | — | Estimasi biaya/token dengan sumber angka sebelum aksi berbiaya (HUKUM 5) |
| review | — | Review PR/branch/diff: prediksi merge, hambatan, saran commit |
| refactor | — | Restrukturisasi aman tanpa ubah perilaku, gerbang test baseline |
| perf | — | Audit performa: N+1, loop berat, bundle besar, IO blocking |
| explain | — | Bedah kode untuk pemula: analogi, diagram, tanpa jargon |
| i18n | — | Semua teks user-visible lewat key, tanpa string hardcoded |
| changelog | — | Entry CHANGELOG sinkron VERSION + badge README |
| learn | — | Ekstrak pelajaran terukur (Pola/Bukti/Aksi) → memory/lessons.md |
| milestone | — | Pecah tugas besar jadi milestone berbukti M1..Mn, papan status |
| test-design | — | Desain kasus test SEBELUM koding: pos/neg/edge/limit/regresi |
| api-design | — | Kontrak API sebelum implementasi: skema, error, versi, contoh curl |
| migrate | — | Ubah skema/data aman: snapshot → skrip mundur → bertahap → verifikasi |
| postmortem | — | Bedah gagal keras: garis waktu, akar, mengapa lolos, pencegahan |
| spec | — | Spesifikasi perilaku sebelum arsitektur: input/output/aturan/error/non-goal |
| research | — | Riset eksternal bersumber: klaim wajib pasangan URL + tanggal |
| red-team | — | Serang hasil kerja sendiri: input jahat, batas, IDOR, kegagalan berantai |
| team | — | Kerja paralel: unit tak-bergantung, sub-agent serentak, verifikasi ulang |
| autonomy | — | Tingkat kemandirian per tugas: PENUH/TITIK/JANGAN — berhenti tepat, bukan setengah jalan |
| metrics | — | Kesehatan project terukur: ukuran, kompleksitas, test, utang → putusan |
| handoff | — | Kontinuitas lintas sesi: selesai(bukti), sisa(terukur), validasi, jebakan |
| a11y | — | Aksesibilitas UI: keyboard, screen reader, kontras — bagian dari SELESAI |
| context | — | Disiplin konteks: baca sekali → ringkas → compact → handoff (HUKUM 8) |
| pr | — | Siapkan pull request dari diff: judul, ringkasan, bukti, checklist |
| **git-guard** | ✅ | Gerbang commit JALAN: blokir secret/marker/debug/diff raksasa |
| **metrics** | ✅ | Angka kesehatan project nyata: ukuran, test, TODO (run.sh) |
| **scan** | ✅ | Peta project dari shell: bahasa/framework/test/entry (run.sh) |
| **changelog** | ✅ | Validasi sinkron VERSION/badge/CHANGELOG + ringkas git log (run.sh) |
| **env-guard** | ✅ | Hygiene .env: tidak ke-commit, .env.example ada, secret tidak di-track |
| **backup** | ✅ | Snapshot tarball bertanggal sebelum operasi berisiko, keep N terbaru |
| dependency | — | Upgrade dependensi aman: inventory, changelog, lockfile, rollback |
| hotfix | — | Produksi rusak: freeze fitur → patch terkecil → bukti → rilis |
| recovery | — | Data rusak: snapshot → skrip mundur → verifikasi → lapor |
| convention | — | Konvensi repo tertulis sebelum kerja besar: gaya, struktur, gerbang |
| **coverage** | ✅ | Peta cakupan test nyata: file teruji vs gap (run.sh) |
| **doctor** | ✅ | Diagnosa lingkungan, dependensi, typecheck, memori (deteksi secret) |
| **test-full** | ✅ | Auto deteksi bahasa & jalankan semua test (12 stack) |
| **audit-full** | ✅ | Auto audit deps, lint, secret (16+ pola), higiene |
| **fix-full** | ✅ | Auto format, lint-fix, re-test |
| **doc-full** | — | README/CHANGELOG sinkron saat perubahan user-visible |

---

## COMMANDS

| Command | Fungsi |
|---------|--------|
| `/ship <tugas>` | Pipeline penuh: think→architect→coder→test→audit→fix→memory→lapor |
| `/fix` | Auto repair: test→audit→fix loop sampai hijau |
| `/audit` | Audit penuh: test→audit-full→review manual→fix sampai CLEAN |
| `/doctor` | Diagnosa kesehatan kit: lingkungan, dependensi, memori |
| `/memory` | Tampilkan ingatan Agent AI |
| `/roadmap` | Prioritas langkah berikutnya: skor dampak × usaha, NOW/NEXT/LATER |
| `/report` | Ringkasan sesi untuk handoff/tim: perubahan, test, audit, risiko, next |
| `/bootstrap` | Pasang Agent AI ke project ini (.opencode/) tanpa install global |
| `/status` | Papan kondisi satu layar: milestone, test, audit, risiko, next |
| `/learn` | Ekstrak pelajaran sesi jadi lessons.md terukur |
| `/release` | Gerbang rilis: test→audit→changelog→version→siap tag |
| `/onboard` | Peta project + cara kerja + lingkungan untuk anggota baru |
| `/backlog` | Antrian kerja terukur: definisi selesai + skor + status |
| `/handoff` | Kemas konteks sesi untuk penerus: selesai/sisa/validasi/jebakan |
| `/metrics` | Angka kesehatan project + putusan konkret |
| `/team` | Kerja paralel terkoordinasi: pecah → sub-agent → verifikasi ulang |
| `/pr` | Siapkan pull request siap tempel dari diff |
| `/context` | Lapor status konteks sesi + saran compact/handoff |
| `/upgrade` | Update kit aman: --update → --check → lint → lapor |
| `/verify` | Satu tombol semua gerbang (HUKUM 9): lint, self-test, e2e, demo, update, mutation, bench, audit, doctor |
| `/hotfix` | Insiden produksi berurutan: freeze → diagnosis → patch terkecil → bukti → rilis |
| `/coverage` | Peta cakupan test + gap → putusan tulis test apa dulu |
| `/blame` | Telusuri regresi: siapa/kenapa/kapan, dari git + memori |

---

## STRUKTUR

```
~/.config/opencode/
├── AGENTS.md              ← doctrine permanen (10 hukum)
├── opencode.json          ← permission granular (skill + git read-only auto, sisanya ask)
├── VERSION                ← versi terpasang (--check & doctor baca ini)
├── agent/
│   ├── dev.md             ← otak utama
│   ├── architect.md
│   ├── coder.md
│   ├── tester.md
│   ├── auditor.md
│   ├── fixer.md
│   └── memory.md
├── skill/                 ← 45 skill
│   ├── think/SKILL.md
│   ├── imagine/SKILL.md
│   ├── remember/SKILL.md
│   ├── recall/SKILL.md
│   ├── caveman/SKILL.md          ← caveman ULTRA
│   ├── caveman-warmup/SKILL.md   ← jembatan tone awal sesi
│   ├── scan/SKILL.md
│   ├── plan/SKILL.md
│   ├── debug/SKILL.md
│   ├── doc-full/SKILL.md
│   ├── cost/SKILL.md             ← HUKUM 5: biaya dulu, baru tanya
│   ├── review/SKILL.md           ← PR/branch/diff sebelum merge
│   ├── refactor/SKILL.md         ← struktur berubah, perilaku tidak
│   ├── perf/SKILL.md             ← N+1, loop berat, bundle, IO blocking
│   ├── explain/SKILL.md          ← bedah pemula: analogi + diagram
│   ├── i18n/SKILL.md             ← teks user-visible lewat key
│   ├── changelog/SKILL.md        ← sinkron VERSION + badge
│   ├── learn/SKILL.md            ← pelajaran terukur → lessons.md
│   ├── milestone/SKILL.md        ← tugas besar = deretan milestone berbukti
│   ├── test-design/SKILL.md      ← desain test sebelum koding
│   ├── api-design/SKILL.md       ← kontrak API sebelum implementasi
│   ├── migrate/SKILL.md          ← skema/data: snapshot dulu, skrip mundur
│   ├── postmortem/SKILL.md       ← bedah gagal: akar + pencegahan
│   ├── spec/SKILL.md             ← spesifikasi sebelum arsitektur
│   ├── research/SKILL.md         ← riset bersumber, tanpa tebak
│   ├── red-team/SKILL.md         ← serang diri sendiri dulu
│   ├── team/SKILL.md             ← paralel + verifikasi ulang
│   ├── autonomy/SKILL.md         ← berhenti tepat, bukan setengah jalan
│   ├── metrics/SKILL.md          ← angka kesehatan → putusan
│   ├── handoff/SKILL.md          ← kontinuitas lintas sesi
│   ├── a11y/SKILL.md             ← UI bisa dipakai semua orang
│   ├── context/SKILL.md          ← disiplin konteks (HUKUM 8)
│   ├── pr/SKILL.md               ← PR siap tempel dari diff
│   ├── git-guard/ (SKILL.md + run.sh) ← gerbang commit JALAN
│   ├── metrics/ (SKILL.md + run.sh)   ← angka kesehatan nyata
│   ├── scan/ (SKILL.md + run.sh)      ← peta project dari shell
│   ├── changelog/ (SKILL.md + run.sh) ← validasi sinkron versi
│   ├── env-guard/ (SKILL.md + run.sh) ← hygiene .env
│   ├── backup/ (SKILL.md + run.sh)    ← snapshot sebelum operasi berisiko
│   ├── dependency/SKILL.md            ← upgrade dependensi aman
│   ├── hotfix/SKILL.md                ← produksi rusak: patch terkecil dulu
│   ├── recovery/SKILL.md              ← data rusak: snapshot + skrip mundur
│   ├── convention/SKILL.md            ← konvensi repo tertulis
│   ├── coverage/ (SKILL.md + run.sh)  ← peta cakupan test nyata
│   ├── doctor/     (SKILL.md + run.sh)
│   ├── test-full/  (SKILL.md + run.sh)
│   ├── audit-full/ (SKILL.md + run.sh)
│   └── fix-full/   (SKILL.md + run.sh)
├── command/               ← 23 command
│   ├── ship.md
│   ├── fix.md
│   ├── audit.md
│   ├── doctor.md
│   ├── memory.md
│   ├── roadmap.md
│   ├── report.md
│   ├── bootstrap.md
│   ├── status.md
│   ├── learn.md
│   ├── release.md
│   ├── onboard.md
│   ├── backlog.md
│   ├── handoff.md
│   ├── metrics.md
│   ├── team.md
│   ├── pr.md
│   ├── context.md
│   ├── upgrade.md
│   ├── verify.md
│   ├── hotfix.md
│   ├── coverage.md
│   └── blame.md
├── docs/USAGE.md          ← panduan lengkap per agent/skill/command
├── docs/PLAYBOOKS.md      ← 17 resep skenario nyata
├── docs/ARCHITECTURE.md   ← arsitektur tertulis (6 lapisan + kontrak)
├── docs/ROADMAP.md        ← arah kit sendiri (v6.1–v6.5 + backlog)
├── Makefile               ← make verify = semua gerbang satu tombol
├── README.en.md           ← versi Inggris
└── memory/
    ├── MEMORY.md
    ├── decisions.md
    ├── lessons.md          ← pelajaran terukur (Pola/Bukti/Aksi)
    └── session-log.md
```

---

## HUKUM Agent AI

1. **CAVEMAN ULTRA** — bicara pendek, marker wajib, tanpa kata lunak, hasil = bukti
2. **PIPELINE OTOMATIS** — SCAN→MIKIR→BAYANG→GODOK→BANGUN→TEST→AUDIT→FIX→(BUG? debug)→(DOK? doc-full)→(MAHAL? cost)→INGAT→LAPOR
3. **MEMORI** — awal sesi recall, akhir tugas remember + learn (lessons.md)
4. **DELEGASI** — DEV panggil sub-agent otomatis via task tool
5. **BERHENTI** — hanya untuk destruktif besar, force push, install sistem, biaya (skill `cost` angkat angkanya)
6. **BAHASA** — ikuti bahasa user, default Indonesia
7. **TINGKAT KEMANDIRIAN** — PENUH default; keputusan di luar wewenang → TITIK-PUTUS dengan opsi bernomor + angka; tidak pernah setengah jalan
8. **KONTEKS** — baca sekali → ringkas; konteks penuh → compact; handoff sebelum hilang
9. **VERIFIKASI PENUH** — SELESAI hanya setelah semua gerbang hijau (/verify: lint, self-test, e2e, demo, update, mutation, bench, audit, doctor)
10. **KONSISTENSI** — satu sumber kebenaran per fakta; VERSION = badge = CHANGELOG; hitungan tulisan = kenyataan folder; struktur baru = detektor baru

---

## CONTOH PAKAI

```
you: buat halaman login yang bagus, responsive, ada validasi

DEV: [MIKIR] ... [BAYANG] ... [BANGUN] ...
     ✔ login.html dibuat
     ✔ style.css dibuat
     ✔ test login.test.js PASS (3/3)
     ✔ audit CLEAN
     ✔ memori tersimpan

you: tambahin fitur register

DEV: [MIKIR] ... [BANGUN] ...
     ✔ register.html dibuat
     ✔ auth.js diupdate
     ✔ test PASS (5/5)
     ✔ audit CLEAN
```

---

## DEMO 60 DETIK

```bash
make verify                 # semua gerbang satu tombol (HUKUM 9 + 10)
bash tests/lint-kit.sh      # linter struktur kit (150+ cek)
bash tests/self-test.sh     # suite detektor (110+ cek)
bash tests/e2e-flow.sh      # alur agent penuh
bash tests/run-demo.sh      # demo pipeline hidup
bash tests/test-update.sh   # update flow: upgrade + anti-downgrade
bash tests/mutation.sh      # bukti detektor menangkap perusakan (6/6)
bash tests/bench.sh         # durasi gate di bawah hard-cap
```

Bangun project fixture dengan bug disengaja → test-full MENANGKAP → perbaiki akar masalah → test HIJAU → audit CLEAN. Pipeline terbukti hidup, bukan cuma dokumen.

---

## UPDATE OTOMATIS

```bash
bash install.sh --update     # unduh master terbaru, install ulang, memori aman
bash install.sh --version    # lihat versi
bash install.sh --check      # cek kesehatan + versi terpasang
bash install.sh --offline    # tanpa cek jaringan (offline/CI aman, tanpa menunggu)
bash install.sh --hook       # pasang pre-commit hook git-guard ke project ini
bash install.sh --lint       # verifikasi lint-kit + self-test setelah install
```

Tiap install juga mengecek versi remote (connect 2s, total 3s — offline aman) dan memberi tahu bila ada versi baru. Semua network call installer kini berbatas waktu — shell agent tidak menggantung.

---

## UNINSTALL

```bash
bash install.sh --uninstall
```

Memori **tidak dihapus**. Agent & doctrine dilepas.

---

## LICENSE

MIT — bebas pakai, modif, distribusi.

---

<div align="center">

**built with ☕ and caveman energy**

</div>
