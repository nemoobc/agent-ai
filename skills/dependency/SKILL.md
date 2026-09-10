---
description: DEPENDENCY — upgrade dependensi dengan aman: inventory dulu, baca changelog, deteksi breaking change, lockfile dikunci, test penuh. Bukan sekadar bump versi.
---

# DEPENDENCY

Bump versi tanpa baca changelog = undang regresi. Upgrade = proses, bukan command.

## APA YANG DILAKUKAN
Mengelola upgrade dependensi project secara terukur dan aman: inventory, riset, backup, upgrade, test, audit. Dependency = fondasi: upgrade tanpa riset = mengganti fondasi tanpa arsitektur.

## KAPAN WAJIB JALAN
1. **Versi dependensi sudah tua** > 6 bulan tidak diupdate
2. **Security vulnerability** ditemukan → upgrade segera
3. **Fitur baru dibutuhkan** → dependensi versi lama tidak support
4. **User minta upgrade** → lakukan dengan prosedur lengkap

## URUTAN KERJA (8 LANGKAH)

### 1. INVENTORY
Daftar dependensi + versi sekarang (dari manifest/lockfile). Tandai yang major di belakang.
```
DEPENDENCY INVENTORY:
  express: ^4.18.0 → latest: 4.21.0 (MINOR)
  typescript: ^4.9.0 → latest: 5.3.0 (MAJOR)
  jest: ^29.0.0 → latest: 29.7.0 (PATCH)
```

### 2. RISET (skill research)
Changelog/release notes per paket (sumber URL + tanggal). Cari breaking change.

### 3. RENCANA
Urutan upgrade: yang dependensinya sedikit dulu. Tiap paket = satu langkah terukur.

### 4. BACKUP (skill backup)
Snapshot lockfile + manifest (bukan cuma git, tapi tarball bernama).

### 5. UPGRADE
Bump versi → lockfile dikunci ulang (npm/pnpm/uv/go mod tidy/cargo update — sesuai stack).

### 6. TEST (skill test-full)
Merah → `git checkout` manifest+lockfile (rollback cepat), catat, ulang dengan versi yang aman.

### 7. AUDIT (skill audit-full)
Cek kerentanan dependensi setelah naik.

### 8. LAPOR
Naik apa, dari-ke, alasan, test hijau, risiko tersisa.

## GERBANG
- Tanpa inventory tertulis → upgrade DILARANG mulai
- Breaking change di changelog tanpa dicatat di plan → temuan P1
- Lockfile tidak dikunci ulang → dianggap gagal (audit temuan)
- Rollback wajib mungkin: lockfile lama tersimpan (backup), bukan hanya di git stash

## INTEGRASI PIPELINE
```
INVENTORY → RESEARCH → BACKUP → UPGRADE → TEST-FULL → AUDIT-FULL → LAPOR
                                                           ↑
                                                    DEPENDENCY ← posisi skill ini
```
- Sebelum: inventory (identifikasi), research (riset), backup (snapshot)
- Sesudah: test-full (verifikasi), audit-full (keamanan)
- Berkaitan: `skill research` (riset changelog), `skill backup` (snapshot)

## EDGE CASE
- Major upgrade → extra hati-hati, baca migration guide
- Tidak ada changelog → riset dari release notes / git diff
- Dependensi saling bergantung → urutan upgrade hati-hati
- Security patch mendesak → upgrade segera, test ketat

## ERROR HANDLING
- Upgrade gagal → rollback ke versi lama dari backup
- Test merah setelah upgrade → rollback + catat versi bermasalah
- Breaking change tidak terduga → rollback + riset lebih dalam
- Lockfile corrupt → regenerate dari manifest

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Bump versi tanpa baca changelog → undang regresi
- ❌ Upgrade semua sekaligus → pecah per paket, test antara
- ❌ Skip test setelah upgrade → test = bukti aman
- ❌ Skip backup → rollback tidak mungkin
- ❌ Mengabaikan security patch → upgrade segera, jangan tunda
