---
description: "Import session opencode dari file JSON atau URL (pasangan dari export)"
agent: autodev
---
User menjalankan /import $ARGUMENTS. Tugas: import session data pakai opencode CLI resmi (`opencode import`), JANGAN tulis manual ke database.

Langkah wajib:
1. Ambil target dari $ARGUMENTS: path file JSON lokal ATAU share URL. Kosong / ga jelas? Tanya 1x (max 1 pertanyaan), jangan nebak.
2. Path relatif → resolve ke absolut dulu (`realpath`). URL (http...) → pakai langsung.
3. Verify dulu SEBELUM import: file ada? JSON valid? (`python3 -m json.tool FILE >/dev/null`). Invalid → lapor + STOP.
4. Backup safety: `cp ~/.local/share/opencode/opencode.db /tmp/opencode.db.bak.$(date +%s)` dulu. Tanpa backup = jangan jalan.
5. Jalankan: `opencode import <file-atau-url>` (tanpa sudo, tanpa root, tanpa pipe buta).
6. Verify SESUDAH: hitung session sebelum vs sesudah naik (`python3 -c sqlite3 count dari tabel session`). Ga naik / error → restore backup (`cp balik`) + lapor error ASLI + hipotesis (label jelas).
7. Lapor caveman: file apa, berapa session/message masuk, command + output asli yang di-run.

Batasan: jangan import file yang belum diverifikasi. Secret/key di dalam file? Jangan print ke laporan.
