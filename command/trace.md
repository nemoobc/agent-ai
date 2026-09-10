---
description: Bangun rantai bukti (HUKUM 11) untuk laporan — klaim tanpa bukti dihapus atau dites dulu
agent: dev
---
TUGAS: /trace

1. Daftar semua klaim yang akan dilaporkan.
2. Tiap klaim isi format: KLAIM → BENTUK (TEST/AUDIT/ANGKA/OUTPUT/FILE) → BUKTI (exit code / file:baris / jumlah) → SELAIN (yang tidak dibuktikan).
3. Klaim yang tidak bisa diisi BUKTI: tes dulu (test-full/audit-full) atau hapus dari laporan.
4. Output: tabel rantai bukti + baris SELAIN wajib ada. Tanpa SELAIN = tidak sah.

## Usage

```
/trace
```

- Tidak ada argument — buktikan semua klaim aktif

## Triggers

- **skill trace** — validasi rantai bukti
- **skill test-full** — bukti untuk klaim test
- **skill audit-full** — bukti untuk klaim audit
- **HUKUM 11** — rantai bukti wajib untuk setiap laporan

## Example

```
/trace
```

## Expected Output

```
RANTAI BUKTI — 5 klaim
├── KLAIM: test pass 42/42
│   BENTUK: TEST
│   BUKTI: bash tests/self-test.sh → exit 0
│   SELAIN: tidak diuji di production
├── KLAIM: audit CLEAN
│   BENTUCH: AUDIT
│   BUKTI: bash skills/audit-full/run.sh → exit 0
│   SELAIN: tidak mencakup third-party dependency
├── KLAIM: no secret
│   BENTUK: TEST
│   BUKTI: bash skills/git-guard/run.sh → exit 0
│   SELAIN: hanya mengecek staged diff
└── ...
STATUS: 5/5 klaim terbukti
```

## Error Cases

- **Klaim tanpa bukti** → tes dulu atau hapus dari laporan
- **Bukti tidak meyakinkan** → cari bukti lebih kuat
- **SELAIN kosong** → wajib isi (tidak ada klaim 100%)

## Related Commands

- `/audit** — audit menghasilkan bukti
- `/critique** — serangan adversarial ke klaim
- `/report** — laporan yang memuat rantai bukti
