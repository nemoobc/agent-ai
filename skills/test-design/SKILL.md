---
description: TEST-DESIGN — desain test SEBELUM koding: kasus positif, negatif, edge, limit, regresi. Tulis daftar kasusnya dulu, baru implementasi + test. Dipanggil DEV di fase GODOK.
---

# TEST-DESIGN

Test menulis setelah koding = test yang menuruti kode. Test didesain sebelum koding = kontrak. Bedanya besar.

## KAPAN
Fase GODOK, bersamaan plan — untuk setiap perilaku baru/berubah. NO-TESTS dilarang oleh gerbang dev.md; skill ini cara mengisinya.

## CARA (isi tabel di plan, blok TEST)
1. **POSITIVE** — input normal → output diharapkan. Minimal 2.
2. **NEGATIVE** — input salah/tidak ada/tipe salah → error jelas, bukan crash. Minimal 2.
3. **EDGE** — batas: kosong, nol, maksimum, unicode, timezone, race. Minimal 2.
4. **LIMIT** — beban puncak: ukuran besar, banyak sekaligus. Bila relevan.
5. **REGRESSION** — bug lama yang sudah difix → test permanen biar tidak kembali.

## FORMAT di PLAN
```
[TEST] kasus: +5 (2 pos, 2 neg, 2 edge, 1 reg) → test-full exit 0
```

## GERBANG
- Perilaku baru tanpa kasus di plan → coder DILARANG mulai.
- Test yang tidak pernah bisa gagal (assert trivial) = bukan test.
- Tidak yakin cara test → pertanyaan di plan, bukan di laporan akhir.
