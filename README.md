# agent-ai

Konfigurasi agent, skill, dan command untuk OpenCode — Linux + Termux Android. Instalasi instan 1 script.

## Apa Ini

- **2 agent**: AUTODEV (primary, full-stack + security + QA) + REVIEWER (red team subagent)
- **17 skill**: code-review, debugging, security, devops, frontend, backend, dll
- **11 command**: mulai, lanjut, selesai, cek, fix, bersih, kalibrasi, audit, rapor, autodev, import
- **13 autodev skills**: anti-hallucination, auto stack detect, git checkpoint, caveman ultra, dll

## Install

### Termux

```bash
curl -fsSL -o install.sh https://raw.githubusercontent.com/nemoobc/agent-ai/master/install.sh
bash install.sh
```

### Linux

```bash
curl -fsSL -o install.sh https://raw.githubusercontent.com/nemoobc/agent-ai/master/install.sh
bash install.sh
```

### Check Status

```bash
bash install.sh --check
```

### Uninstall

```bash
bash install.sh --uninstall
```

### Install Versi Tertentu

```bash
bash install.sh --version 1.0.0
```

## Struktur

```
agent-ai/
├── install.sh              # Universal installer (auto-detect Termux/Linux)
├── AGENTS.md               # Global rules
├── opencode.json           # Config
├── autodev/
│   └── memory.md           # Template memory
├── agents/
│   └── config-agents/
│       ├── autodev.md      # AUTODEV agent (definition)
│       ├── autodev-skills.md # 13 autodev skills (detail)
│       └── reviewer.md     # REVIEWER agent (red team)
├── command/                # 11 custom commands
│   ├── mulai.md
│   ├── lanjut.md
│   ├── selesai.md
│   ├── cek.md
│   ├── fix.md
│   ├── bersih.md
│   ├── kalibrasi.md
│   ├── audit.md
│   ├── rapor.md
│   ├── autodev.md
│   └── import.md
└── skills/
    └── config-skills/      # 17 opencode skills
        ├── automation-integrations/
        ├── backend-api/
        ├── code-review/
        ├── codebase-discovery/
        ├── data-analysis/
        ├── database/
        ├── debugging/
        ├── devops-platform/
        ├── documentation/
        ├── frontend-ui/
        ├── incident-response/
        ├── observability/
        ├── product-ux/
        ├── research-docs/
        ├── security-defensive/
        ├── software-engineering/
        └── testing-qa/
```

## Agent

### AUTODEV (Primary)

Senior full-stack engineer + security auditor + QA tester. CAVEMAN ULTRA mode — reply pendek, stak, langsung gas.

Override: ketik `/normal` untuk mode normal, `/caveman` untuk balik ultra.

13 skills: anti-hallucination, auto stack detect, autodev loop, safe shell, honesty module, git checkpoint, notify, memory, termux gotcha, red team gate, smart read, deps audit, auto model gate.

### REVIEWER (Subagent)

Red team reviewer. Read-only, dipanggil AUTODEV untuk second opinion. Output: `[HIGH]`/`[MED]`/`[LOW]` per file:line.

## Skills

17 skills untuk berbagai domain:

| Skill | Fungsi |
|-------|--------|
| automation-integrations | Script, scheduler, webhook, API |
| backend-api | Service, API, auth, queue |
| code-review | Risk-focused code review |
| codebase-discovery | Repo discovery & conventions |
| data-analysis | CSV, JSON, SQL, metrics |
| database | SQL, schema, migrations |
| debugging | Evidence-based debugging |
| devops-platform | Docker, CI/CD, Linux |
| documentation | README, API docs, ADR |
| frontend-ui | HTML, CSS, React, Vue |
| incident-response | Triage, recovery, postmortem |
| observability | Logging, metrics, tracing |
| product-UX | UX, user flow, accessibility |
| research-docs | Official docs research |
| security-defensive | Secure coding, threat model |
| software-engineering | Production implementation |
| testing-qa | Unit, integration, E2E |

> Catatan: 17 skills ini mirip dengan yang sudah ada di opencode built-in. Yang membedakan adalah autodev agent dan 13 autodev skills yang lebih spesifik untuk workflow autonomous engineering.

## Binary

agent-ai cuma konfigurasi. Butuh binary opencode:

- **Termux**: [opencode-termux](https://github.com/nemoobc/opencode-termux)
- **Linux**: `npm install -g opencode-ai`

## Lisensi

MIT
