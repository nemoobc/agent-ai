---
description: HANDOFF — kemas konteks sesi supaya sesi/agent berikutnya lanjut tanpa mengulang dari nol: kondisi, sisa kerja, keputusan, perintah validasi. Tanpa handoff = ilusi konteks.
---

# HANDOFF

Sesi baru tidak tahu apa-apa. Handoff = paket yang membuatnya pintar dalam 1 menit.

## APA YANG DILAKUKAN
Mentransfer konteks sesi kerja ke sesi/agent berikutnya secara lengkap dan terstruktur. Handoff = packaging knowledge: semua yang perlu diketahui penerus, dalam satu dokumen.

## KAPAN WAJIB JALAN
1. **Akhir sesi panjang** — sebelum /clear
2. **Sebelum tugas diserahkan** — ke orang/agent lain
3. **User minta "lanjutkan besok"** — konteks harus tersimpan
4. **Ganti topik besar** — sesi berikutnya butuh konteks baru
5. **Context budget hampir habis** — compact + handoff

## KEMAS (tulis ke memori + lapor)

### 1. KONDISI
Apa yang SELESAI + bukti (test/audit/commit tertentu), apa JALAN setengah (jangan ada!), apa ANTRE.

### 2. SISA KERJA
Daftar terukur, tiap item ada definisi selesai (plan blok SELESAI).
```
SISA:
1. Auth module — definisi: test 5/5 PASS + audit CLEAN
2. UI login — definisi: form bisa diakses keyboard
```

### 3. KEPUTUSAN
Keputusan sesi ini + alasan (masuk decisions.md via remember).

### 4. PELAJARAN
Yang mengubah cara kerja (masuk lessons.md via learn).

### 5. VALIDASI
Command persis untuk cek semua masih hijau:
```bash
bash tests/self-test.sh  # hasil terakhir: PASS
bash tests/eval.sh       # hasil terakhir: PASS
```

### 6. JEBAKAN
1–3 hal yang akan menjebak penerus:
- File yang jangan disentuh
- Keputusan jangan dibalik
- Area yang belum selesai tapi terlihat selesai

## FORMAT
```
HANDOFF <tanggal>
SELESAI : <+ bukti>
SETENGAH: <harus KOSONG — bila ada, selesaikan atau batalkan dulu>
SISA    : <daftar + definisi selesai>
VALIDASI: <command + hasil terakhir>
JEBAKAN : <1–3>
```

## GERBANG
- SETENGAH terisi = handoff DITOLAK sendiri — selesaikan/batalkan dulu (HUKUM: tidak ada pekerjaan menggantung)
- Sisa kerja tanpa definisi selesai = bukan sisa kerja, itu harapan. Tulis terukur

## INTEGRASI PIPELINE
```
KERJA → HANDOFF ← posisi skill ini → SESI BARU (recall handoff)
          ↓
     REMEMBER (simpan keputusan)
     LEARN (simpan pelajaran)
     MEMORY (simpan konteks)
```
- Sebelum: kerja selesai, perlu transfer konteks
- Sesudah: sesi baru, recall handoff
- Berkaitan: `skill recall` (baca memori), `skill remember` (simpan), `skill context` (disiplin konteks)

## EDGE CASE
- Sesi sangat pendek (<10 menit) → handoff ringkas
- Tidak ada yang berubah → "tidak ada perubahan" adalah handoff
- Handoff ke agent yang berbeda bahasa → gunakan bahasa yang dimengerti penerus
- Terlalu banyak sisa → prioritaskan 3 terpenting

## ERROR HANDLING
- Memori tidak ada → tulis handoff di laporan langsung
- Handoff terlalu panjang → kompres, ambil yang paling penting
- Penerus tidak bisa membaca handoff → format lebih jelas, lebih pendek

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Skip handoff → penerus mulai dari nol
- ❌ Handoff tanpa bukti → "sudah selesai" tanpa verifikasi
- ❌ Sisa kerja tanpa definisi → tidak bisa diverifikasi selesai
- ❌ SETENGAH terisi → handoff ditolak sendiri
- ❌ Handoff terlalu detail → kompres, ambil intinya

## MASTERY — ALL-ROUNDER MAX
Handoff kelas atas:
- Format: status + keputusan terakhir + blocker + langkah berikutnya + file kunci — pembaca tak punya memorimu
- Tulis untuk otak BARU: asumsi ditulis, istilah dijelaskan sekali — handoff untuk diri sendiri = bukan handoff
- Perintah bisa dijalankan langsung (copy-paste ready) — instruksi setengah jadi = kerja dua kali
- Tanggal + versi di kepala dokumen — handoff basi lebih berbahaya daripada tidak ada
