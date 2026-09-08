---
description: DEPENDENCY — upgrade dependensi dengan aman: inventory dulu, baca changelog, deteksi breaking change, lockfile dikunci, test penuh. Bukan sekadar bump versi.
---

# DEPENDENCY

Bump versi tanpa baca changelog = undang regresi. Upgrade = proses, bukan command.

## URUTAN KERJA
1. **INVENTORY** — daftar dependensi + versi sekarang (dari manifest/lockfile). Tandai yang major di belakang.
2. **RISET** — skill `research`: changelog/release notes per paket (sumber URL + tanggal). Cari breaking change.
3. **RENCANA** — urutan upgrade: yang dependensinya sedikit dulu. Tiap paket = satu langkah terukur.
4. **BACKUP** — skill `backup`: snapshot lockfile + manifest (bukan cuma git, tapi tarball bernama).
5. **UPGRADE** — bump versi → lockfile dikunci ulang (npm/pnpm/uv/go mod tidy/cargo update — sesuai stack).
6. **TEST** — skill `test-full`. Merah → `git checkout` manifest+lockfile (rollback cepat), catat, ulang dengan versi yang aman.
7. **AUDIT** — skill `audit-full` + cek kerentanan dependensi setelah naik.
8. **LAPOR** — naik apa, dari-ke, alasan, test hijau, risiko tersisa.

## GERBANG
- Tanpa inventory tertulis → upgrade DILARANG mulai.
- Breaking change di changelog tanpa dicatat di plan → temuan P1.
- Lockfile tidak dikunci ulang → dianggap gagal (audit temuan).
- Rollback wajib mungkin: lockfile lama tersimpan (backup), bukan hanya di git stash.