---
description: auto-prompt — Generate prompt lengkap & matang dari input kasar/pendek
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan auto-prompt generator: analisis input user, deteksi domain & bahasa, generate prompt lengkap dengan aturan, output, dan kriteria sukses. Via shell: `bash skills/auto-prompt/run.sh "$ARGUMENTS"`.

## Usage

```
/auto-prompt [input user]
```

## Triggers

- **bash skills/auto-prompt/run.sh "input"** — eksekusi langsung dari shell
- **user kasih prompt pendek/kasar** — DEV auto-generate prompt lengkap

## Example

```
/auto-prompt bikin fitur login

╔══════════════════════════════════════════════════════════════╗
║                    AUTO-PROMPT GENERATED                      ║
╚══════════════════════════════════════════════════════════════╝

## KONTEKS
- Domain: autentikasi
- Bahasa: JavaScript/TypeScript
- Input awal: "bikin fitur login"

## TUJUAN
Buat/ubah/implementasikan: bikin fitur login

## ATURAN
1. Ikuti konvensi project yang sudah ada
2. Semua perubahan wajib punya test
3. Diff kecil & fokus
4. Error handling wajib ada
5. Dokumentasi update jika perlu

## EXPECTED OUTPUT
- Kode bersih, tanpa TODO tersembunyi
- Test hijau
- Tidak ada breaking change
- Commit message jelas

## SUCCESS CRITERIA
- [ ] Fitur berfungsi
- [ ] Test pass
- [ ] Tidak ada regression
- [ ] Code review ready
```

## Expected Output

```
AUTO-PROMPT GENERATED
├── DOMAIN  : autentikasi
├── BAHASA  : JavaScript/TypeScript
├── ATURAN  : 5 aturan
└── STATUS  : prompt siap pakai
```

## Error Cases

- **Input kosong** → minta input dari user
- **Input terlalu vague** → generate prompt generic + saran spesifikasi

## Related Commands

- `/plan` — generate rencana 8 blok dari prompt
- `/build` — eksekusi prompt yang sudah jadi
- `/route` — klasifikasi intensitas tugas
