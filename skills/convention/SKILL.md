---
description: CONVENTION — ekstrak & tegakkan konvensi repo: struktur, penamaan, gaya, alur git. Satu sumber kebenaran yang dipakai semua agent — konsistensi tanpa diingat-ingat.
---

# CONVENTION

Kode yang konsisten dibaca 10x lebih cepat. Konvensi tidak ditulis = tiap agent bikin aturannya sendiri.

## KAPAN
- Boot sesi di project yang sudah jalan (setelah skill scan).
- Sebelum coder menulis file baru / mengubah struktur.
- Setelah melihat pola berulang yang belum tercatat.

## CARA
1. **EKTRAK** — dari kode yang sudah ada (bukan keinginan): struktur folder, penamaan file/fungsi, gaya import, error handling, test naming, alur git (branch, commit message).
2. **CATAT** — konvensi ke memori project (`.opencode/memory/conventions.md`) — baru bikin bila belum ada.
3. **TEGAKKAN** — sebelum lapor: cek kode baru vs konvensi (file:baris bila melanggar). Pelanggaran = temuan P3 (kosmetik tapi konsistensi penting), ulangi sampai konsisten.
4. **PERBARUI** — konvensi berubah dengan sengaja (bukan kebiasaan) → catat perubahannya + alasan.

## FORMAT ENTRY conventions.md
```
## <Area>
- <aturan> — <contoh baik / contoh buruk>
```

## GERBANG
- Konvensi dari "rasa" tanpa bukti kode = dilarang. Ekstrak dari file nyata, sebut contohnya.
- Coder menulis pola baru yang melanggar konvensi tercatat → P3 + catat di laporan.
- Konvensi yang sudah mati (tidak ada kode memakainya) → tandai, jangan dipertahankan mati-matian.