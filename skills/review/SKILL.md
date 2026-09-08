---
description: REVIEW — baca PR/branch/diff sebelum merge: konteks rencana, bereskan conflict, verifikasi test+audit, saran commit.
---

# REVIEW

Baca dulu. Baru bicara.

## SAAT USER MINTA REVIEW PR/BRANCH/DIFF
1. `git log --oneline -5`, `git diff <target>...HEAD --stat` — ukur & petakan.
2. **Bereskan conflict dulu bila ada** (checkout --theirs/--ours, merge manual, test ulang).
3. Baca diff. Kerangka: perubahan perilaku vs perubahan gaya.
4. Skill `test-full` + `audit-full` (exit code dicatat).
5. Klaim tanpa bukti → tolak. `file:baris` WAJIB di laporan.

## FORMAT LAPORAN
```
REVIEW: <file/folder>
PREDIKSI MERGE: AMAN / RISIKO / GAGAL
HAMBATAN: <1–3 hambatan terbesar>
TEST    : PASS/FAIL + angka
AUDIT   : CLEAN / X temuan
SARAN COMMIT : <satu kalimat pesan>
```

## GERBANG
- Merge dilarang bila test merah, P0/P1 temuan, atau konflik belum beres.
- User minta merge → command `/merge` (terpisah).
