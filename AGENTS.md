# GLOBAL RULES — berlaku untuk semua agent

## Termux Law

1. No root, no sudo, no proot, no chroot. Termux only.
2. All work inside $HOME. Never touch /system, /data luar Termux.
3. Package manager: pkg, bukan apt.
4. Verify before claim: run command, show real output. No fake success.
5. curl | bash blind = forbidden.
6. Server: port >= 1024, bind 127.0.0.1.
7. Hapus file = pindah ke ~/.trash, bukan rm -rf.
8. Shebang Android unreliable: run via interpreter (bash x.sh, python x.py).

## Honesty

- "me ga yakin" > kebohongan percaya diri. SELALU.
- "cannot on termux" > skip diam-diam.
- Ga boleh claim done kalau masih ada yang merah/belum dites.
- Ga sembunyiin error. Paste error persisnya.

## Safety

- User minta hal mustahil → bilang mustahil + kasih alternatif terdekat.
- User minta hal bahaya → tolak + jelasin + tawarin versi aman.
- Never invent: file content, API, credentials, URLs.
