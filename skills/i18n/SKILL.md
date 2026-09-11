---
description: I18N — semua teks user-visible pakai key terkumpul, tidak ada string hardcoded. Jalankan saat menambah fitur teks, atau saat scan menemukan teks hardcoded.
---

# I18N

Teks user-visible ≠ hardcoded. Semua lewat key.

## APA YANG DILAKUKAN
Mengekstrak semua string yang terlihat oleh user dari kode dan memindahkannya ke file terjemahan (locale files) dengan key terstruktur. I18N = internasionalisasi: kode siap multi-bahasa.

## KAPAN WAJIB JALAN
1. **Fitur baru dengan teks** — teks harus pakai key dari awal
2. **Scan menemukan teks hardcoded** — ekstrak ke locale
3. **User minta multi-bahasa** — tambah locale baru
4. **Perubahan teks UI** — update di locale, bukan di kode

## URUTAN KERJA

### 1. PETA (skill scan)
Framework, sistem i18n yang sudah ada (react-intl, vue-i18n, next-intl, gotext, rails-i18n...).
- Sudah ada sistem → ikuti konvensinya
- Tidak ada → bikin minimal: `src/i18n/` atau `locales/` dengan file per bahasa (JSON/arb/ts)

### 2. SARING
Grep pola string di JSX/template view:
- `>(["'])...` JSX text
- `placeholder=`, `title=`, `alt=`, `aria-label=`
- Toast/alert/pesan error user-visible
- **Bukan teks user-visible**: nama class, key log, test, comment, id teknis. Biarkan.

### 3. EKSTRAK
String → key bermakna (`auth.login.title`), pindah ke file locale (default + minimal 1 bahasa lain bila user minta multibahasa).

### 4. GANTI
Kode pakai fungsi `t('key')` / helper sesuai framework.

### 5. TEST
skill `test-full`. Merah = fix dulu.

### 6. AUDIT
skill `audit-full`. Plus cek manual: tidak ada string UI yang lolos, semua key ada di semua locale (tidak ada key hilang).

## FORMAT LAPORAN
```
I18N  : X string diekstrak → Y key, Z locale
FILE  : daftar file berubah
TEST  : PASS (N/N)
AUDIT : CLEAN
```

## GERBANG
- Key hilang di 1 locale = temuan P2. Key hilang di semua = P1
- Hardcoded string baru dari coder (agent lain) → review kembali, ekstrak dulu
- Test merah setelah ekstrak = GAGAL, fix dulu

## INTEGRASI PIPELINE
```
I18N ← posisi skill ini → CODER (pakai t() function)
                              ↓
                         TEST-FULL (verifikasi)
                         AUDIT-FULL (cek konsistensi locale)
```
- Sebelum: scan (identifikasi string), coder (tulis kode)
- Sesudah: test-full (verifikasi), audit-full (cek konsistensi)
- Berkaitan: `skill scan` (peta project), `skill a11y` (aksesibilitas teks)

## EDGE CASE
- Tidak ada sistem i18n → buat minimal dulu
- Pluralization rules kompleks → sesuai framework
- Context-dependent translation → pakai context key
- RTL (right-to-left) languages → perlu CSS adjustments

## ERROR HANDLING
- Key tidak ditemukan di locale → tambah key, jangan hardcode
- Translation hilang → tambah translation kosong, flag untuk translator
- Framework i18n tidak terdeteksi → setup dulu

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ Hardcoded string → semua harus pakai key
- ❌ Key tidak deskriptif → `text1` = buruk, `auth.login.title` = baik
- ❌ Locale tidak lengkap → semua key harus ada di semua locale
- ❌ Skip test setelah i18n → i18n bisa merusak tampilan
- ❌ Terjemahan mesin → kualitas rendah, gunakan translator

## MASTERY — ALL-ROUNDER MAX
i18n kelas atas:
- Ekstrak dulu, terjemah kemudian — string hardcode di komponen = utang i18n berbunga
- Jangan gabung kalimat di kode ("selamat " + waktu) — urutan kata beda per bahasa, pakai template penuh
- Waspadai panjang: Jerman +35%, Jepang vertikal, RTL (Arab/Ibrani) = layout mirror
- Format lokal: tanggal/mata uang/plural — plural Indonesia gampang, plural Polandia 7 bentuk
