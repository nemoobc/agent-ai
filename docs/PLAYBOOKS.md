# PLAYBOOKS — DEV-BRAIN v6.0

Resep skenario nyata. Tiap resep = urutan skill/command + gerbang yang tidak boleh dilewati.
Kamu tetap TIDAK PERLU hafal ini — DEV pilih otomatis. Ini untuk paham cara dia berpikir.

---

## 1. FITUR BARU BESAR (dari nol sampai rilis)
`/ship <tugas>` menjalankan:
think → **spec** (input/output/aturan/error/non-goal) → imagine+architect → **plan 8 blok tampil** → **test-design** (kasus sebelum koding) → coder → test-full → audit-full → **red-team** (bila menyentuh auth/data/publik) → fixer → doc-full → learn → remember → lapor
GERBANG: tanpa spec & plan & kasus test → coder dilarang mulai. P0/P1 sisa → GAGAL.

## 2. REWRITE BESAR / PERBAIKAN TOTAL
plan 8 blok → **milestone** (M1..Mn berbukti) → per milestone: build→test→audit → papan update → handoff bila sesi habis
GERBANG: milestone merah → milestone berikutnya terkunci.

## 3. PR MASUK / REVIEW
**review** (konteks, conflict, diff) → test-full → audit-full → **red-team** (bila permukaan publik) → prediksi merge + saran commit
GERBANG: test merah / P0/P1 / konflik belum beres → merge dilarang.

## 4. PRODUKSI LAMBAT
**perf** (scan hot path → ukur → urutkan dampak×usaha → fix satu per satu) → re-test tiap langkah → metrics untuk bukti sebelum/after
GERBANG: tebakan tanpa ukur dilarang dijual sebagai hasil.

## 5. UBAH SKEMA / DATA PRODUKSI
**migrate** (snapshot WAJIB → contoh → skrip mundur → uji kecil → bertahap) → test + audit → lapor lokasi skrip mundur
GERBANG: tanpa snapshot → BERHENTI, minta keputusan user (HUKUM 5).

## 6. RILIS
**/release**: test-full → audit-full → changelog (sinkron VERSION+badge) → self-test → SIAP RILIS → tag hanya bila user eksplisit
GERBANG: satu saja merah → rilis tertunda. Tanpa perintah user → tidak menyentuh remote.

## 7. SESI HABIS / SERAH KERJA
**/handoff**: selesai(bukti) + sisa(terukur) + keputusan + pelajaran + command validasi + jebakan → remember + learn
GERBANG: pekerjaan setengah jalan → handoff ditolak sendiri.

## 8. AMBIGU / TAK PASTI MAU APA
**spec** (tulis asumsi eksplisit) → plan → **autonomy TITIK** bila keputusan butuh user: opsi A/B/C + angka + rekomendasi → user putus → lanjut penuh
GERBANG: berhenti tanpa opsi bernomor = menyerah, dilarang.

## 9. TOOL/SERVICE BARU (luar)
**research** (sumber + tanggal) → **cost** (angka dari sumber, konfirmasi user) → plan → kerja → doc
GERBANG: klaim tanpa sumber; biaya tanpa konfirmasi — dua-duanya dilarang.

## 10. UI BARU
plan + **test-design** → coder (komponen aksesibel dulu) → test → audit + **a11y** (keyboard/semantik/kontras) → fixer → doc-full
GERBANG: UI tanpa cek a11y → audit belum CLEAN.

## 11. COMMIT
**git-guard** (run.sh: blokir secret/marker/debug/diff raksasa) → bersih? commit boleh → setelahnya /pr
GERBANG: guard BLOKIR → commit dilarang, tidak ada "sekali aja".

## 12. KIRIM PR
**/pr**: baca diff → test+audit+guard hijau → judul konvensional + ringkasan + bukti + checklist → siap tempel
GERBANG: test merah / P0-P1 / guard merah → PR belum lahir. Push/merge hanya dengan perintah eksplisit user.

## 13. UPGRADE DEPENDENSI
**dependency** (inventory → research changelog → backup lockfile → bump → lockfile ulang → test) → audit kerentanan → lapor naik apa
GERBANG: tanpa inventory tertulis → dilarang; breaking change tidak dicatat → P1; rollback wajib mungkin (backup).

## 14. OPERASI BERISIKO DATA / ROLLBACK
**backup** (tarball bertanggal, terverifikasi) → migrate/refactor jalan → gagal? restore dari backup → lapor → ulang
GERBANG: tanpa backup sukses → operasi dilarang; backup korup = backup gagal.

## 15. PRODUKSI RUSAK (INSIDEN)
**/hotfix**: FREEZE fitur (tidak ada kerja lain) → diagnosis dari log/error → **patch terkecil** yang mengembalikan layanan → bukti (test + verifikasi manual) → rilis patch → **postmortem** setelah tenang
GERBANG: tanpa freeze → fix fitur dilarang; patch >1 fokus → ditolak; tanpa bukti pulih → belum selesai.

## 16. DATA RUSAK / KORUP
**recovery**: snapshot/backup terverifikasi → identifikasi rentang kerusakan → skrip mundur (rollback) → uji di salinan → restore bertahap → verifikasi integritas → lapor + postmortem
GERBANG: tanpa snapshot → BERHENTI minta keputusan user (HUKUM 5); restore langsung ke produksi tanpa uji salinan → dilarang.

## 17. SATU TOMBOL VERIFIKASI (HUKUM 9 + 10)
**make verify** (atau /verify): lint-kit → self-test → e2e → demo → test-update → mutation → bench → audit → doctor. Laporan SELESAI hanya setelah semua hijau
GERBANG: satu merah → fix dulu → ulang. Hitungan nyasar (badge/tabel) → lint/self-test menolak laporan.

