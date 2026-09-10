---
description: A11Y — aksesibilitas: UI bisa dipakai keyboard, screen reader, kontras cukup. Wajib untuk UI baru/perubahan UI — bukan bonus, bagian dari definisi selesai.
---

# A11Y

UI yang tidak bisa dipakai semua orang = UI yang rusak. Bukannya bonus, bagian dari SELESAI.

## APA YANG DILAKUKAN
Memastikan semua antarmuka pengguna dapat diakses oleh semua pengguna, termasuk pengguna keyboard-only, screen reader, dan pengguna dengan kebutuhan aksesibilitas lainnya. A11Y = aksesibilitas (11 huruf di antara 'a' dan 'y').

## KAPAN WAJIB JALAN
1. **UI baru dibuat** — setiap komponen baru harus aksesibel dari awal
2. **Perubahan UI signifikan** — modifikasi yang mempengaruhi interaksi user
3. **Form baru** — input, validasi, error state harus accessible
4. **Kompleks interaktif** — modal, dropdown, tabs, accordion
5. **Audit UI** — pemeriksaan berkala terhadap UI yang sudah ada

## CEK DASAR (di plan blok TEST + di coder + di audit manual)

### 1. KEYBOARD (P1 bila gagal)
- Semua aksi bisa via Tab/Enter/Escape/Space
- Tidak ada trap fokus (fokus bisa keluar dari komponen)
- Urutan tab masuk akal (mengikuti alur visual)
- Focus visible: outline yang jelas, bukan cuma kursor
- Skip link ada bila navigation kompleks

### 2. SEMANTIK (P2 bila gagal)
- `<button>` ≠ `<div onClick>` — elemen yang benar untuk aksi
- Heading berurutan (h1 → h2 → h3, tidak loncat)
- Form pakai `<label>` atau `aria-label`
- Landmark ada: `<nav>`, `<main>`, `<footer>`, `<header>`
- List pakai `<ul>`/`<ol>`, bukan div berjejer

### 3. SCREEN READER (P2 bila gagal)
- Gambar penting ada `alt` deskriptif
- Ikon aksi punya `aria-label`
- Status dinamis pakai `aria-live="polite"`
- Fokus diumumkan saat pindah view (SPA)
- Loading state punya label
- Error message terhubung ke input via `aria-describedby`

### 4. KONTRAS (P2 bila gagal)
- Teks vs latar minimal 4.5:1 (WCAG AA)
- Large text (18pt+) minimal 3:1
- Keadaan fokus kelihatan jelas (bukan cuma kursor)
- Status/error/warning punya kontras memadai

### 5. GERAK & WARNA (P3 bila gagal)
- Info tidak bertumpu warna saja (tambah ikon/teks)
- Animasi hormati `prefers-reduced-motion`
- Tidak ada flash > 3x/detik
- Carousel auto-pause saat hover/fokus

## CARA KERJA
1. **Saat plan**: UI baru → tulis cek a11y mana yang berlaku (blok TEST)
2. **Saat coder**: pakai komponen aksesibel yang sudah ada (library UI) sebelum bikin sendiri
3. **Saat audit**: audit-full + cek manual item di atas. Temuan → fixer
4. **Test**: bila framework punya a11y test (axe-core, jest-axe, pa11y) → jalan; tidak ada → cek manual di laporan

## OUTPUT FORMAT
```
A11Y: PASS / X temuan
  - [P1] keyboard trap di komponen X
  - [P2] heading skipping di halaman Y
  - [P3] alt text kurang deskriptif di gambar Z
```

## INTEGRASI PIPELINE
```
PLAN (cek a11y) → CODER (implementasi aksesibel) → A11Y ← posisi skill ini
                                                         ↓
                                                    AUDIT-FULL
                                                    FIX-FULL (temuan)
```
- Sebelum: plan (identifikasi kebutuhan), coder (implementasi)
- Sesudah: audit-full (gabungan), fix-full (temuan)
- Berkaitan: `skill audit-full` (gabungan), `skill red-team` (serangan UX)

## EDGE CASE
- Framework UI (Material UI, Chakra) → komponen default sudah accessible, verifikasi
- Custom component → pastikan rolo attributes, keyboard handling, focus management
- SPA (single page app) → announcement saat route berubah
- Third-party widget → bila tidak accessible, beri workaround + catat

## ERROR HANDLING
- Tidak ada axe-core → cek manual sesuai checklist
- Temuan tidak bisa difix sekarang → catat sebagai known issue + remediation plan
- Komponen pihak ketiga tidak accessible → workaround atau ganti

## KESALAHAN UMUM YANG HARUS DIHINDARI
- ❌ "Nanti dihias a11y-nya" → selesai berarti semua orang bisa pakai
- ❌ Skip a11y untuk "prototype" → prototype yang accessible = 10x lebih mudah diakses nanti
- ❌ Menganggap a11y = screen reader saja → keyboard, kontras, motion semua penting
- ❌ Hanya cek di akhir → a11y harus dibangun dari awal, bukan ditambahkan
- ❌ Mengandalkan tool saja → tool menangkap ~30%, cek manual tetap wajib
