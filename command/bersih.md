---
description: "Cleanup aman: proses orphan, port, artifact. Delete = trash"
agent: autodev
---
Cleanup aman: (1) ps -ef, identifikasi proses milik sesi/project ini, kill cuma yang jelas milik kita, (2) cek server jalan di background, matiin, (3) artifact/cache project (build/, dist/, __pycache__): TANYA dulu sebelum bersihin, (4) semua buang = pindah ke ~/.trash, NEVER rm -rf, (5) ga sentuh file user lain, (6) lapor apa yang dibersihin.
