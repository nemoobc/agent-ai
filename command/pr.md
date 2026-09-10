---
description: PR — siapkan pull request siap tempel dari diff: judul konvensional, ringkasan, perubahan, bukti test, checklist.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill pr — susun PR dari diff (`git diff <base>...HEAD` atau staged).
2. Sebelum disusun: test-full + audit-full + git-guard harus hijau (merah? /fix dulu).
3. Output format skill pr. Bila template `.github/PULL_REQUEST_TEMPLATE.md` ada → ikuti checklistnya.
4. Push/merge TIDAK dilakukan tanpa perintah eksplisit user (HUKUM 5 — aksi ke remote).

## Usage

```
/pr [base_branch]
```

- `base_branch` — branch target (default: main/master).

## Triggers

- **skill pr** — susun PR dari diff
- **skill test-full** — test wajib hijau
- **skill audit-full** — audit wajib CLEAN
- **skill git-guard** — guard secret wajib lolos

## Example

```
/pr
/pr main
/pr develop
```

## Expected Output

```
PR: feat/add-input-validation
├── BASE: main
├── DIFF: 3 file, +127 -45 baris
├── TEST: PASS (32/32, +8 baru)
├── AUDIT: CLEAN
├── GIT-GUARD: CLEAN
├── CHECKLIST:
    [x] Test ditambah
    [x] Audit bersih
    [x] Secret-free
    [x] Breaking change ditulis
    [ ] Docs diupdate (opsional)
└── STATUS: SIAP PUSH (menunggu perintah user)
```

## Error Cases

- **Test merah** → lapor "fix dulu, jalankan /fix"
- **Audit temukan P0/P1** → lapor + fix dulu
- **Tidak ada perubahan** → lapor "tidak ada diff untuk PR"
- **git-guard merah** → lapor secret yang ditemukan

## Related Commands

- `/release** — PR + merge + tag
- `/review** — review PR
- `/handoff** — konteks untuk reviewer
