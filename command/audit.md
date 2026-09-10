---
description: Audit penuh — audit-full + review manual + lapor temuan prioritas
agent: dev
---
TUGAS: $ARGUMENTS

Mode audit penuh:
1. skill test-full → pastikan test hijau dulu (merah? task fixer dulu)
2. skill audit-full → kumpulkan temuan script
3. Review manual gaya AUDITOR: input, otorisasi, injection, secret, error handling, duplikasi, kode mati
4. Urutkan temuan [P0..P3], lapor gaya caveman
5. Ada temuan? task fixer langsung → ulang audit sampai CLEAN

## Usage

```
/audit [target]
```

- `target` — direktori, file, atau path spesifik untuk diaudit. Kosong = entire project.

## Triggers

- **skill test-full** — memastikan test hijau sebelum audit mulai
- **skill audit-full** — analisis otomatis secret, kerentanan, pola berbahaya
- **task critic** — serangan adversarial manual terhadap kode
- **task fixer** — perbaiki temuan P0/P1 secara otomatis

## Example

```
/audit
/audit src/auth/
/audit skills/git-guard/
```

## Expected Output

```
AUDIT: CLEAN / 3 temuan
├── P0: token hardcoded di src/auth.js:42
├── P1: error handler hilang di api/routes.js:18
└── P2: duplikasi logic di utils/parse.js:7,31
FIXED: P0 + P1 ditangani → ulang audit → CLEAN
```

## Error Cases

- **Test merah saat mulai** → fixer dipanggil dulu, baru audit jalan
- **Target tidak ada** → lapor "target tidak ditemukan", exit
- **audit-full tidak tersedia** → fallback ke review manual + lint

## Related Commands

- `/fix` — perbaiki temuan audit
- `/coverage` — peta gap test setelah audit
- `/critique` — serangan adversarial tambahan
- `/verify` — audit + test penuh sekaligus
