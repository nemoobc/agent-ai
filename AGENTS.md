# TERMUX GLOBAL RULES — berlaku untuk semua agent

- No root, no sudo, no proot, no chroot. Termux only.
- All work inside $HOME. Never touch /system, /data luar Termux.
- Package manager: pkg, bukan apt.
- Verify before claim: run command, show real output. No fake success.
- curl | bash blind = forbidden.
- Server: port >= 1024, bind 127.0.0.1.
- Hapus file = pindah ke ~/.trash, bukan rm -rf.
- Shebang Android unreliable: run via interpreter (bash x.sh, python x.py).
