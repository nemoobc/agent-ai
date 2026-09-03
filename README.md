# Agent - OpenCode Termux Configuration

Konfigurasi agent, skill, dan command untuk OpenCode di Termux Android.

## Ringkasan

Repo ini berisi konfigurasi lengkap untuk menjalankan OpenCode agent di Termux:

### Agent
- **AUTODEV** - Agent utama autonomous engineering (primary mode)
- **REVIEWER** - Red team reviewer untuk security + correctness check

### Skill (17 skill folders + 13 autodev skills)
| Skill | Fungsi |
|-------|--------|
| `automation-integrations` | Script, scheduler, webhook, API integration |
| `backend-api` | Service, API, auth, webhook, queue |
| `code-review` | Risk-focused code review |
| `codebase-discovery` | Repository discovery & conventions |
| `data-analysis` | CSV, JSON, SQL analysis, metrics |
| `database` | SQL, schema, migrations, ORM |
| `debugging` | Evidence-based debugging, root cause |
| `devops-platform` | Docker, CI/CD, Linux, deployment |
| `documentation` | README, API docs, ADR, runbook |
| `frontend-ui` | HTML, CSS, React, Vue, browser UI |
| `incident-response` | Incident triage, recovery, postmortem |
| `observability` | Logging, metrics, tracing, health check |
| `product-ux` | UX, user flow, interaction design |
| `research-docs` | Official docs research, fact-check |
| `security-defensive` | Secure coding, threat model, remediation |
| `software-engineering` | Production-quality implementation |
| `testing-qa` | Unit, integration, E2E testing |

### Autodev Skills (13 skills di autodev.md)
| # | Skill | Fungsi |
|---|-------|--------|
| 1 | READ BEFORE EVERYTHING | Anti-hallucination, verify sebelum claim |
| 2 | AUTO STACK DETECT | Auto deteksi Node/Python/Go/Rust/etc |
| 3 | AUTODEV LOOP | Mandatory: detect→plan→build→audit→test→fix→report |
| 4 | SAFE SHELL | No root, no proot, quote var |
| 5 | HONESTY MODULE | Ga bohong, ga nebak, paste error asli |
| 6 | GIT CHECKPOINT | Safety net sebelum refactor |
| 7 | NOTIFY | termux-notification best effort |
| 8 | MEMORY | LOG.md + ~/.autodev/memory.md |
| 9 | TERMUX GOTCHA | Error patterns, jangan cari ulang |
| 10 | RED TEAM GATE | Wajib reviewer sebelum done |
| 11 | SMART READ | Hemat context file gede |
| 12 | DEPS AUDIT | npm audit, pip check |
| 13 | AUTO MODEL GATE | Kalibrasi otomatis 6 skenario |

### Command (10 command)
| Command | Fungsi |
|---------|--------|
| `mulai` | Mulai sesi baru |
| `lanjut` | Lanjut sesi sebelumnya |
| `selesai` | Selesai & wrap up |
| `cek` | Cek status project |
| `fix` | Fix masalah |
| `bersih` | Bersihkan file |
| `kalibrasi` | Kalibrasi agent |
| `audit` | Audit kode |
| `rapor` | Laporan hasil |
| `autodev` | Jalankan AUTODEV |

## Struktur Folder

```
Agent/
├── README.md
├── AGENTS.md              # Global rules untuk semua agent
├── opencode.json          # Config OpenCode
├── autodev/
│   └── memory.md          # Memory global AUTODEV
├── agents/
│   └── config-agents/     # Agent dari ~/.config/opencode
│       ├── autodev.md     # AUTODEV + 13 skills + caveman ultra
│       └── reviewer.md    # Red team reviewer
├── command/               # Custom commands
│   ├── mulai.md
│   ├── lanjut.md
│   ├── selesai.md
│   ├── cek.md
│   ├── fix.md
│   ├── bersih.md
│   ├── kalibrasi.md
│   ├── audit.md
│   ├── rapor.md
│   └── autodev.md
└── skills/
    ├── config-skills/     # Skills dari ~/.config/opencode (17 skill)
    ├── opencode-skills/   # Skills dari ~/.opencode
    └── agents-skills/     # Skills dari ~/.agents
```

## Instalasi

### Prasyarat
- Android 8+ dengan Termux terinstall
- Node.js 18+ ( `pkg install nodejs` )
- OpenCode CLI terinstall

### Cara Install

1. **Clone repo ini:**
```bash
git clone https://github.com/nemoobc/Agent.git ~/Agent
```

2. **Copy agent & skills ke Termux:**
```bash
# Backup config lama (opsional)
mv ~/.config/opencode/agent ~/.config/opencode/agent.bak 2>/dev/null
mv ~/.config/opencode/skills ~/.config/opencode/skills.bak 2>/dev/null

# Copy agent baru
cp -r ~/Agent/agents/config-agents ~/.config/opencode/agent

# Copy skills baru
cp -r ~/Agent/skills/config-skills/* ~/.config/opencode/skills/

# Copy command
cp -r ~/Agent/command ~/.config/opencode/command

# Copy AGENTS.md
cp ~/Agent/AGENTS.md ~/.config/opencode/AGENTS.md

# Copy autodev memory
cp -r ~/Agent/autodev ~/.autodev
```

3. **Verifikasi:**
```bash
# Cek agent
ls ~/.config/opencode/agent/
# Output: autodev.md reviewer.md

# Cek skills
ls ~/.config/opencode/skills/
# Output: automation-integrations backend-api ...

# Cek command
ls ~/.config/opencode/command/
# Output: mulai.md lanjut.md selesai.md ...
```

4. **Jalankan OpenCode:**
```bash
opencode
```

### Instalasi Manual (Tanpa Clone)

Jika tidak ingin clone, copy folder secara manual:

```bash
# Buat direktori
mkdir -p ~/.config/opencode/agent
mkdir -p ~/.config/opencode/skills
mkdir -p ~/.config/opencode/command

# Copy file agent
cp agents/config-agents/*.md ~/.config/opencode/agent/

# Copy semua skills
cp -r skills/config-skills/* ~/.config/opencode/skills/

# Copy command
cp command/*.md ~/.config/opencode/command/

# Copy AGENTS.md
cp AGENTS.md ~/.config/opencode/
```

## Config OpenCode

File `opencode.json`:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "share": "disabled"
}
```

Model default: `opencode/mimo-v2.5-free` (gratis, recommended).

## Tips

- **Bahasa**: Agent default pakai Bahasa Indonesia
- **Caveman Ultra**: Komunikasi super pendek, stak, tanpa basa-basi
- **No root**: Semua berjalan di Termux tanpa root
- **Port aman**: Hanya pakai port >= 1024

## Lisensi

MIT - Bebas dipakai dan dimodifikasi.

## Author

**nemoobc** - [GitHub](https://github.com/nemoobc)
