# ROADMAP DEV-BRAIN DOCTRINE

Arah kit, bukan daftar keinginan. Setiap item = dampak × usaha, punya bukti selesai.

Status: `[ ]` belum, `[~]` berjalan, `[x]` selesai.

---

## TERPASANG (v1–v7) — ringkas

| Versi | Isi utama |
|---|---|
| v1–v2 | Fondasi: 7 agent, pipeline dasar, installer, self-test |
| v2.4 | +8 skill situasional, +3 command, e2e, USAGE |
| v2.5 | Auto-plan 8 blok wajib, perbaikan akar bug install (timeout) |
| v2.6 | +6 skill top-tier (learn, milestone, test-design, api-design, migrate, postmortem), +4 command |
| v3.0 | HUKUM 7 kemandirian, +8 skill (spec, research, red-team, team, autonomy, metrics, handoff, a11y), lint-kit 135 cek |
| v4.0 | HUKUM 8 konteks, script jalan (git-guard, metrics), /pr /context /upgrade |
| v5.0 | HUKUM 9 verifikasi, update flow diuji, env-guard, backup, scan, /verify |
| v6.0 | HUKUM 10 konsistensi, krisis (hotfix/recovery), mutation + bench, arsitektur tertulis, Makefile |
| v7.0 | HUKUM 11 rantai bukti + HUKUM 12 anti-injeksi, agent critic (adversarial VETO), +8 skill (53), +4 command (27), tests/eval.sh (6 kasus perilaku), mutation 10 sabotase, THREAT-MODEL, profile+budget+deliver |
| v8.0 | agent hermes (utusan all-rounder, 9 agent), skill clean (+run.sh: allowlist ketat) & estimate (S/M/L/XL dari angka nyata) → 55 skill/15 script, +3 command (/clean /estimate /hermes → 30), mutation 11 sabotase, clean masuk fase LAPOR sebelum deliver |
| v8.1 | HUKUM 13 router intensitas: FASE 0 route (NORMAL/FULL/ULTRA, sumber pemicu run.sh tunggal), pemicu = PANGGIL SEMUA (9 agent + hermes + caveman ULTRA), skill route (+run.sh) → 56 skill/16 script, +1 command (/route → 31), eval 8 kasus, mutation 12 sabotase |

---

## BERIKUTNYA (prioritas dampak × usaha)

### [ ] v8.1 — KERJA LINTAS BAHASA
- **Dampak**: kit dipakai di project non-bash (Python, JS, Go) — sekarang masih bash-centric.
- **Bukti selesai**: contoh integrasi minimal di 1 bahasa non-shell + lint-kit cek.

### [ ] v8.2 — RILIS OTOMATIS
- **Dampak**: `/release` jadi satu perintah: bump → changelog → test penuh → zip → upload.
- **Bukti selesai**: test-update memverifikasi rilis palsu dari versi apa pun.

### [ ] v8.3 — BENCH BERAMBAT
- **Dampak**: kit tidak boleh makin lambat antar versi; drift = alarm.
- **Bukti selesai**: bench.sh punya baseline tersimpan dan hard-cap bertingkat.

### [ ] v8.4 — PLUGIN SKILL
- **Dampak**: skill pihak ketiga masuk via manifest, tanpa edit inti.
- **Bukti selesai**: 1 skill contoh dimuat dari folder luar + diuji.

### [ ] v8.5 — MEMORI TERSTRUKTUR
- **Dampak**: recall tidak baca 5 file; index JSON + query.
- **Bukti selesai**: recall/run.sh (jika ada) membaca index; migration test.

---

## BACKLOG (belum diprioritaskan)

- Benchmark skenario 100 permintaan simulasi (kit harus stabil di sesi panjang).
- Mode kepala dingin: tanpa akses internet, semua gate tetap jalan (sebagian sudah lewat `--offline`).
- Multi-repo: satu instalasi kit mengelola beberapa project (config per-project).
- Test lintas-platform: macOS/Windows Git Bash/CI Linux — jalankan suite di 3 OS.
- Templat onboarding interaktif: `install.sh` bisa bertanya 3 pertanyaan → profil tim.

---

## ATURAN ROADMAP

1. Item masuk BACKLOG dulu, naik ke BERIKUTNYA hanya jika dampak × usaha jelas.
2. Setiap versi = minimal 1 bukti baru yang masuk ke suite test.
3. Roadmap ini sendiri diuji lint-kit (format tabel konsisten) — dokumen yang dijanjikan harus ada.
4. Tidak ada item tanpa "bukti selesai". Item tanpa bukti = bukan roadmap, itu angan-angan.