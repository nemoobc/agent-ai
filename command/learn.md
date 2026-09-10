---
description: LEARN — ekstrak pelajaran dari tugas/sesi terakhir jadi lessons.md terukur (Pola/Bukti/Aksi), lalu sinkron keputusan ke decisions.md bila mengubah aturan.
agent: dev
---
TUGAS: $ARGUMENTS

1. skill recall — baca konteks sesi & memori.
2. skill learn — ekstrak pelajaran dari tugas terakhir (atau $ARGUMENTS bila diisi): POLA + BUKTI + AKSI.
3. Tulis entry ke memory/lessons.md (teratas). Duplikat → perbarui yang lama.
4. Pelajaran mengubah aturan kit → tambah 1 baris ke decisions.md (skill remember).
5. Lapor gaya caveman: jumlah entry, perubahan aturan (bila ada).

## Usage

```
/learn [topik spesifik]
```

- `topik spesifik` — fokus pelajaran dari topik tertentu. Kosong = dari sesi terakhir.

## Triggers

- **skill recall** — baca memori sesi
- **skill learn** — ekstrak pelajaran terstruktur
- **skill remember** — simpan keputusan baru

## Example

```
/learn
/learn "npm audit offline false-positive"
/learn "race condition di concurrent update"
```

## Expected Output

```
LEARN: 1 entry baru ke lessons.md
├── POLA: npm audit tanpa lockfile selalu report false-positive
├── BUKTI: eval.sh test case ke-5 membuktikan
├── AKSI: jangan pakai npm audit tanpa lockfile di test
└── DECISIONS: tidak ada perubahan aturan
TOTAL: 13 entry di lessons.md
```

## Error Cases

- **Tidak ada pelajaran baru** → lapor "tidak ada pelajaran signifikan"
- **lessons.md corrupt** → backup + buat baru
- **Pelajaran bertentangan** → konfirmasi user

## Related Commands

- `/memory** — tampilkan ingatan
- `/handoff** — pelajaran masuk handoff
- `/report** — pelajaran masuk laporan sesi
