# LESSONS — pelajaran terukur (skill learn)
Entry terbaru di atas. Format: POLA / BUKTI / AKSI. Tanpa bukti = tidak masuk.

## 2026-09-10 — 1 file 1 baris, cetak ganda dibaca sebagai nimpa (v8.2.0)
- POLA: cetak ganda ok+pbar dibaca user sebagai nimpa
- BUKTI: 96 pasang ok+pbar label sama di output --offline 232 baris
- AKSI: 1 file 1 baris — gabung jadi okbar/errbar (232→136 baris)

## 2026-09-10 — fail-fast tengah loop tinggalkan setengah-tulis (v8.2.0)
- POLA: fail-fast tengah loop tinggalkan setengah-tulis
- BUKTI: critic VETO
- AKSI: _FAIL kumpul-akhir-exit1 + pesan "ulangi install"

## 2026-09-10 — glob-nol tetap exit0 tanpa guard counter (v8.2.0)
- POLA: glob-nol tetap exit0
- BUKTI: simulasi agents-kosong
- AKSI: guard counter-nol → exit1

## 2026-09-10 — badge ganda bikin gate palsu + MAIN && menelan gagal (v8.2.0)
- POLA: footer badge ganda bikin gate palsu bila test head -1; MAIN && menelan gagal
- BUKTI: probe SKILLS-99 lolos sebelum fix, FAIL setelah fix; --project nonexistent exit0 sebelum fix, exit1 setelah
- AKSI: badge parsable tunggal + test sort -u; MAIN if ... || exit 1

## 2026-09-10 — animasi \r menimpa log, wajib append-only (v8.2.0)
- POLA: animasi \r menimpa log
- BUKTI: grep \r=0 + matrix TTY/CI/NO_ANIM exit0
- AKSI: append-only newline + auto-disable non-TTY (can_anim TTY/CI/NO_ANIM/dumb/NO_COLOR, --no-anim/NO_ANIM, trap)

## 2026-09-09 — upgrade besar = audit turn-sebelumnya dulu, sebelum tambah apa pun
- POLA: file baru ditulis turn sebelumnya ≠ selesai; tanpa audit, duplikat patch & sabotase test yang gak nempel lolos senyap
- BUKTI: v7.0.0 — AGENTS.md HUKUM 11/12 ter-duplikat penuh (lint GAK nangkep duplikat, cuma keberadaan); mutation sabotase `-eq 45` di count yang sudah 53 → "gate LOLOS = detektor palsu"; self-test panggil `bash "$path show"` satu-argumen → 127; eval cetak 7/6
- AKSI: sebelum build di atas kerja lama: jalankan lint+self-test dulu, bedah tiap merah ke akar (reproduksi exit code), baru tambah; sabotase mutation WAJIB dicek cocok dengan count aktif saat count berubah

## 2026-09-09 — angka laporan suite dihitung dari ok() nyata, bukan dari label
- POLA: menulis "6 kasus" di label/CHANGELOG padahal blok menghasilkan cek lain
- BUKTI: tests/eval.sh EVAL 1/6 menghasilkan 2 ok() → cetak "PASS (7/6)"
- AKSI: label jumlah kasus = jumlah p marker; kalau mau 2 cek jadi 1 kasus, rangkum jadi 1 ok()

## 2026-09-08 — suite yang saling memanggil = rekursi tak hingga
- POLA: suite A menjalankan suite B yang menjalankan suite A → loop sampai timeout
- BUKTI: v6.0.0 self-test memanggil mutation.sh; mutation.sh menjalankan self-test pada salinan repo → timeout 180s; fix: self-test cukup cek syntax+file
- AKSI: suite pembuktian (mutation/bench) jalan terpisah di make verify + CI; aturan: suite yang dijalankan suite lain tidak boleh memanggil balik

## 2026-09-08 — bash -n menangkap syntax error process substitution
- POLA: tutup brace group `}` dan tutup process substitution `)` salah urutan
- BUKTI: coverage/run.sh line 40 `) 2>/dev/null ... ; }` → syntax error; diperbaiki jadi `} ... )`; self-test syntax loop langsung menangkap
- AKSI: setiap run.sh baru wajib lolos `bash -n` di self-test — gerbang syntax = detektor murah

## 2026-09-08 — skenario yang pernah gagal wajib jadi test
- POLA: bug update (nama folder tarball) terulang dari v2.3.0 karena tidak ada test permanen
- BUKTI: tests/test-update.sh menangkap 2 bug saat pertama jalan — update gagal senyap (find -name agent-ai*) + exit 1 install biasa (ekspresi && terakhir)
- AKSI: HUKUM 9 — skenario pernah-gagal = test permanen; /verify satu tombol sebelum SELESAI

## 2026-09-08 — gerbang tertulis vs gerbang yang JALAN
- POLA: aturan markdown ("jangan commit secret") bisa dilanggar diam-diam; script dengan exit code tidak bisa
- BUKTI: git-guard/run.sh blokir secret nyata di self-test (exit 1) lalu CLEAN (exit 0) — repo nyata, bukan imajinasi
- AKSI: konsep keamanan inti punya run.sh + dibuktikan self-test; aturan tulisan untuk sisanya

## 2026-09-08 — patch di dalam heredoc bikin double-line
- POLA: str_replace menempel baris baru di dalam blok heredoc usage() installer
- BUKTI: `X\n}  PROJECT=...` double-line di install.sh:41 — ketahuan saat baca ulang hasil patch
- AKSI: selalu baca ulang area hasil patch di dalam heredoc sebelum lanjut

## 2026-09-08 — install menggantung bukan karena jaringan lambat
- POLA: script kit manggil network tanpa batas waktu + tidak exit setelah sub-install
- BUKTI: timeout 120s shell agent; update() write_brain 2x — file lama menimpa baru
- AKSI: semua curl kena connect-timeout/max-time + flag --offline + exit setelah inner-install (v2.5.0)

## 2026-09-08 — angka hitung dulu, baru tulis
- POLA: menulis jumlah skill di badge/self-test sebelum menghitung real
- BUKTI: self-test FAIL "SKILLS=13 ≠ 21" — 13+8 salah tulis 16
- AKSI: hitung `ls | wc -l` dulu, baru tulis angka; self-test jaga
