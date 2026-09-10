---
description: COVERAGE — peta gap test heuristik: fungsi tanpa reference di test → daftar + prioritas backlog.
agent: dev
---
TUGAS: $ARGUMENTS

1. `bash skills/coverage/run.sh` (dari root project) — peta gap.
2. Baca hasil: area kritis (auth/data/publik) dengan gap → konfirmasi manual dulu.
3. Gap valid → masuk /backlog dengan definisi selesai + kasus test (skill test-design).
4. Lapor: total fungsi, gap, yang masuk backlog.

## Usage

```
/coverage [target]
```

- `target` — direktori/file spesifik. Kosong = entire project.

## Triggers

- **bash skills/coverage/run.sh** — pemetaan gap test heuristik
- **skill test-design** — desain kasus test untuk gap
- **/backlog** — gap valid masuk antrian kerja

## Example

```
/coverage
/coverage src/auth/
/coverage skills/git-guard/
```

## Expected Output

```
COVERAGE: 84 fungsi, 12 gap (14%)
├── KRITIS (3): auth.validate(), auth.refresh(), data.export()
├── SEDANG (5): utils.parse(), utils.format(), ...
├── RENDAH (4): helpers.*, internal.*
BACKLOG: 3 item KRITIS ditambahkan dengan definisi selesai
```

## Error Cases

- **coverage/run.sh tidak ada** → fallback grep manual + lapor limitasi
- **Project tanpa test sama sekali** → lapor "0% coverage, semua gap"
- **Target bukan direktori** → lapor

## Related Commands

- `/audit` — audit mencakup coverage gap
- `/backlog** — gap masuk antrian
- `/test-design** — desain kasus test untuk gap
