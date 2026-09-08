---
description: A11Y — aksesibilitas: UI bisa dipakai keyboard, screen reader, kontras cukup. Wajib untuk UI baru/perubahan UI — bukan bonus, bagian dari definisi selesai.
---

# A11Y

UI yang tidak bisa dipakai semua orang = UI yang rusak. Bukannya bonus, bagian dari SELESAI.

## CEK DASAR (di plan blok TEST + di coder + di audit manual)
1. **KEYBOARD** — semua aksi bisa via Tab/Enter/Escape; tidak ada trap fokus; urutan tab masuk akal.
2. **SEMANTIK** — button ≠ div klik; heading berurutan; form pakai label; landmark (nav/main/footer) ada.
3. **SCREEN READER** — gambar penting ada alt; ikon aksi punya aria-label; status dinamis pakai aria-live; fokus diumumkan saat pindah view.
4. **KONTRAS** — teks vs latar minimal 4.5:1 (AA); keadaan fokus kelihatan jelas, bukan cuma kursor.
5. **GERAK & WARNA** — info tidak bertumpu warna saja; animasi hormati prefers-reduced-motion; tidak ada flash > 3x/detik.

## CARA
1. Saat plan: UI baru → tulis cek a11y mana yang berlaku (blok TEST).
2. Saat coder: pakai komponen aksesibel yang sudah ada (library UI) sebelum bikin sendiri.
3. Saat audit: audit-full + cek manual item di atas. Temuan → fixer.
4. Test: bila framework punya a11y test (axe-core dll) → jalan; tidak ada → cek manual di laporan.

## GERBANG
- Perubahan UI tanpa cek a11y = audit belum CLEAN.
- Kontras gagal = temuan P2. Keyboard tak terpakai di alur inti = P1.
- "nanti dihias a11y-nya" dilarang — selesai berarti semua orang bisa pakai.
