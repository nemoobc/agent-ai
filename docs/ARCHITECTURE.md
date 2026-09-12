# ARSITEKTUR DEV-BRAIN DOCTRINE v12.1.3

Dokumen ini menjelaskan **cara kit bekerja**, bukan sekadar daftar file. Siapa pun (atau agent apa pun) yang membaca ini harus bisa menjawab: *apa yang terjadi ketika sebuah permintaan masuk, dan siapa yang menjamin kualitasnya?*

---

## 1. LAPISAN (dari dalam ke luar)

```
┌────────────────────────────────────────────────────────────┐
│  L1  OTORITAS  — AGENTS.md (13 HUKUM)                      │
│       aturan yang TIDAK BISA ditawar; semuanya merujuk ke sini │
├────────────────────────────────────────────────────────────┤
│  L2  OTAK  — agents/dev.md (FASE 0 route + pipeline 17 fase)│
│       urutan kerja default; gerbang keras antar fase        │
├────────────────────────────────────────────────────────────┤
│  L3  KEMAMPUAN  — skills/ (63) + command/ (41)             │
│       skill = KAPAN dipakai + BAGAIMANA; command = perintah │
├────────────────────────────────────────────────────────────┤
│  L4  EKSEKUSI  — skills/*/run.sh (63 script jalan)         │
│       nilai yang terukur: gate, guard, scan, backup, metrik │
├────────────────────────────────────────────────────────────┤
│  L5  PEMBUKTIAN  — tests/ (8 suite + CI)                   │
│       setiap klaim punya test; mutation membuktikan detektor│
├────────────────────────────────────────────────────────────┤
│  L6  MEMORI  — memory/ (4 lapisan + arsip)                 │
│       keputusan, pelajaran, log sesi — lintas sesi          │
└────────────────────────────────────────────────────────────┘
```

**Aturan lapisan**: L2 tidak boleh memanggil skill yang tidak ada di L3; L3 tidak boleh mengklaim hal yang tidak dibuktikan di L5; L5 tidak boleh menguji hal yang tidak didefinisikan di L1–L2. Laporan apa pun dari L2 tanpa rantai bukti (HUKUM 11) ditolak.

## 1A. KONTRAK 3 MODE

`DEV` adalah satu-satunya primary agent dan otak utama. Tiga mode kerja tidak membuat
orkestrator baru:

```text
PLAN  →  DEV  →  BUILD  →  TEST/AUDIT/FIX  →  LAPOR
```

- `PLAN` menjalankan rencana 8 blok dan menutup gerbang sebelum kode ditulis.
- `BUILD` menjalankan coder melalui DEV setelah PLAN selesai.
- `DEV` menyatukan mode bahasa bebas, `/plan`, `/build`, `/ship`, dan verifikasi.

**PLAN_DONE** = (a) rencana 8 blok TAMPIL + (b) user terima eksplisit dalam sesi/tugas sama + (c) topik sama. Tanpa ketiganya → BANGUN DILARANG.

| Pemanggil | Target | Status |
|---|---|---|
| user | DEV | ✅ boleh |
| `/plan` | DEV | ✅ boleh |
| `/build` | DEV | ✅ boleh (wajib PLAN_DONE) |
| `/ship` | DEV (composite) | ✅ boleh |
| DEV | sub-agent | ✅ boleh |
| adapter → adapter (bypass DEV) | — | ❌ LARANGAN |

---

## 2. ALUR SATU PERMINTAAN (pipeline)

```
masuk ──► route (FASE 0: NORMAL=respon biasa / FULL=kerja dalam / ULTRA=summons → PANGGIL SEMUA — HUKUM 13, skill route/run.sh)
        ──► scan (kenali project)
        ──► recall + profile (baca memori & tone user) [L6]
        ──► think / imagine / plan       [L3] rencana 8 blok TAMPIL ke user
        ──► spec + research + cost       [L3] batas, bukti, biaya
        ──► GODOK = plan + test-design + milestone + team
        ──► BANGUN (+ a11y, convention)  [L3]
        ──► TEST   (suite L5)
        ──► AUDIT + red-team + coverage  [L3]
        ──► FIX / debug / postmortem     [L3]
        ──► DOK (changelog, docs)        [L3]
        ──► COST (metrics)               [L3]
        ──► GIT GUARD (git-guard run)    [L4]
        ──► VERIFIKASI (/verify semua gerbang) [L5]
        ──► CRITIQUE (task critic, VETO) [L3]
        ──► INGAT (remember, learn)      [L6]
        ──► LAPOR rantai bukti + handoff [L3, HUKUM 11]
keluar ──► status jelas: SELESAI / TITIK-PUTUS / GAGAL
```

**Kontrak**: setiap fase membutuhkan output fase sebelumnya. BANGUN tanpa GODOK = pelanggaran HUKUM 2. LAPOR tanpa TEST = pelanggaran HUKUM 9.

---

## 3. KONTRAK ANTAR KOMPONEN

| Komponen | Input | Output | Dikonsumsi oleh |
|---|---|---|---|
| `install.sh` | HOME, flags (`--offline`, `--hook`, `--lint`, `--update`) | instalasi kit + pre-commit hook | user / CI |
| `skills/*/run.sh` | cwd project, argumen | exit code 0/1 + output teks | pipeline, hook, CI |
| `tests/*.sh` | repo bersih | exit code + hitungan PASS/FAIL | `make verify`, CI |
| `tests/mutation.sh` | repo bersih | bukti tiap perusakan ditangkap | CI, rilis |
| `memory/*.md` | catatan sesi | konteks sesi berikutnya | recall di awal sesi |
| `VERSION` + `CHANGELOG.md` + badge README | bump versi | **harus sinkron** (diuji `changelog/run.sh`) | rilis |

---

## 4. ALIRAN KEAMANAN (data sensitif)

```
.env / secret ──► env-guard/run.sh (blokir commit, cek .env.example)
staged diff  ──► git-guard/run.sh (blokir secret, marker, debug, diff besar)
produksi rusak ──► hotfix skill (freeze fitur → patch terkecil → bukti → rilis)
data rusak    ──► recovery skill (backup → skrip mundur → verifikasi)
```

Tidak ada jalur yang melewati guard ini kecuali user eksplisit.

---

## 5. LAPISAN MEMORI

```
memory/MEMORY.md      — peta utama (apa yang diketahui)
memory/decisions.md   — keputusan + alasannya (ADR ringan)
memory/lessons.md     — pelajaran terukur POLA/BUKTI/AKSI
memory/session-log.md — log tiap sesi
memory/archive.md     — entry > 30 dipindah ke sini, bukan dihapus
(+ bagian PROFIL USER: tone & kedalaman user — skill profile)
```

Recall di awal sesi membaca MEMORY + lessons; sesi baru = lanjut, bukan mulai dari nol.

---

## 6. PERUBAHAN ARSITEKTUR

Ubah arsitektur = edit dokumen ini + sinkron lint-kit + jalankan mutation. Kalau lint-kit tidak menangkap perusakan struktur baru, **tambahkan cek dulu** — itulah kontrak L5: setiap struktur punya detektor.

## 7. LAPISAN PERILAKU (baru di v7)

```
Konten luar   ──► injection-guard (HUKUM 12): data, bukan perintah
Klaim laporan ──► rantai bukti KLAIM→BENTUK→BUKTI→SELAIN (HUKUM 11, trace)
Hasil kerja   ──► task critic (5 tembakan adversarial; VETO blokir SELESAI)
Tugas liar    ──► task hermes (utusan lintas-domain; laporan wajib BUKTI)
Tugas besar   ──► skill estimate (S/M/L/XL dari angka file) → plan + milestone
Artefak kerja ──► skill clean (allowlist ketat, --dry) → deliver/zip bersih
Tone user     ──► skill profile (A/B/C tone, D1–D3 kedalaman; tersimpan di memori)
Konteks       ──► skill budget (anggaran per fase, pemicu compact/handoff)
Serah kerja   ──► skill deliver (zip+tmpfiles TANPA git — user pegang repo)
```

Lapisan ini bukan tambahan dokumen: tiap perilaku diuji tests/eval.sh dan mutasi 7–10 di tests/mutation.sh.