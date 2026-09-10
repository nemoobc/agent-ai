---
description: scaffold — generate project boilerplate React/Next.js/Express/FastAPI/Go/Rust via DEV
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan skill scaffold: setup proyek baru dari nol — pilih stack, generate, langsung siap coding.

## Usage

```
/scaffold [stack] [nama-project]
```

- `stack` — react, nextjs, express, fastapi, go, rust, atau pilihan lain
- `nama-project` — nama direktori project baru

## Triggers

- **skill scaffold** — generate boilerplate
- **skill test** — verify setup berhasil

## Example

```
/scaffold react my-dashboard
/scaffold express api-server
/scaffold fastapi ml-service
/scaffold go microservice
```

## Expected Output

```
SCAFFOLD: SELESAI
├── STACK: React 18 + Vite + TypeScript
├── NAMA: my-dashboard
├── STRUCTURE:
│   ├── src/components/
│   ├── src/hooks/
│   ├── src/pages/
│   ├── tests/
│   └── package.json
├── SETUP: npm install → 0 errors
├── TEST: npm test → PASS (1 assertion)
└── STATUS: siap coding
```

## Error Cases

- **Stack tidak dikenali** → lapor stack yang didukung
- **Project sudah ada** → tanya user: overwrite atau cancel
- **npm/yarn tidak tersedia** → lapor dependency yang dibutuhkan

## Related Commands

- `/bootstrap** — pasang DEV-BRAIN (bukan project baru)
- `/build** — bangun fitur di project yang ada
- `/onboard** — onboarding setelah scaffold
