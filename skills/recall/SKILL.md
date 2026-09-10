---
description: Memuat ingatan jangka panjang DEV-BRAIN. Dipakai otomatis di awal setiap sesi. Baca file memori, jangan tebak. Saring yang relevan, rangkum 1 blok.
---

# RECALL

Baca memori (baca file, jangan tebak):
1. Project `.opencode/memory/MEMORY.md` bila ada
2. Global `~/.config/opencode/memory/MEMORY.md`, `decisions.md`, `lessons.md` (5 teratas), `session-log.md` (10 baris terakhir)

Saring yang relevan dengan tugas sekarang. Rangkum 1 blok pendek: "INGATAN RELEVAN: …"

## APA YANG DILAKUKAN
Membaca semua file memori DEV-BRAIN yang tersimpan dan menyaring informasi yang relevan dengan tugas atau sesi saat ini. Ingatan jangka panjang = prevents mengulang kesalahan yang sudah diketahui.

## KAPAN WAJIB JALAN
1. **Awal setiap sesi baru** — sebelum eksekusi pertama, tanpa diminta
2. **Setelah /clear** — muat ulang ingatan sebelum lanjut
3. **Setelah ganti topik besar** — konteks berubah → muat ulang yang relevan
4. **Sebelum keputusan penting** — cek ada keputusan serupa di decisions.md

## URUTAN MEMBACA

### 1. Project Memory (prioritas)
```
.opencode/memory/MEMORY.md     → konteks project, keputusan terakhir
.opencode/memory/conventions.md → konvensi project (bila ada)
.opencode/memory/decisions.md  → keputusan yang sudah diambil
```

### 2. Global Memory (fallback)
```
~/.config/opencode/memory/MEMORY.md   → profil user, preferensi
~/.config/opencode/memory/lessons.md  → 5 pelajaran teratas (paling relevan)
~/.config/opencode/memory/session-log.md → 10 baris terakhir (jejak aktivitas)
```

### 3. Filtering & Summarizing
- Baca semua file → identifikasi yang relevan dengan tugas sekarang
- Rangkum ke: `INGATAN RELEVAN: [daftar poin penting]`
- Maksimal 1 blok pendek — jangan tumpahkan semua isi memori

## OUTPUT FORMAT
```
INGATAN RELEVAN:
- Keputusan: [dari decisions.md yang relevan]
- Pelajaran: [dari lessons.md yang masih berlaku]
- Konteks: [dari MEMORY.md yang sesuai]
```

## ATURAN
- Kalau memori kosong → lanjut tanpa ingatan, jangan mengarang
- lessons.md dibaca dulu: pelajaran yang masih relevan mencegah ulang kesalahan lama
- Kalau memori kosong → lanjut tanpa ingatan, jangan mengarang (double-check)
- Jangan mengarang isi memori yang tidak ada di file — baca = baca, bukan berkhayal
- File memori corrupt/tidak ada → catat, lanjut, jangan berhenti

## INTEGRASI PIPELINE
```
SCAN → RECALL ← posisi skill ini → THINK → PLAN → ...
```
- Sebelum: awal sesi (boot sequence)
- Sesudah: think, plan, atau eksekusi langsung
- Berkaitan: `skill remember` (menyimpan), `skill learn` (ekstrak pelajaran), `skill handoff` (transfer konteks)

## EDGE CASE
- Memori punya entry yang sudah usang (>3 bulan) → tandai, jangan hapus
- Konflik keputusan lama vs baru → ambil yang paling baru, catat
- File memori di-read-only filesystem → catat di SELAIN, lanjut
- Multi-project memory → prioritas project-specific dulu, global sebagai tambahan

## ERROR HANDLING
- File tidak ditemukan → catat "memori kosong", lanjut tanpa error
- File corrupt (encoding salah) → skip file yang corrupt, baca yang lain
- Permission denied → catat di SELAIN, lanjut
- Terlalu banyak entry → baca yang paling baru/relevan dulu

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Mengarang isi memori yang tidak ada → baca file, bukan berkhayal
- ❌ Membaca semua memori tanpa filtering → tumpahkan 50 baris ke user = boros konteks
- ❌ Skip recall karena "sepertinya tidak relevan" → baca dulu, baru putuskan
- ❌ Menggunakan memori lama tanpa verifikasi masih berlaku → cek timestamp & konteks
- ❌ Lupa update memori setelah tugas besar → remember + learn wajib di akhir
