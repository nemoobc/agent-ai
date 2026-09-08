# PANDUAN LENGKAP DEV-BRAIN (docs/USAGE.md)

Semua agent, semua skill, semua command — kapan dipakai, siapa yang panggil, contoh nyata.
DEV-BRAIN v6.0.0 — 7 agent, 45 skill, 23 command, 10 hukum, 11 script jalan. Install dulu: `bash install.sh`.

---

## CARA KERJA INTI

Kamu TIDAK PERLU command manual. Ketik tugas bahasa bebas → DEV jalan sendiri:

```
recall+scan → think → imagine+architect → plan → coder → test → audit → fix → (debug) → (doc) → (cost) → memory → lapor
```

Command di bawah = pintasan. Skills = otot di belakang pintasan. Agents = tangan yang eksekusi.

---

## AGENTS (7)

| Agent | Peran | Kapan Aktif | Contoh Output |
|-------|-------|-------------|---------------|
| **DEV** (primary) | Orkestrator, satu-satunya yang bicara ke user | Selalu — otomatis | Laporan caveman ≤8 baris |
| **ARCHITECT** | Desain struktur, data flow, edge case | Fase BAYANG | Desain + edge case list |
| **CODER** | Implementasi bersih sesuai desain | Fase BANGUN | Kode + file:baris |
| **TESTER** | Jalankan test, analisa kegagalan | Fase TEST | PASS/FAIL + angka |
| **AUDITOR** | Audit keamanan/kualitas/dependensi/secret | Fase AUDIT | Temuan `[P0..P3] file:baris` |
| **FIXER** | Perbaiki semua temuan sampai hijau | Fase FIX | Diff perbaikan + re-test hijau |
| **MEMORY** | Simpan ingatan jangka panjang | Fase INGAT | Entry keputusan + pembelajaran |

DEV yang panggil. User tidak perlu tahu. Bila tugas kecil (< 3 file, tanpa risiko) DEV kerja sendiri.

---

## SKILLS (45)

### Otot otomatis (dipanggil DEV tanpa disuruh)

| Skill | Kapan | Fungsi |
|-------|-------|--------|
| `recall` | Awal sesi | Muat ingatan (MEMORY/decisions/session-log) |
| `scan` | Boot sebelum eksekusi pertama | Peta project: bahasa, framework, entry, test |
| `think` | Fase MIKIR | Masalah, batasan, opsi, risiko, putusan |
| `imagine` | Fase BAYANG | Bayangkan hasil akhir sebelum bangun |
| `plan` | Setiap permintaan, fase GODOK | Rencana 8 blok tampil ke user SEBELUM eksekusi: TUJUAN/KONTEKS/FILE/URUTAN/RISIKO/TEST/AUDIT/SELESAI |
| `debug` | Ada bug | Reproduksi → isolasi → bukti → fix. Dilarang menebak |
| `doc-full` | Perubahan user-visible | README/CHANGELOG sinkron |
| `remember` | Akhir tugas penting | Simpan keputusan & pembelajaran (tanpa secret) |
| `caveman` | Permanen | Gaya bicara ULTRA: pendek, marker wajib |
| `caveman-warmup` | Awal sesi | Jembatan tone: profil A/B/C sebelum bicara keras, kerja tetap caveman |
| `cost` | Sebelum aksi berbiaya (HUKUM 5) | Estimasi biaya/token dengan sumber angka, tanya user |
| `learn` | Akhir setiap tugas | Ekstrak pelajaran POLA/BUKTI/AKSI → memory/lessons.md |
| `postmortem` | Gagal keras / data rusak | Garis waktu, akar, mengapa lolos test, pencegahan permanen |

### Otot khusus (aktif bila situasinya cocok)

| Skill | Kapan | Fungsi |
|-------|-------|--------|
| `review` | User minta review PR/branch/diff | Prediksi merge, hambatan, saran commit |
| `refactor` | Restrukturisasi tanpa ubah perilaku | Test baseline hijau sebagai gerbang |
| `perf` | Keluh "lambat" / hotspot | N+1, loop berat, bundle besar, IO blocking |
| `explain` | User minta penjelasan | Bedah pemula: analogi, diagram, tanpa jargon |
| `i18n` | Fitur teks / teks hardcoded | Semua teks user-visible lewat key terkumpul |
| `changelog` | Rilis / bump versi | Entry CHANGELOG sinkron VERSION + badge README |
| `milestone` | Tugas besar (>10 file / plan >15 baris) | Deretan M1..Mn berbukti, papan status, gerbang antar milestone |
| `test-design` | Fase plan, perilaku baru | Kasus test sebelum koding: pos/neg/edge/limit/regresi |
| `api-design` | Menambah/ubah endpoint | Kontrak API: skema, error, versi, contoh curl |
| `migrate` | Ubah skema/data | Snapshot → skrip mundur → bertahap → verifikasi |
| `spec` | Fitur baru/ambigu | Spesifikasi: input/output/aturan/error/non-goal — sebelum arsitektur |
| `research` | Fakta luar (versi/API/harga) | Klaim wajib sumber URL + tanggal; mulai dari repo dulu |
| `red-team` | Auth/pembayaran/data/publik | Serang sendiri: input jahat, batas, IDOR, kegagalan berantai |
| `team` | ≥3 unit tak-bergantung | Sub-agent paralel + verifikasi ulang penuh |
| `autonomy` | Setiap tugas (pilih tingkat) | PENUH/TITIK/JANGAN — berhenti tepat dengan opsi bernomor |
| `metrics` | Kesehatan project | Ukuran/kompleksitas/test/utang → putusan konkret |
| `handoff` | Sesi habis/serah kerja | Selesai(bukti) + sisa(terukur) + validasi + jebakan |
| `a11y` | UI baru/berubah | Keyboard, semantik, screen reader, kontras — bagian dari SELESAI |
| `context` | Selalu (HUKUM 8) | Baca sekali → ringkas 1 paragraf → compact saat penuh → handoff |
| `pr` | Siapkan PR dari diff | Judul konvensional, ringkasan, bukti test, checklist |
| `git-guard` (✅) | Sebelum commit | Blokir secret/marker/debug/diff raksasa di staged diff — exit 0/1 |
| `metrics` (✅) | /metrics /roadmap | Angka nyata: ukuran, file terbesar, test, TODO — exit 0 |
| `scan` (✅) | Boot / /onboard | Peta project dari shell: bahasa, framework, test, entry — exit 0 |
| `changelog` (✅) | Rilis / bump | Validasi sinkron VERSION/badge/CHANGELOG + git log — exit 0/1 |
| `env-guard` (✅) | Project dengan secret | .env tidak ke-commit, .env.example ada, secret tidak di-track — exit 0/1 |
| `backup` (✅) | Sebelum operasi berisiko data | Snapshot tarball bertanggal, keep N terbaru, verifikasi bisa dibaca — exit 0/1 |
| `dependency` | Upgrade dependensi | Inventory → riset changelog → backup → bump → lockfile → test → rollback |
| `hotfix` | Produksi rusak (insiden) | Freeze fitur → diagnosis → patch terkecil → bukti pulih → rilis → postmortem |
| `recovery` | Data rusak/korup | Snapshot terverifikasi → rentang kerusakan → skrip mundur → uji salinan → restore bertahap |
| `convention` | Project tanpa aturan tertulis | Konvensi repo: gaya, struktur, gerbang — ditulis dulu sebelum kerja besar |
| `coverage` (✅) | Setelah test / /coverage | Peta cakupan test nyata: file teruji vs gap → putusan — exit 0 |

### Otot bash (script nyata, exit code jelas)

| Skill | Script | Exit 0 | Exit 1 | Exit 2 |
|-------|--------|--------|--------|--------|
| `test-full` | ✅ | PASS | FAIL | NO-TESTS |
| `audit-full` | ✅ | CLEAN | temuan | — |
| `fix-full` | ✅ | hijau | masih merah | — |
| `doctor` | ✅ | sehat | masalah | — |

---

## COMMANDS (23)

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `/ship <tugas>` | Pipeline penuh ujung-ke-ujung | `/ship bikin login page + test` |
| `/fix` | Loop repair sampai hijau | `/fix test merah semua` |
| `/audit` | Audit penuh + review manual | `/audit` |
| `/doctor` | Diagnosa kesehatan kit | `/doctor` |
| `/memory` | Tampilkan ingatan | `/memory` |
| `/roadmap` | Prioritas dampak × usaha | `/roadmap` |
| `/report` | Ringkasan sesi untuk handoff | `/report` |
| `/bootstrap` | Pasang DEV-BRAIN ke project ini tanpa install global | `/bootstrap` |
| `/status` | Papan kondisi satu layar | `/status` |
| `/learn` | Ekstrak pelajaran sesi | `/learn` |
| `/release` | Gerbang rilis penuh | `/release` |
| `/onboard` | Peta project untuk anggota baru | `/onboard` |
| `/backlog` | Antrian kerja terukur | `/backlog tambah fitur X` |
| `/handoff` | Kemas konteks untuk penerus | `/handoff` |
| `/metrics` | Angka kesehatan + putusan | `/metrics` |
| `/team` | Kerja paralel terkoordinasi | `/team bangun 3 module` |
| `/pr` | Siapkan PR siap tempel | `/pr` |
| `/context` | Lapor status konteks + saran compact | `/context` |
| `/upgrade` | Update kit aman + verifikasi | `/upgrade` |
| `/verify` | Satu tombol semua gerbang (HUKUM 9+10) | `/verify` (atau `make verify`) |
| `/hotfix` | Insiden produksi berurutan: freeze→diagnosis→patch→bukti→rilis | `/hotfix login error 500` |
| `/coverage` | Peta cakupan test + gap → tulis test apa dulu | `/coverage` |
| `/blame` | Telusuri regresi: siapa/kenapa/kapan (git + memori) | `/blame login rusak` |

---

## CONTOH NYATA

**Contoh 1 — tugas biasa**
```
you: bikin halaman login responsive, ada validasi, testnya sekalian

DEV: [MIKIR] form + validasi client, 3 field.
     [BAYANG] architect: struktur form, error state, edge case input kosong/panjang.
     [GODOK]  3 file: page.tsx, form.tsx, form.test.tsx.
     [BANGUN] coder: 3 file selesai.
     [TEST]   6/6 PASS.
     [AUDIT]  CLEAN.
     [INGAT]  memori tersimpan.
     STATUS : SELESAI | TEST : 6/6 | AUDIT : CLEAN
```

**Contoh 2 — review PR**
```
you: review PR #42

DEV: [REVIEW] 4 file, +120 −40. Conflict? Tidak.
     [TEST] 14/14 PASS. [AUDIT] 1 temuan P2 (input tanpa sanitasi, api.ts:31).
     PREDIKSI MERGE: RISIKO — temuan P2.
     SARAN COMMIT: "add auth flow with validation"
```

**Contoh 3 — perf**
```
you: dashboard lambat banget

DEV: [PERF] scan → hot path: render tabel 500 row.
     Temuan: filter + sort jalan tiap render (table.tsx:88), N+1 query (api.ts:42).
     FIX: memo filter/sort, 1 query dengan join. Re-test 22/22 PASS.
     DAMPAK: render 480ms → 60ms (ukur via profiler).
```

**Contoh 4 — aksi berbiaya**
```
you: bikin fitur ringkasan dokumen pakai AI

DEV: [COST] sumber: docs API (app.md:12) — $0.003 per 1K token, dokumen rata 5K token.
     SKALA: terbaik $45/bln, wajar $120/bln, terburuk $400/bln (1K dokumen/hari).
     ALTERN: caching hasil + queue batch → wajar $70/bln.
     BUTUH KONFIRMASI: pakai API X dengan caching? (y/t)
```

**Contoh 5 — auto plan (semua permintaan)**
```
you: tambahin dark mode

DEV: [GODOK] TUJUAN: toggle tema gelap, tersimpan di preferensi.
     KONTEKS: React + tailwind, token warna sudah ada.
     FILE: ThemeProvider.tsx (baru), toggle.tsx (baru), index.css (token).
     URUTAN: 1) token CSS → 2) provider → 3) toggle di navbar.
     RISIKO: flash putih saat load → mitigate: init tema sebelum render.
     TEST: test-full exit 0 (5 test baru). AUDIT: audit-full exit 0.
     SELESAI BILA: toggle jalan + preferensi persist + semua test hijau.
     ← baru setelah ini kerja dimulai
```

---

## STRUKTUR INSTALASI

```
~/.config/opencode/          ← global
├── AGENTS.md                ← doctrine permanen (6 hukum)
├── opencode.json            ← permission granular
├── VERSION                  ← versi terpasang
├── agent/                   ← 7 agent
├── skill/                   ← 41 skill
├── command/                 ← 20 command
└── memory/                  ← ingatan persisten

<project>/.opencode/         ← per-project (opsional: /bootstrap)
├── agent/  skill/  command/  memory/
└── AGENTS.md                ← doctrine project-level
```

---

## HUKUM (RINGKAS)

1. CAVEMAN ULTRA — pendek, marker, hasil = bukti.
2. PIPELINE OTOMATIS — tanpa command manual.
3. MEMORI — recall awal, remember akhir. Secret dilarang masuk memori.
4. DELEGASI — DEV panggil sub-agent otomatis.
5. BERHENTI hanya: destruktif besar, force push, install sistem, biaya (skill `cost` ngangkat angkanya).
6. BAHASA — ikuti bahasa user.
7. TINGKAT KEMANDIRIAN — PENUH default; TITIK-PUTUS dengan opsi bernomor + angka bila keputusan di luar wewenang; tidak pernah setengah jalan.
8. KONTEKS — baca file sekali → ringkas; konteks penuh → compact; handoff sebelum hilang.
9. VERIFIKASI PENUH — SELESAI hanya setelah semua gerbang hijau (/verify).
