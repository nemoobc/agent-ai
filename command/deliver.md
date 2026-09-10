---
description: Serah kerja tanpa git: zip → upload tmpfiles.org → link (dilarang commit/push)
agent: dev
---
TUGAS: /deliver [jam]

1. Guard dulu: bash skills/git-guard/run.sh — merah → BATAL, lapor temuan, tidak ada zip.
2. Zip: bash skills/deliver/run.sh ${1:-24} — buat arsip isi kerja (tanpa .git), upload tmpfiles.org.
3. Lapor: ukuran + jumlah file + link unduh + masa hidup + "hapus manual bila perlu".
4. DILARANG: git commit, git push, atau perintah git apa pun. User yang pegang repo.
GERBANG: tanpa permintaan eksplisit user → upload DILARANG (HUKUM 5).

## Usage

```
/deliver [masa_hidup_jam]
```

- `masa_hidup_jam` — berapa jam file bertahan di server. Default: 24 jam.

## Triggers

- **bash skills/git-guard/run.sh** — cek secret sebelum deliver
- **bash skills/deliver/run.sh** — buat zip + upload
- **HUKUM 5** — tidak ada git push/commit

## Example

```
/deliver
/deliver 48
```

## Expected Output

```
DELIVER: SELESAI
├── GIT-GUARD: CLEAN (tidak ada secret)
├── ZIP: 2.3 MB (47 file)
├── LINK: https://tmpfiles.org/12345/agent-ai.zip
├── MASA HIDUP: 24 jam
└── CATATAN: hapus manual bila perlu
DILARANG: git commit/push oleh deliver
```

## Error Cases

- **git-guard merah** → BATAL, tidak ada zip, lapor temuan
- **Upload gagal** → lapor error + saran retry
- **Project kosong** → lapor "tidak ada file untuk di-deliver"
- **User tidak eksplisit minta** → upload DILARANG

## Related Commands

- `/ship` — pipeline penuh tanpa deliver (internal)
- `/release` — rilis resmi via git tag
- `/handoff` — serah konteks ke agent berikutnya
