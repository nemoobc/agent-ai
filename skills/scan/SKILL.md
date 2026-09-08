---
description: SCAN — peta project saat BOOT sesi: bahasa, framework, struktur, entry point, test framework. Input wajib sebelum eksekusi pertama.
---
# SCAN

Jalan tiap awal sesi, sebelum eksekusi pertama. Baca file, jangan tebak:

1. **BAHASA & FRAMEWORK** — dari manifest: `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` / `composer.json` / `Makefile`
2. **ENTRY POINT** — main/index/app, script `start`/`dev` di manifest
3. **TEST FRAMEWORK** — jest/vitest/pytest/go test/… + cara menjalankannya
4. **STRUKTUR** — folder penting + fungsinya, maksimal 8 baris
5. **MEMORI PROJECT** — `.opencode/memory/` bila ada; baca 10 baris terakhir tiap file

Output: 1 blok peta project, maksimal 10 baris, gaya caveman. Tanpa blok ini, eksekusi pertama DILARANG.
