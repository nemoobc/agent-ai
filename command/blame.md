---
description: BLAME — ringkas git blame per file: siapa mengubah apa, kapan, pesan commit → konteks untuk memahami kode.
agent: dev
---
TUGAS: $ARGUMENTS

1. File target dari $ARGUMENTS. Bila kosong → file yang paling baru berubah (git log -1 --name-only).
2. `git blame <file>` → kelompokkan per commit/penulis: fungsi/baris kunci siapa yang menulis kapan + pesan commit (git log -1 <hash> --format=%s).
3. Ringkas: 1 baris per area berubah (file:baris — penulis — kapan — pesan commit). Tanpa menghakimi penulis.
4. Bila ada area tidak jelas → tawarkan: bedah baris itu dengan skill explain.
5. JANGAN mengubah kode — /blame untuk memahami.

## Usage

```
/blame [file]
```

- `file` — path file untuk di-blame. Kosong = file terbaru berubah.

## Triggers

- **git blame** — data blame mentah
- **git log** — pesan commit konteks
- **skill explain** — bedah baris tidak jelas (opsional)

## Example

```
/blame src/auth.js
/blame skills/git-guard/run.sh
/blame
```

## Expected Output

```
BLAME: src/auth.js (142 baris, 3 penulis)
├── 1-18   — @alice — 2026-03-15 — "init auth module"
├── 19-85  — @bob   — 2026-05-20 — "add rate limiting"
└── 86-142 — @alice — 2026-08-01 — "fix token refresh"
AREA TIDAK JELAS: baris 42-48 (blame campur aduk) → /blame src/auth.js:42 ?
```

## Error Cases

- **File tidak ada** → lapor path salah + saran nama mirip
- **Bukan git repo** → lapor "bukan git repo"
- **File binary** → lapor "file binary, blame tidak tersedia"

## Related Commands

- `/explain` — bedah kode lebih dalam
- `/report** — konteks blame masuk ke laporan sesi
- `/handoff** — blame jadi bagian konteks untuk agent berikutnya
