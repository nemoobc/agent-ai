<div align="center">

```
   ██████╗ ███████╗██████╗ 
   ██╔══██╗██╔════╝██╔══██╗
   ██║  ██║███████╗██████╔╝
   ██║  ██║╚════██║██╔═══╝ 
   ██████╔╝███████║██║     
   ╚═════╝ ╚══════╝╚═╝     
```

# DEV — B R A I N

**otak utama opencode • caveman mode permanen • ultronomatis**

![Pipeline](https://img.shields.io/badge/PIPELINE-MIKIR→BAYANG→GODOK→BANGUN→TEST→AUDIT→FIX→INGAT-ff69b4?style=for-the-badge)
![Agents](https://img.shields.io/badge/AGENTS-7-00d2ff?style=for-the-badge)
![Skills](https://img.shields.io/badge/SKILLS-8-82d815?style=for-the-badge)
![Commands](https://img.shields.io/badge/COMMANDS-3-ffd700?style=for-the-badge)
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

DEV-BRAIN adalah **otak permanen** untuk [opencode](https://github.com/nemoobc/opencode-termux). Sekali install, selalu aktif di semua sesi. Tidak perlu pilih agent. Ketik tugas → DEV jalan sendiri.

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
    │  GODOK   │  ← rencana detail
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
| caveman | — | Gaya bicara: pendek, kata kerja dulu |
| **test-full** | ✅ | Auto deteksi bahasa & jalankan semua test |
| **audit-full** | ✅ | Auto audit deps, lint, secret, higiene |
| **fix-full** | ✅ | Auto format, lint-fix, re-test |

---

## COMMANDS

| Command | Fungsi |
|---------|--------|
| `/ship <tugas>` | Pipeline penuh: think→architect→coder→test→audit→fix→memory→lapor |
| `/fix` | Auto repair: test→audit→fix loop sampai hijau |
| `/memory` | Tampilkan ingatan DEV-BRAIN |

---

## STRUKTUR

```
~/.config/opencode/
├── AGENTS.md              ← doctrine permanen (6 hukum)
├── opencode.json          ← permission auto-allow
├── agent/
│   ├── dev.md             ← otak utama
│   ├── architect.md
│   ├── coder.md
│   ├── tester.md
│   ├── auditor.md
│   ├── fixer.md
│   └── memory.md
├── skills/
│   ├── think/SKILL.md
│   ├── imagine/SKILL.md
│   ├── remember/SKILL.md
│   ├── recall/SKILL.md
│   ├── caveman/SKILL.md
│   ├── test-full/  (SKILL.md + run.sh)
│   ├── audit-full/ (SKILL.md + run.sh)
│   └── fix-full/   (SKILL.md + run.sh)
├── command/
│   ├── ship.md
│   ├── fix.md
│   └── memory.md
└── memory/
    ├── MEMORY.md
    ├── decisions.md
    └── session-log.md
```

---

## HUKUM DEV-BRAIN

1. **CAVEMAN MODE** — bicara pendek, kata kerja dulu, hasil = bukti
2. **PIPELINE OTOMATIS** — MIKIR→BAYANG→GODOK→BANGUN→TEST→AUDIT→FIX→INGAT→LAPOR
3. **MEMORI** — awal sesi recall, akhir tugas remember
4. **DELEGASI** — DEV panggil sub-agent otomatis via task tool
5. **BERHENTI** — hanya untuk destruktif besar, force push, install sistem, biaya
6. **BAHASA** — ikuti bahasa user, default Indonesia

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
