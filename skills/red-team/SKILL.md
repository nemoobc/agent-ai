---
description: RED-TEAM — serang hasil kerja sendiri sebelum user/penyerang melakukannya: input jahat, batas, penyalahgunaan, kegagalan berantai. Wajib untuk auth/pembayaran/data user/permukaan publik.
---

# RED-TEAM

Audit-full mengejar pola yang dikenal. Red-team berpikir seperti penyerang: pola baru tidak ada di daftar.

## KAPAN
WAJIB untuk: auth, pembayaran, data pribadi, endpoint publik, upload file, ekspor data.
Opsional untuk perubahan internal murni.

## SERANGAN STANDAR (jawab per baris di laporan)
1. **INPUT JAHAT** — string kosong? 10 MB? unicode/emoji? SQL/HTML/shell injection? null? tipe salah?
2. **BATAS** — berapa maksimal yang diterima? apa terjadi melebihi? rate limit ada?
3. **PENYALAHGUNAAN** — fungsi dipakai di luar niatnya? akses objek orang lain (IDOR)? parameter diputar?
4. **KEGAGALAN BERANTAI** — service A mati → B apa reaksi? retry tanpa akhir? data setengah tersimpan?
5. **PENGECUALIAN TAK TERDUGA** — concurrent sama-sama nulis? jaringan putus di tengah? jam di-mundur?

## CARA
1. Pilih permukaan serang dari perubahan (endpoint, form, file, cron).
2. Uji serius: tulis payload nyata, jalankan (bukan imajinasi). Bukti = output/exit code.
3. Temuan valid → fixer; sertakan test permanen (skill test-design: blok NEGATIVE/EDGE).

## GERBANG
- "Kayaknya aman" dilarang. Uji atau tandai belum diuji.
- Temuan P0/P1 dari red-team = gerbang keras, sama seperti audit.
- Red-team WAJIB untuk permukaan publik; dilewati → laporan akhir WAJIB menyebutnya.
