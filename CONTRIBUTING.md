# KONTRIBUSI — agent-ai (DEV-BRAIN)

Aturan main singkat. Doctrine lengkap: AGENTS.md.

## SEBELUM MENGUSULKAN PERUBAHAN
1. Fork + branch: `feat/<nama>` atau `fix/<nama>`.
2. Cek `memory/lessons.md` + `decisions.md` — jangan usulkan yang sudah diputuskan dengan alasan tertulis.

## GAYA
- Skill/command = markdown padat, gerbang (dilarang/wajib) tegas, ada exit code bila bersifat bash.
- Bahasa Indonesia. Kalimat pendek gaya caveman. Tanpa kata lunak ("mungkin", "kayaknya").
- Satu skill = satu tujuan. Ragukan → pecah.

## WAJIB SEBELUM PR
```bash
make verify                 # semua gerbang satu tombol (lint, self-test, e2e, demo, update, mutation, bench)
bash skills/audit-full/run.sh .   # CLEAN
```

## ANGKA WAJIB SINKRON (HUKUM 10)
Tambah skill/command → update SEMUA: installer (`mkdir`), self-test (jumlah + cek file), badge README, tabel README, docs/USAGE.md, CHANGELOG, VERSION. Satu kelewat = self-test FAIL — itu tugasnya, bukan musuh.
Struktur baru = detektor baru: tambah skill/command/script → WAJIB ada cek di lint-kit + self-test. Tanpa detektor, perusakan berikutnya tidak akan pernah ketahuan (lihat tests/mutation.sh).

## PR
- Judul: `feat: ...` / `fix: ...` / `docs: ...`.
- Deskripsi: apa, kenapa, bukti test (tempel output self-test).
- Perubahan perilaku user-visible → entry CHANGELOG ikut.
