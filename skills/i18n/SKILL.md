---
description: I18N — semua teks user-visible pakai key terkumpul, tidak ada string hardcoded. Jalankan saat menambah fitur teks, atau saat scan menemukan teks hardcoded.
---

# I18N

Teks user-visible ≠ hardcoded. Semua lewat key.

## URUTAN KERJA
1. **PETA** — skill `scan` → framework, sistem i18n yang sudah ada (react-intl, vue-i18n, next-intl, gotext, rails-i18n...).
   - Sudah ada sistem → ikuti konvensinya. Tidak ada → bikin minimal: `src/i18n/` atau `locales/` dengan file per bahasa (JSON/arb/ts).
2. **SARING** — grep pola string di JSX/template view: `>(["'])...` JSX text, `placeholder=`, `title=`, `alt=`, `aria-label=`, toast/alert/pesan error user-visible.
   - Bukan teks user-visible: nama class, key log, test, comment, id teknis. Biarkan.
3. **EKSTRAK** — string → key bermakna (`auth.login.title`), pindah ke file locale (default + minimal 1 bahasa lain bila user minta multibahasa).
4. **GANTI** — kode pakai fungsi `t('key')` / helper sesuai framework.
5. **TEST** — skill `test-full`. Merah = fix dulu.
6. **AUDIT** — skill `audit-full`. Plus cek manual: tidak ada string UI yang lolos, semua key ada di semua locale (tidak ada key hilang).
7. **LAPOR** — jumlah key, locale, file berubah, test hijau.

## FORMAT LAPORAN
```
I18N  : X string diekstrak → Y key, Z locale
FILE  : daftar file berubah
TEST  : PASS (N/N)
AUDIT : CLEAN
```

## GERBANG
- Key hilang di 1 locale = temuan P2. Key hilang di semua = P1.
- Hardcoded string baru dari coder (agent lain) → review kembali, ekstrak dulu.
- Test merah setelah ekstrak = GAGAL, fix dulu.
