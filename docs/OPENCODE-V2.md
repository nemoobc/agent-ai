# OPENCODE V2 — RISET DOKUMENTASI RESMI

> Referensi ringkas OpenCode V2 (upstream 2.x) untuk pengembangan agent-ai.
> Sumber: https://opencode.ai/v2/docs (diakses 2026-09-22).
> Versi CLI yang dibundel opencode-termux: upstream 2.2.0.

## 1. INSTALL & INTERFACE

| Cara | Perintah |
|------|----------|
| curl | `curl -fsSL https://opencode.ai/v2/install \| bash` |
| homebrew | `brew install anomalyco/tap/opencode-v2` |
| npm | `npm install -g @opencode/cli` |
| bun | `bun install -g --trust @opencode/cli` |
| pnpm | `pnpm add -g --allow-build=@opencode/cli @opencode/cli` |
| yarn | `yarn global add @opencode/cli` |

- Binary standalone per platform (darwin/linux glibc+musl/windows, x64/arm64, variant `baseline`).
- Antarmuka: TUI (terminal), Desktop (dmg/deb/rpm/AppImage), Web (`opencode pair` → URL+user+pass lokal), Docker (`ghcr.io/anomalyco/opencode:2.0.0`).

## 2. CONFIG (`opencode.json(c)`)

- JSON atau JSONC. Global: `~/.config/opencode/opencode.json(c)`. Project: `opencode.json(c)` atau `.opencode/opencode.json(c)`.
- Precedence (rendah→tinggi): global → direct project (dari akar proyek mendekat) → `.opencode` dir (mendekat). `.opencode` selalu override direct.
- `$schema`: `https://opencode.ai/config.json`.
- `update`: `"disable" | "notify" (default) | "auto"` — hanya dibaca dari config global.
- `shell`: shell untuk terminal & shell tools. `model`: `provider/model` (root tidak simpan `#variant`).
- `default_agent`: primary agent sesi default.
- `permissions`: array ATURAN (V2); V1 pakai `permission` objek — **jangan pakai `bash`; pakai `shell`**.
- `agents`, `skills`, `commands`, `plugins`, `mcp`, `providers`, `references`, `worktree`, `snapshots` (bool), `formatter` (bool), `media` (resize gambar), `tool_output` (max lines/bytes), `websearch` (`"provider": "random"`), `compaction` (`auto` + `keep.tokens` + `buffer`), `warming` (keep-alive session, nonaktif default), `watcher.ignore`, `instructions` (diterima tapi TIDAK dimuat — pakai `AGENTS.md`).
- V2 legacy yang harus dihindari di agent config: `temperature`, `top_p`, `prompt`, `permission`, `tools`, `disable`, `maxSteps` (pakai `steps`).

## 3. AGENTS

### Lokasi & format
- Markdown: `~/.config/opencode/agents/<name>.md` (global) atau `.opencode/agents/<name>.md` (project). Body = system prompt. Frontmatter = `description`, `mode`, `model`, `permissions`, `steps`, `hidden`, `color`, `disabled`, `request`.
- JSONC: entri `agents.<id>` di config. Path nested → ID `team/reviewer`.

### Mode
| Mode | Perilaku |
|------|----------|
| `primary` | Agent utama sesi (default baru) |
| `subagent` | Anak sesi via `subagent` tool |
| `all` | Keduanya |

### Builtin V2 (penting!)
| Agent | Mode | Tugas |
|-------|------|-------|
| `build` | primary | Coding default; tools diizinkan; baca env + akses luar workspace = ask |
| `plan` | primary | Eksplorasi & rencana tanpa edit file normal |
| `general` | subagent | Riset & multi-step; tidak bisa luncurkan subagent |
| `explore` | subagent | Baca & cari (tidak edit) |
| `compaction`/`title`/`summary` | hidden | Maintenance — tidak bisa dipilih |

**V2 tidak punya built-in `scout`.** Override builtin = definisikan ID yang sama. Merge: permintaan merge by key, permission APPEND (rule global dulu, agent menyusul — last match wins).

### Opsi
- `model`: `provider/model#variant` atau bentuk ekspansi `{providerID, model, variant}`. Subagent pakai model sendiri atau warisi sesi.
- `system`: ganti prompt dasar provider (instruksi project/AGENTS.md tetap ditambahkan).
- `steps`: max langkah model (positif); terakhir: tools dilepas, model diminta ringkas.
- `permissions`: ordered rules dengan wildcard — broad rule DULU, exception menyusul.
- `disabled: true` menghapus agent pada titik config itu.

## 4. SKILLS

- Struktur: `.opencode/skills/<skill-id>/SKILL.md` (+ scripts/references relatif ke SKILL.md). Bentuk flat `skills/<name>.md` juga valid (root source).
- Discovery otomatis: `~/.config/opencode/skills`, `~/.claude/skills`, `~/.agents/skills`, `.opencode/skills`, `.claude/skills`, `.agents/skills` (project, dari akar mendekat). Tambahan via config `skills: [paths|URL]` (combined, bukan replace). URL = HTTP catalog (`index.json`, download `<base>/<name>/<file>`, bump `version` saat berubah).
- Frontmatter: `name` (label saja — **ID = path**, case-sensitive), `description` (wajib supaya diiklankan; tanpa description = tidak diiklankan), `slash` / `metadata.opencode/slash` (false = sembunyi dari catalog), `metadata.opencode/autoinvoke` (false = sembunyi dari daftar model, tetap bisa di-load eksplisit).
- ID portable: `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 char.
- Loading: model panggil tool `skill` dengan ID; cek permission `skill`; body ditambahkan TANPA frontmatter; path base + sampel ≤10 file pendukung disediakan (isi TIDAK auto-load).
- Permission skill: `{action: "skill", resource: "<id>", effect}` — `deny` = disembunyikan & ditolak.
- Precedence: builtin → `.claude` → `.agents` → global `~/.config/opencode/skills` → project `.opencode/skills` (mendekat) → config `skills` (terakhir = menang).

## 5. COMMANDS

- Markdown: global `~/.config/opencode/commands/`, project `.opencode/commands/`. Hanya `.md`. Nested → `/team/review`. Direktori legacy `command/` masih dibaca (pakai `commands/` untuk baru). Body = template prompt.
- JSON: `commands.<name> = {template (wajib), description, agent, model, subagent}`. `subtask` deprecated alias `subagent` (subagent menang bila dua-duanya ada).
- Argumen: `$ARGUMENTS` (full string), `$1/$2` (posisional, quote di-group, highest-numbered = tangkap sisa), tanpa placeholder → args ditambahkan setelah blank line.
- Shell inline (ampas hati-hati!): `!` + backtick dijalankan SAAT evaluasi command, DI LUAR permission flow agent — hanya source terpercaya.
- `subagent: true` → latar belakang child session; model command override model agent; model agent override model sesi.
- Reload otomatis saat file berubah.

## 6. PERMISSIONS (V2)

- Rule: `{action, resource, effect}` dengan effect `allow|deny|ask`. **Last match wins** — broad dulu, exception belakangan.
- No match → default `ask`.
- Wildcard: `*` (0+ karakter termasuk `/`), `?` (1). Pattern shell berakhiran ` *` juga cocok tanpa args (`git status *` cocok `git status`).
- Action built-in: `read`, `edit`, `glob`, `grep`, `shell`, `subagent`, `skill`, `question`, `webfetch`, `websearch`, `external_directory`, `<server>_<tool>` (MCP, `*` resource), `execute` (Code Mode).
- Path: normalize backslash→slash; `~`/`$HOME` di-expand untuk `read`/`edit`/`external_directory`, TIDAK untuk shell.
- Multi-resource check: ada `deny` → deny; else ada `ask` → ask; else allow.
- Default policy: semua allow, tapi `external_directory *` ask, `read *.env*` ask (`*.env.example` allow). `plan` deny edit di luar `~/.opencode/plan`; `explore` deny semua kecuali baca/glob/grep/web; `general` deny question + subagent.
- Approvals: `once` / `always` (tersimpan durable per-project: `shell: git status * → allow`) / `reject`. Saved approval TIDAK pernah override configured `deny`.
- Directory eksternal butuh `external_directory` approval sebelum `read`/`edit`.
- Policies (`experimental.policies`): hard-deny provider.use / permission check — menang atas config project (governance).
- Scanner portabel: `experimental.portable_shell_scanner: true` (gantikan tree-sitter; perintah tak-teranalisa = error scanner, bukan denial).

## 7. CLI SETTINGS (`~/.config/opencode/cli.json`, `$schema: https://opencode.ai/v2/cli.json`)

- Global saja (tidak ada project-local). Inline override: env `OPENCODE_CLI_CONFIG_CONTENT` (authoritative selama diset).
- `theme.{name,mode}` · `animations` · `cursor.{style,blinking}`
- `mouse` · `scroll.{speed,acceleration}` · `prompt.{editor,paste:compact|full,image_preview}`
- `session.{sidebar,scrollbar,thinking,grouping,image_preview,tps,markdown,new_location,permissions:prompt|autoaccept}`
- `tabs.{mode:auto|on|off,scope:cwd|global,layout,indicators:status|numbers}` (legacy `tabs.enabled` tetap dibaca)
- `diffs.{source:branch|committed|working,wrap,tree,single,view}`
- `attention.{notifications,sound,volume,sound_pack,sounds.{default,question,permission,error,done,subagent_done}}`
- `terminal.{title,copy:manual|select}` · `mini.{thinking,tools,shell_output,turn_summary,footer,splash,work_spinner,mono,replay,replay_limit}`
- `keybinds.<command>` + `leader.timeout` (ms) · `plugins` (CLI-only) · `debug.{devtools,timing,turn_tokens}` · `experimental` (feature IDs dari dialog Experiments)

## 8. IMPLIKASI UNTUK AGENT-AI (catatan teknis)

1. **Deteksi V2** — marker kuat config V2: `permissions` (array) + `shell` action; marker V1: `permission` + `bash`. `$schema: https://opencode.ai/config.json` dipakai dua-duanya (docs contoh V2 tetap schema config.json; schema khusus CLI `/v2/cli.json`).
2. **Installer** — saat ini `write_config_v2` menulis `permissions:[{action:"*",resource:"*",effect:...}]` + `update:"notify"` + `snapshots:false` — sesuai dokumen (valid).
3. **Command wrapper** — kit meng-copy command `.md` ke `commands/` untuk V2 → benar; folder `command/` legacy masih dibaca V2 tapi jangan dipakai untuk baru.
4. **Skill** — kit pakai `skills/<id>/SKILL.md` + `run.sh` + frontmatter `name`/`description` → sesuai; tambah `description` di semua skill supaya diiklankan.
5. **Default permissions** — V2 default ask untuk hal sensitif; kit menulis `effect: ask` untuk semua → aman & sesuai.
6. **Agent subagent** — opencode V2 built-in `general`/`explore` = subagent; kit menambah agent dev/coder/dst → path `~/.config/opencode/agents/*.md` (V2) benar.