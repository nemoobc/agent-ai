# THREAT-MODEL — DEV-BRAIN KIT ITSELF

Model ancaman terhadap kit ini sendiri (dogfood skill threat-model). Reviu tiap versi mayor.

```
ASET     : doctrine (AGENTS.md), installer (curl|bash jalur publik), memori user, opencode.json permission, CI secrets
AKTOR    : penyerang konten (injeksi prompt via web/file/issue), penyerang supply-chain (repo/update URL), contributor nakal, bot installer
JALUR    : 1) konten luar → sesi agent (HUKUM 12, injection-guard)
           2) install.sh --update unduh tarball remote (anti-downgrade, DEV_BRAIN_UPDATE_URL override, re-install dari SRC)
           3) curl|bash install dari master (trust repo origin)
           4) PR masuk (CI gate + mutation + review critic)
           5) secret bocor ke repo (git-guard, env-guard, audit-full, pre-commit hook)
DAMPAK   : P0 doctrine diganti → semua sesi terinfeksi; P0 secret ter-commit; P1 update flow menjalankan kode asing; P2 lint/matikan gate senyap
MITIGASI : HUKUM 12 + injection-guard/run.sh (detektor sinyal);
           update flow: tarball dari repo resmi saja (prefix resmi, non-resmi ditolak),
           https wajib DEV_BRAIN_UPDATE_SHA (SHA mismatch = ditolak), file:// hanya test lokal,
           curl --proto '=https' --tlsv1.2, anti-downgrade sort -V, memori dipertahankan, test-update 2 arah;
           curl|bash diganti unduh-inspeksi-jalankan di README; install default granular (allow-all opt-in);
           deliver upload wajib --yes; uninstall wajib konfirmasi;
           CI wajib lint+test+eval+e2e+update+mutation+bench+audit sebelum merge; release.yml jalankan self-test lagi sebelum rilis;
           pre-commit hook git-guard; secret scan 16+ pola; permission opencode.json granular (skill allowlist, sisanya ask)
SISA     : master branch = trust anchor (push proteksi repo milik owner, di luar kendali kit);
           injection-guard = detektor sinyal bukan AI — di approved (owner) 2026-09-08
```

## ATURAN PERUBAHAN
- Jalur baru ke arah aset P0/P1 tanpa mitigasi = temuan audit P0, rilis diblokir.
- Perubahan update flow = wajib test-update 2 arah hijau sebelum merge (HUKUM 9).
