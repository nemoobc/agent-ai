---
description: BACKLOG — antrian kerja terukur: tiap item punya definisi selesai + skor dampak×usaha + status. Sumber skill milestone & /roadmap.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill recall + baca `.opencode/backlog.md` bila ada, selain itu mulai baru.
2. Tambah item dari $ARGUMENTS: tiap item = judul + definisi selesai terukur + skor (dampak 1–5 × usaha 1–5 dibalik, gaya /roadmap) + sumber (user/audit/perf/metrics).
3. Tampilkan papan: ID | item | skor | definisi selesai | status (ANTRE/JALAN/SELESAI).
4. Bila user minta mulai → item teratas masuk pipeline penuh (skill milestone bila besar, plan 8 blok selalu).
5. Simpan papan kembali ke `.opencode/backlog.md` (project) atau memori global bila tidak ada project.

GERBANG: item tanpa definisi selesai = masuk paksa diberi definisi, atau ditolak.

## Usage

```
/backlog [add <judul> | start <ID> | list | done <ID>]
```

- `add <judul>` — tambah item baru ke antrian
- `start <ID>` — mulai eksekusi item
- `list` — tampilkan semua item
- `done <ID>` — tandai selesai

## Triggers

- **skill recall** — baca memori + keputusan sebelumnya
- **skill milestone** — untuk item XL yang perlu milestone
- **skill plan** — plan 8 blok sebelum eksekusi

## Example

```
/backlog add "optimize query performance"
/backlog add "tambah test coverage auth module"
/backlog start 1
/backlog list
```

## Expected Output

```
BACKLOG — 4 item
ID | ITEM                          | SKOR | DEFINISI SELESAI           | STATUS
1  | optimize query performance    | 15   | query < 200ms p99          | ANTRE
2  | test coverage auth module     | 12   | coverage > 80%             | ANTRE
3  | fix memory leak               | 20   | no leak after 1h load test | JALAN
4  | upgrade dependencies          | 8    | all tests pass after upgrade| SELESAI
```

## Error Cases

- **Item tanpa definisi selesai** → ditolak atau dipaksa isi definisi
- **ID tidak ditemukan** → lapor ID valid yang tersedia
- **Backlog file corrupt** → buat baru + catat di memori

## Related Commands

- `/roadmap` — prioritasi backlog berdasar dampak×usaha
- `/estimate` — isi skor usaha untuk item
- `/milestone` — untuk item XL yang perlu dipecah
