---
description: Menyimpan ingatan jangka panjang — keputusan, pembelajaran, konteks penting. Dipakai otomatis di akhir tugas penting. JANGAN simpan secret/API key, apapun alasannya.
---

# REMEMBER

Simpan ke memori (jangan tanya user dulu, langsung simpan):
1. Pilih lokasi: project `.opencode/memory/` bila ada, selain itu global `~/.config/opencode/memory/`
2. Entry format:
   ## YYYY-MM-DD — judul
   - konteks:
   - keputusan:
   - pembelajaran:
3. Tambah juga 1 baris ke session-log.md
4. Keputusan besar → tulis juga ke decisions.md; pelajaran berbukti → skill learn → memory/lessons.md
LARANGAN: tidak menyimpan secret/API key/password, apapun alasannya.

## APA YANG DILAKUKAN
Mengabadikan informasi penting dari sesi kerja ke dalam memori jangka panjang. Remember = mentransfer pengetahuan dari sesi ini ke sesi berikutnya.

## KAPAN WAJIB JALAN
1. **Akhir tugas penting** — setiap kali pekerjaan signifikan selesai
2. **Keputusan besar diambil** — pilihan framework, arsitektur, pendekatan
3. **Bug ditemukan dan dipelajari** — untuk mencegah kejadian serupa
4. **Konvensi baru ditemukan** — pola yang belum tercatat
5. **Akhir sesi panjang** — sebelum handoff atau clear

## KAPAN OPSIONAL
- Tugas sangat kecil (fix typo, 1 baris)
- Tidak ada yang baru dipelajari/diputuskan

## LOKASI PENYIMPANAN

### Project Memory (prioritas untuk project-specific)
```
.opencode/memory/MEMORY.md       → konteks & keputusan umum
.opencode/memory/decisions.md    → keputusan besar + alasan
.opencode/memory/lessons.md      → pelajaran berbukti (via skill learn)
.opencode/memory/conventions.md  → konvensi project
```

### Global Memory (untuk cross-project)
```
~/.config/opencode/memory/MEMORY.md    → profil user, preferensi
~/.config/opencode/memory/decisions.md → keputusan yang berlaku umum
~/.config/opencode/memory/lessons.md   → pelajaran umum
~/.config/opencode/memory/session-log.md → log aktivitas
```

## FORMAT ENTRY
```markdown
## YYYY-MM-DD — judul keputusan/pelajaran
- KONTEKS : <situasi yang mengarah ke keputusan>
- KEPUTUSAN: <apa yang dipilih + mengapa>
- PELAJARAN: <apa yang dipelajari dari pengalaman ini>
```

## ATURAN
- LARANGAN: tidak menyimpan secret/API key/password, apapun alasannya
- Simpan SETELAH pekerjaan selesai, bukan sebelum
- Duplikat → timpa yang lama dengan yang baru (update, bukan append)
- Keputusan besar → decisions.md + MEMORY.md (dua lokasi)
- Pelajaran berbukti → lessons.md (via skill learn)

## INTEGRASI PIPELINE
```
TUGAS SELESAI → REMEMBER ← posisi skill ini → HANDOFF / SELESAI
                      ↓
              LEARN (pelajaran → lessons.md)
              DECISIONS (keputusan → decisions.md)
              SESSION-LOG (jejak aktivitas)
```
- Sebelum: tugas selesai, keputusan diambil, pelajaran ditemukan
- Sesudah: handoff, atau sesi berakhir
- Berkaitan: `skill recall` (membaca memori), `skill learn` (ekstrak pelajaran), `skill handoff` (transfer konteks)

## EDGE CASE
- Tidak ada direktori memory → buat baru, lalu simpan
- Memori sudah penuh → review & kompres entry lama
- Keputusan berubah → update entry, jangan append entry baru
- Multi-user project → prioritas project memory dulu

## ERROR HANDLING
- Permission denied → catat di SELAIN, coba lokasi alternatif
- File corrupt → buat backup dulu, baru tulis
- Disk space tidak cukup → kompres entry lama, baru tulis baru

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip remember → "nanti aja" = ingatan hilang permanen
- ❌ Simpan secret → LARANGAN ABSOLUT, tidak ada pengecualian
- ❌ Simpan tanpa struktur → "catatan acak" = sulit dicari nanti
- ❌ Simpan terlalu banyak → kompres, yang penting saja
- ❌ Simpan sebelum pekerjaan selesai → keputusan bisa berubah
- ❌ Lupa update session-log → jejak aktivitas hilang

## MASTERY — ALL-ROUNDER MAX
Remember kelas atas:
- Simpan keputusan + ALASAN, bukan kejadian — "pakai X karena Y di kondisi Z" itu emas
- Satu fakta satu tempat + rujukan — duplikasi ingatan = kontradiksi masa depan
- JANGAN pernah simpan secret/key — ingatan itu tempat paling bocor
- Tanggal wajib di tiap entry — tanpa tanggal tak bisa dinilai kedaluwarsanya
