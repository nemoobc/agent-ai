---
description: auto-prompt — Generate prompt lengkap & matang dari input kasar/pendek
---

# SKILL: auto-prompt

## DESKRIPSI
Generate prompt lengkap & matang dari input kasar/pendek. Deteksi otomatis domain, bahasa target, aturan, output, dan kriteria sukses.

## KAPAN DIPAKAI
- User kasih prompt pendek/kasar
- Butuh prompt lengkap sebelum eksekusi
- Input kurang spesifik

## BAGAIMANA
1. Analisis input user
2. Deteksi domain (autentikasi/API/UI/bug/dll)
3. Deteksi bahasa target
4. Generate prompt dengan aturan, output, success criteria

## CONTOH INPUT
```
bikin fitur login
tambah button di dashboard
fix bug di API
test unit untuk service user
```

## CONTOH OUTPUT
```
## KONTEKS
- Domain: autentikasi
- Bahasa: JavaScript/TypeScript

## TUJUAN
Buat/ubah/implementasikan: bikin fitur login

## ATURAN
1. Ikuti konvensi project yang sudah ada
2. Semua perubahan wajib punya test
3. Diff kecil & fokus
4. Error handling wajib ada
5. Dokumentasi update jika perlu

## SUCCESS CRITERIA
- [ ] Fitur berfungsi
- [ ] Test pass
- [ ] Tidak ada regression
```

## TERKAIT
- `/plan` — generate rencana 8 blok
- `/build` — eksekusi prompt
- `/route` — klasifikasi intensitas
