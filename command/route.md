---
description: ROUTE — router intensitas prompt: NORMAL / FULL / ULTRA. Jalur menentukan cakupan pipeline, delegasi agent, dan mode caveman sebelum eksekusi.
agent: dev
---
PROMPT: $ARGUMENTS

1. `bash skills/route/run.sh "<PROMPT>"` — hasil: JALUR + PEMICU + KELAS.
2. Terapkan jalur (skills/route/SKILL.md):
   - NORMAL = jalur inti, delegasi minimal.
   - FULL = inti + critic + doc-full + clean.
   - ULTRA = PANGGIL SEMUA: 11 agent + caveman ULTRA + skill gerbang wajib + verify 10 gerbang sebelum lapor.
3. Tampilkan marker `[ROUTE] <jalur> — pemicu: <kata>` di rencana + laporan.
4. Jalur ≠ bahasa: caveman tetap nyala di semua jalur; hukum & gerbang sama semua jalur.

GERBANG: prompt pemicu dieksekusi NORMAL = DILARANG; prompt biasa dipaksa ULTRA = DILARANG (boros).

## Usage

```
/route [prompt]
```

- `prompt` — prompt user yang akan diklasifikasikan

## Triggers

- **bash skills/route/run.sh** — classifier intensitas
- **HUKUM 13** — router intensitas wajib sebelum eksekusi

## Example

```
/route deploy backend hari ini
/route lengkapin dashboard user
/route panggil semuanya semua agent
```

## Expected Output

```
ROUTE: JALUR NORMAL
├── PEMICU: tidak ada (prompt biasa)
├── KELAS: kerja langsung tanpa summon agent
└── MODE: respon biasa, hukum & gerbang tetap aktif

ROUTE: JALUR FULL
├── PEMICU: "lengkapin" (trigger: Lengkapin)
├── KELAS: kerja lebih dalam + critic + doc-full + clean
└── MODE: riset+test+dok+critic ringan

ROUTE: JALUR ULTRA
├── PEMICU: "panggil semuanya" (trigger: ULTRA eksplisit)
├── KELAS: PANGGIL SEMUA — 11 agent + caveman ULTRA
└── MODE: skill gerbang wajib + verify penuh
```

## Error Cases

- **Prompt kosong** → lapor "prompt tidak boleh kosong"
- **Route run.sh tidak ada** → fallback manual berdasarkan kata kunci

## Related Commands

- `/ship** — eksekusi pipeline sesuai jalur
- `/plan** — plan 8 blok, jalur menentukan cakupan
- `/verify** — verify wajib di semua jalur

