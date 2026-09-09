#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════
#   ██████╗ ███████╗██████╗
#   ██╔══██╗██╔════╝██╔══██╗     D E V — B R A I N
#   ██║  ██║███████╗██████╔╝     agent-ai full-agent installer
#   ██║  ██║╚════██║██╔═══╝      caveman mode • permanen • ultronomatis
#   ██████╔╝███████║██║          auto: think→build→test→audit→fix
#   ╚═════╝ ╚══════╝╚═╝
# ─────────────────────────────────────────────────────────────────
# Pakai  : bash install.sh [--project DIR] [--uninstall]
# ═════════════════════════════════════════════════════════════════
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── warna ──
if [ -t 1 ]; then pc(){ printf '\033[38;5;%sm%s\033[0m\n' "$1" "$2"; }
else pc(){ printf '%s\n' "$2"; }; fi
ok(){ pc 82  "  ✔ $1"; }
inf(){ pc 45  "  ▸ $1"; }
wrn(){ pc 214 "  ⚠ $1"; }
err(){ pc 196 "  ✖ $1"; }
step(){ printf '\n'; pc 213 "══════ $1 ══════"; }

CFG="$HOME/.config/opencode"
IS_TERMUX=0
[ -n "${TERMUX_VERSION:-}" ] && IS_TERMUX=1
[ -d /data/data/com.termux ] && IS_TERMUX=1

usage(){ cat <<'X'
Pemakaian:
  bash install.sh                 install global (~/.config/opencode)
  bash install.sh --project DIR   sekalian pasang ke project (DIR/.opencode)
  bash install.sh --check         cek kesehatan instalasi (tanpa menulis)
  bash install.sh --update        update ke versi terbaru dari GitHub (memori aman)
  bash install.sh --version       tampilkan versi
  bash install.sh --uninstall     buang agent & doctrine (memori DIPERTAHANKAN)
  bash install.sh --offline       tanpa cek jaringan (offline/CI aman, tanpa menunggu)
  bash install.sh --hook          pasang pre-commit hook git-guard ke project ini (.git/hooks)
  bash install.sh --lint          jalankan lint-kit + self-test setelah install (verifikasi)
  env DEV_BRAIN_UPDATE_URL=...    override URL update (untuk tes/file://)

Di dalam opencode (tanpa install global di project ini):
  /bootstrap                      pasang DEV-BRAIN ke project ini (.opencode/)
X
}
PROJECT=""; UNINSTALL=0; CHECK=0; UPDATE=0; SHOWVER=0; OFFLINE=0; HOOK=0; LINT=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) [ $# -ge 2 ] || { err "--project butuh path folder"; exit 1; }; PROJECT="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    --check) CHECK=1; shift ;;
    --update) UPDATE=1; shift ;;
    --version) SHOWVER=1; shift ;;
    --offline) OFFLINE=1; shift ;;
    --hook) HOOK=1; shift ;;
    --lint) LINT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) wrn "arg tak dikenal: $1 (diabaikan)"; shift ;;
  esac
done

banner(){
  pc 213 '   ██████╗ ███████╗██████╗ '
  pc 177 '   ██╔══██╗██╔════╝██╔══██╗'
  pc 141 '   ██║  ██║███████╗██████╔╝'
  pc 105 '   ██║  ██║╚════██║██╔═══╝ '
  pc 69  '   ██████╔╝███████║██║     '
  pc 33  '   ╚═════╝ ╚══════╝╚═╝     B R A I N'
  echo
  pc 45 "   otak utama: DEV • caveman mode ULTRA • ultronomatis"
  [ -f "$SCRIPT_DIR/VERSION" ] && pc 45 "   versi: $(cat "$SCRIPT_DIR/VERSION" | tr -d '[:space:]')"
  pc 45 "   auto test/audit/fix ✓ • memori persisten ✓"
  echo
}

# ── update dari GitHub ──
REPO="nemoobc/agent-ai"
# URL override: untuk tes lokal (file://) — set DEV_BRAIN_UPDATE_URL
UPDATE_URL="${DEV_BRAIN_UPDATE_URL:-https://codeload.github.com/$REPO/tar.gz/refs/heads/master}"
update(){
  step "UPDATE DEV-BRAIN"
  command -v curl >/dev/null 2>&1 || { err "curl tidak ada — update manual: git clone $REPO"; exit 1; }
  TMP=$(mktemp -d)
  inf "unduh master terbaru…"
  # timeout wajib: connect 5s, total 60s — offline/nyangkut tetap selesai, tidak menggantung shell agent
  curl -fsSL --connect-timeout 5 --max-time 60 "$UPDATE_URL" -o "$TMP/kit.tgz" \
    || { err "unduh gagal — cek koneksi"; rm -rf "$TMP"; exit 1; }
  tar -xzf "$TMP/kit.tgz" -C "$TMP" || { err "ekstrak gagal"; rm -rf "$TMP"; exit 1; }
  SRC=$(find "$TMP" -maxdepth 1 -type d -name 'agent-ai*' | head -1)
  [ -f "$SRC/install.sh" ] || { err "paket tidak valid"; rm -rf "$TMP"; exit 1; }
  NEWV=$(tr -d '[:space:]' < "$SRC/VERSION" 2>/dev/null)
  OLDV=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  inf "terpasang: ${OLDV:-?} → tersedia: ${NEWV:-?}"
  # anti-downgrade: hanya update bila remote LEBIH BARU (semver compare)
  OLDER=$(printf '%s\n%s\n' "${OLDV:-0}" "${NEWV:-0}" | sort -V | head -1)
  if [ -n "$OLDV" ] && [ "$OLDER" != "$OLDV" ]; then
    ok "remote ($NEWV) tidak lebih baru dari terpasang ($OLDV) — skip"
    rm -rf "$TMP"; exit 0
  fi
  if [ "$NEWV" = "$OLDV" ]; then ok "sudah versi terbaru"; rm -rf "$TMP"; exit 0; fi
  if bash "$SRC/install.sh" --offline; then ok "update ke $NEWV selesai — memori tetap aman"; else err "update gagal di tengah — instalasi lama utuh"; fi
  rm -rf "$TMP"
  # penting: jangan lanjut write_brain ulang — inner install sudah menulis semuanya
  exit 0
}

# ── cek versi remote (non-blokir, offline aman) ──
check_remote_version(){
  [ "$OFFLINE" -eq 1 ] && return 0
  command -v curl >/dev/null 2>&1 || return 0
  REMOTE=$(curl -fsSL --connect-timeout 2 --max-time 3 "https://raw.githubusercontent.com/$REPO/master/VERSION" 2>/dev/null | tr -d '[:space:]')
  [ -n "$REMOTE" ] || return 0
  LOCALV=$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null)
  if [ -n "$LOCALV" ] && [ "$REMOTE" != "$LOCALV" ]; then
    wrn "versi baru tersedia: $REMOTE (lokal $LOCALV) — update: bash install.sh --update"
  fi
}

# ── uninstall ──
uninstall(){
  step "UNINSTALL DEV-BRAIN"
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command" "$CFG/docs"
  rm -f "$CFG/AGENTS.md"
  BAK=$(ls -1t "$CFG"/opencode.json.bak.* 2>/dev/null | head -n1)
  if [ -n "${BAK:-}" ]; then mv "$BAK" "$CFG/opencode.json"; ok "opencode.json dipulihkan dari backup"
  elif [ -f "$CFG/opencode.json" ] && grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    rm -f "$CFG/opencode.json"; ok "opencode.json buatan DEV-BRAIN dihapus"
  fi
  wrn "folder memory/ DIPERTAHANKAN (isi ingatan kamu)"
  ok "uninstall selesai — DEV-BRAIN dilepas"
  exit 0
}

# ── tulis file dari script dir ke CFG ──
write_brain(){
  step "TULIS OTAK → ~/.config/opencode"
  # prune instalasi lama biar tidak ada file sisa dari versi sebelumnya
  rm -rf "$CFG/agent" "$CFG/skill" "$CFG/command"
  mkdir -p "$CFG/agent" "$CFG/command" "$CFG/memory" \
    "$CFG/skill/think" "$CFG/skill/imagine" "$CFG/skill/remember" "$CFG/skill/recall" \
    "$CFG/skill/caveman" "$CFG/skill/caveman-warmup" "$CFG/skill/scan" "$CFG/skill/plan" \
    "$CFG/skill/debug" "$CFG/skill/doc-full" \
    "$CFG/skill/doctor" "$CFG/skill/review" "$CFG/skill/refactor" "$CFG/skill/cost" \
    "$CFG/skill/perf" "$CFG/skill/explain" "$CFG/skill/i18n" "$CFG/skill/changelog" \
    "$CFG/skill/learn" "$CFG/skill/milestone" "$CFG/skill/test-design" "$CFG/skill/api-design" \
    "$CFG/skill/migrate" "$CFG/skill/postmortem" "$CFG/skill/spec" "$CFG/skill/research" \
    "$CFG/skill/red-team" "$CFG/skill/team" "$CFG/skill/autonomy" "$CFG/skill/metrics" \
    "$CFG/skill/handoff" "$CFG/skill/a11y"    "$CFG/skill/context" "$CFG/skill/pr" \
    "$CFG/skill/git-guard" "$CFG/skill/env-guard" "$CFG/skill/backup" "$CFG/skill/dependency" \
    "$CFG/skill/hotfix" "$CFG/skill/recovery" "$CFG/skill/convention" "$CFG/skill/coverage" \
    "$CFG/skill/critique" "$CFG/skill/injection-guard" "$CFG/skill/trace" "$CFG/skill/profile" \
    "$CFG/skill/budget" "$CFG/skill/threat-model" "$CFG/skill/deliver" "$CFG/skill/eval" \
    "$CFG/skill/clean" "$CFG/skill/estimate" "$CFG/skill/route" \
    "$CFG/skill/test-full" "$CFG/skill/audit-full" "$CFG/skill/fix-full"

  # backup config lama HANYA bila itu bukan tulisan DEV-BRAIN (marker)
  if [ -f "$CFG/opencode.json" ] && ! grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null; then
    cp "$CFG/opencode.json" "$CFG/opencode.json.bak.$(date +%s)"
  fi

  # opencode.json: izin granular — 3 level: allow (aman), ask (konfirmasi), deny (block)
  cat > "$CFG/opencode.json" <<'OPencodeEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "devbrain": true,
  "permission": {
    "edit": "allow",
    "write": "allow",
    "webfetch": "allow",
    "bash": {
      "ls*": "allow", "ll*": "allow", "la*": "allow", "tree*": "allow",
      "file*": "allow", "stat*": "allow", "readlink*": "allow", "basename*": "allow", "dirname*": "allow",
      "cat*": "allow", "head*": "allow", "tail*": "allow", "less*": "allow", "more*": "allow",
      "nl*": "allow", "od*": "allow", "xxd*": "allow", "hexdump*": "allow", "strings*": "allow",
      "find*": "allow", "locate*": "allow",
      "grep*": "allow", "rg*": "allow", "egrep*": "allow", "fgrep*": "allow", "ag*": "allow", "ack*": "allow",
      "which*": "allow", "whereis*": "allow", "type*": "allow", "command*": "allow", "hash*": "allow",
      "wc*": "allow", "sort*": "allow", "uniq*": "allow", "diff*": "allow", "comm*": "allow", "cmp*": "allow",
      "col*": "allow", "column*": "allow", "fmt*": "allow", "fold*": "allow", "pr*": "allow",
      "expand*": "allow", "unexpand*": "allow",
      "whoami*": "allow", "id*": "allow", "hostname*": "allow", "uname*": "allow", "uptime*": "allow",
      "date*": "allow", "cal*": "allow", "df*": "allow", "du*": "allow", "free*": "allow", "vmstat*": "allow",
      "lscpu*": "allow", "lsblk*": "allow", "lsusb*": "allow", "lspci*": "allow", "lsmod*": "allow",
      "locale*": "allow", "env*": "allow", "printenv*": "allow", "set*": "allow",
      "echo*": "allow", "printf*": "allow", "pwd*": "allow", "test*": "allow", "true*": "allow", "false*": "allow",
      "git status*": "allow", "git log*": "allow", "git diff*": "allow", "git branch*": "allow",
      "git remote*": "allow", "git tag*": "allow", "git show*": "allow", "git blame*": "allow",
      "git reflog*": "allow", "git describe*": "allow", "git rev-parse*": "allow", "git rev-list*": "allow",
      "git shortlog*": "allow", "git count-objects*": "allow", "git fsck*": "allow",
      "git add*": "allow", "git commit*": "allow", "git push*": "allow", "git pull*": "allow",
      "git clone*": "allow", "git checkout*": "allow", "git switch*": "allow", "git stash*": "allow",
      "git merge*": "allow", "git fetch*": "allow", "git revert*": "allow", "git cherry-pick*": "allow",
      "git reset*": "allow", "git rebase*": "allow", "git branch -m*": "allow", "git branch -d*": "allow",
      "git remote add*": "allow", "git remote set-url*": "allow", "git remote rename*": "allow",
      "git remote remove*": "allow", "git config*": "allow", "git archive*": "allow",
      "git clean*": "allow", "git restore*": "allow",
      "mkdir*": "allow", "cp*": "allow", "mv*": "allow", "touch*": "allow", "ln*": "allow",
      "chmod*": "allow", "chown*": "allow", "rm*": "allow", "rmdir*": "allow", "install*": "allow",
      "sed*": "allow", "awk*": "allow", "tr*": "allow", "cut*": "allow", "paste*": "allow",
      "join*": "allow", "tee*": "allow", "xargs*": "allow", "jq*": "allow", "yq*": "allow",
      "cd*": "allow", "source*": "allow", ".*": "allow", "eval*": "allow",
      "export*": "allow", "unset*": "allow", "alias*": "allow", "unalias*": "allow",
      "history*": "allow", "jobs*": "allow", "bg*": "allow", "fg*": "allow", "wait*": "allow",
      "shopt*": "allow", "readonly*": "allow", "declare*": "allow", "local*": "allow", "typeset*": "allow",
      "node*": "allow", "npm*": "allow", "npx*": "allow", "yarn*": "allow", "pnpm*": "allow",
      "bun*": "allow", "deno*": "allow", "tsc*": "allow", "ts-node*": "allow", "tsx*": "allow",
      "eslint*": "allow", "prettier*": "allow", "stylelint*": "allow",
      "webpack*": "allow", "vite*": "allow", "esbuild*": "allow", "rollup*": "allow",
      "parcel*": "allow", "snowpack*": "allow", "turbo*": "allow", "lerna*": "allow", "nx*": "allow",
      "jest*": "allow", "vitest*": "allow", "mocha*": "allow", "chai*": "allow",
      "cypress*": "allow", "playwright*": "allow", "storybook*": "allow",
      "babel*": "allow", "postcss*": "allow", "tailwindcss*": "allow", "sass*": "allow",
      "python*": "allow", "python3*": "allow", "pip*": "allow", "pip3*": "allow",
      "poetry*": "allow", "pipenv*": "allow", "pytest*": "allow", "unittest*": "allow",
      "black*": "allow", "flake8*": "allow", "mypy*": "allow", "ruff*": "allow", "pyright*": "allow",
      "isort*": "allow", "bandit*": "allow", "safety*": "allow", "tox*": "allow", "pre-commit*": "allow",
      "ipython*": "allow", "jupyter*": "allow", "notebook*": "allow",
      "java*": "allow", "javac*": "allow", "jar*": "allow", "keytool*": "allow",
      "jdeps*": "allow", "jmod*": "allow", "jlink*": "allow", "jshell*": "allow",
      "gradle*": "allow", "gradlew*": "allow", "mvn*": "allow", "ant*": "allow",
      "kotlin*": "allow", "kotlinc*": "allow", "scala*": "allow", "scalac*": "allow", "groovy*": "allow",
      "cargo*": "allow", "rustc*": "allow", "rustup*": "allow", "clippy*": "allow", "rustfmt*": "allow",
      "go*": "allow", "gofmt*": "allow", "goimports*": "allow", "golint*": "allow", "govet*": "allow", "staticcheck*": "allow",
      "gcc*": "allow", "g++*": "allow", "clang*": "allow", "clang++*": "allow",
      "make*": "allow", "cmake*": "allow", "ninja*": "allow",
      "autoconf*": "allow", "automake*": "allow", "libtool*": "allow", "pkg-config*": "allow", "pkgconf*": "allow",
      "gdb*": "allow", "lldb*": "allow", "valgrind*": "allow", "strace*": "allow", "ltrace*": "allow",
      "ruby*": "allow", "gem*": "allow", "bundle*": "allow", "bundler*": "allow",
      "rails*": "allow", "rake*": "allow", "rspec*": "allow", "rubocop*": "allow",
      "php*": "allow", "composer*": "allow", "phpunit*": "allow", "psalm*": "allow", "phpstan*": "allow",
      "flutter*": "allow", "dart*": "allow", "adb*": "allow", "fastboot*": "allow",
      "xcodebuild*": "allow", "xcode-select*": "allow", "pod*": "allow", "carthage*": "allow",
      "react-native*": "allow", "expo*": "allow", "eas*": "allow",
      "bash*": "allow", "sh*": "allow", "zsh*": "allow", "fish*": "allow",
      "shellcheck*": "allow", "shfmt*": "allow",
      "dotnet*": "allow", "nuget*": "allow", "mono*": "allow",
      "ghc*": "allow", "cabal*": "allow", "stack*": "allow",
      "lua*": "allow", "luarocks*": "allow",
      "perl*": "allow", "cpan*": "allow", "cpanm*": "allow",
      "swift*": "allow", "swiftc*": "allow", "swift-package*": "allow",
      "ps*": "allow", "top*": "allow", "htop*": "allow", "atop*": "allow",
      "kill*": "allow", "killall*": "allow", "pkill*": "allow", "pgrep*": "allow",
      "nice*": "allow", "renice*": "allow", "nohup*": "allow", "disown*": "allow",
      "timeout*": "allow", "time*": "allow", "watch*": "allow",
      "apt install*": "allow", "apt-get install*": "allow", "apt update*": "allow", "apt-get update*": "allow",
      "apt upgrade*": "allow", "apt-get upgrade*": "allow",
      "pkg install*": "allow", "pkg update*": "allow", "pkg upgrade*": "allow",
      "brew install*": "allow", "brew update*": "allow", "brew upgrade*": "allow", "brew link*": "allow",
      "conda install*": "allow", "conda update*": "allow", "conda create*": "allow",
      "snap install*": "allow", "flatpak install*": "allow",
      "pip install*": "allow", "npm install*": "allow", "npm ci*": "allow", "npm update*": "allow",
      "yarn install*": "allow", "yarn add*": "allow", "yarn upgrade*": "allow",
      "pnpm install*": "allow", "pnpm add*": "allow",
      "cargo install*": "allow", "cargo update*": "allow",
      "gem install*": "allow", "bundle install*": "allow",
      "composer install*": "allow", "composer update*": "allow",
      "curl*": "allow", "wget*": "allow", "ssh*": "allow", "scp*": "allow", "rsync*": "allow", "sftp*": "allow",
      "nc*": "allow", "ncat*": "allow", "socat*": "allow",
      "ping*": "allow", "traceroute*": "allow", "nslookup*": "allow", "dig*": "allow", "host*": "allow",
      "ifconfig*": "allow", "ip*": "allow", "ss*": "allow", "netstat*": "allow",
      "tar*": "allow", "gzip*": "allow", "gunzip*": "allow", "bzip2*": "allow", "bunzip2*": "allow",
      "xz*": "allow", "unxz*": "allow", "zip*": "allow", "unzip*": "allow",
      "7z*": "allow", "zstd*": "allow", "unzstd*": "allow", "lzma*": "allow", "unlzma*": "allow",
      "zcat*": "allow", "bzcat*": "allow", "xzcat*": "allow",
      "psql*": "allow", "mysql*": "allow", "sqlite3*": "allow", "redis-cli*": "allow", "mongosh*": "allow",
      "pg_dump*": "allow", "pg_restore*": "allow", "mysqldump*": "allow",
      "docker*": "allow", "podman*": "allow", "nerdctl*": "allow", "buildah*": "allow", "skopeo*": "allow",
      "docker-compose*": "allow", "docker compose*": "allow",
      "qemu*": "allow", "qemu-img*": "allow", "qemu-system*": "allow",
      "terraform*": "allow", "terragrunt*": "allow", "ansible*": "allow", "ansible-playbook*": "allow",
      "helm*": "allow", "kubectl*": "allow", "kustomize*": "allow",
      "vagrant*": "allow", "packer*": "allow",
      "aws*": "allow", "gcloud*": "allow", "az*": "allow", "heroku*": "allow",
      "vercel*": "allow", "netlify*": "allow", "fly*": "allow", "railway*": "allow",
      "build*": "allow", "run*": "allow", "start*": "allow", "stop*": "allow", "restart*": "allow",
      "clean*": "allow", "test*": "allow", "lint*": "allow", "format*": "allow",
      "check*": "allow", "verify*": "allow", "deploy*": "allow", "release*": "allow",
      "package*": "allow", "compile*": "allow", "assemble*": "allow",
      "man*": "allow", "info*": "allow", "help*": "allow", "usage*": "allow", "version*": "allow",
      "bat*": "allow", "exa*": "allow", "lsd*": "allow", "delta*": "allow",
      "fzf*": "allow", "fd*": "allow", "ripgrep*": "allow", "tldr*": "allow", "howdoi*": "allow",
      "rm -rf /*": "ask", "rm -rf /": "ask", "rm -rf ~": "ask", "rm -rf ~/": "ask",
      "rm -rf ..": "ask", "rm -rf .git": "ask",
      "rm -rf /home": "ask", "rm -rf /root": "ask", "rm -rf /etc": "ask", "rm -rf /var": "ask",
      "rm -rf /usr": "ask", "rm -rf /bin": "ask", "rm -rf /sbin": "ask", "rm -rf /lib": "ask",
      "rm -rf /boot": "ask", "rm -rf /dev": "ask", "rm -rf /proc": "ask", "rm -rf /sys": "ask", "rm -rf /tmp": "ask",
      "git push --force*": "ask", "git push -f*": "ask", "git push --force-with-lease*": "ask",
      "git reset --hard*": "ask", "git reset --merge*": "ask",
      "git clean -fd*": "ask", "git clean -fxd*": "ask", "git clean -fXd*": "ask",
      "git filter-branch*": "ask", "git filter-repo*": "ask", "git branch -D*": "ask",
      "sudo*": "ask", "su*": "ask",
      "systemctl stop*": "ask", "systemctl disable*": "ask", "systemctl mask*": "ask",
      "service stop*": "ask", "init 0*": "ask", "init 6*": "ask",
      "shutdown*": "ask", "reboot*": "ask", "halt*": "ask", "poweroff*": "ask",
      "mkfs*": "ask", "fdisk*": "ask", "parted*": "ask", "dd*": "ask", "wipefs*": "ask",
      "mount*": "ask", "umount*": "ask", "swapon*": "ask", "swapoff*": "ask",
      "chmod 777*": "ask", "chmod -R 777*": "ask", "chown -R*": "ask",
      "shred*": "ask", "wipe*": "ask", "srm*": "ask",
      "export PATH=*": "ask", "unset PATH": "ask", "env -i*": "ask",
      "curl | sh*": "ask", "curl | bash*": "ask", "wget | sh*": "ask", "wget | bash*": "ask",
      "curl -sL | sh*": "ask", "curl -sL | bash*": "ask",
      "apt remove*": "ask", "apt purge*": "ask", "apt-get remove*": "ask", "apt-get purge*": "ask",
      "pkg delete*": "ask", "npm uninstall -g*": "ask",
      "terraform destroy*": "ask", "terraform state rm*": "ask", "terragrunt destroy*": "ask",
      "docker system prune*": "ask", "docker system prune -a*": "ask",
      "docker volume rm*": "ask", "docker network rm*": "ask",
      "docker container prune*": "ask", "docker image prune -a*": "ask",
      "curl | sudo sh*": "deny", "curl | sudo bash*": "deny",
      "wget | sudo sh*": "deny", "wget | sudo bash*": "deny",
      "curl -sL | sudo sh*": "deny", "curl -sL | sudo bash*": "deny",
      "rm -rf / --no-preserve-root*": "deny", "rm -rf /* --no-preserve-root*": "deny",
      ":(){:|:&};:*": "deny", "fork bomb*": "deny",
      "dd if=/dev/zero of=/dev/sd*": "deny", "dd if=/dev/random of=/dev/sd*": "deny",
      "mkfs.ext4 /dev/sd*": "deny", "mkfs.xfs /dev/sd*": "deny", "mkfs.btrfs /dev/sd*": "deny",
      "format c:*": "deny", "format c:\\*": "deny",
      "> /dev/sda*": "deny", "mv /* /dev/null*": "deny", "mv ~ /dev/null*": "deny",
      "chmod -R 000 /*": "deny", "chown -R nobody:nogroup /*": "deny",
      "iptables -F": "deny", "iptables -P INPUT ACCEPT": "deny", "iptables -P FORWARD ACCEPT": "deny",
      "ufw disable*": "deny",
      "*": "allow"
    }
  }
}
OPencodeEOF

  # copy agents — 9 termasuk critic (adversarial) & hermes (utusan all-rounder)
  for f in "$SCRIPT_DIR/agents/"*.md; do
    [ -f "$f" ] && cp "$f" "$CFG/agent/" && ok "agent: $(basename "$f")"
  done

  # copy skills (SKILL.md + run.sh)
  for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$CFG/skill/$skill_name"
    [ -f "$skill_dir/SKILL.md" ] && cp "$skill_dir/SKILL.md" "$CFG/skill/$skill_name/"
    [ -f "$skill_dir/run.sh" ] && { cp "$skill_dir/run.sh" "$CFG/skill/$skill_name/"; chmod +x "$CFG/skill/$skill_name/run.sh"; }
    ok "skill: $skill_name"
  done

  # copy commands
  for f in "$SCRIPT_DIR/command/"*.md; do
    [ -f "$f" ] && cp "$f" "$CFG/command/" && ok "command: $(basename "$f")"
  done

  # copy AGENTS.md (doctrine)
  [ -f "$SCRIPT_DIR/AGENTS.md" ] && cp "$SCRIPT_DIR/AGENTS.md" "$CFG/" && ok "doctrine: AGENTS.md"

  # copy panduan lengkap
  mkdir -p "$CFG/docs"
  [ -f "$SCRIPT_DIR/docs/USAGE.md" ] && cp "$SCRIPT_DIR/docs/USAGE.md" "$CFG/docs/" && ok "panduan: docs/USAGE.md"
  [ -f "$SCRIPT_DIR/docs/PLAYBOOKS.md" ] && cp "$SCRIPT_DIR/docs/PLAYBOOKS.md" "$CFG/docs/" && ok "playbook: docs/PLAYBOOKS.md"
  [ -f "$SCRIPT_DIR/docs/ARCHITECTURE.md" ] && cp "$SCRIPT_DIR/docs/ARCHITECTURE.md" "$CFG/docs/" && ok "arsitektur: docs/ARCHITECTURE.md"
  [ -f "$SCRIPT_DIR/docs/ROADMAP.md" ] && cp "$SCRIPT_DIR/docs/ROADMAP.md" "$CFG/docs/" && ok "roadmap: docs/ROADMAP.md"

  # copy memory seed
  for f in "$SCRIPT_DIR/memory/"*.md; do
    [ -f "$f" ] && [ ! -f "$CFG/memory/$(basename "$f")" ] && cp "$f" "$CFG/memory/"
  done

  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  ok "total $N file otak ditulis"
  # catat versi terpasang (dipakai --check, doctor, --update)
  [ -f "$SCRIPT_DIR/VERSION" ] && cp "$SCRIPT_DIR/VERSION" "$CFG/VERSION"
}

# ── pasang ke project ──
install_project(){
  step "PASANG KE PROJECT: $PROJECT"
  if [ ! -d "$PROJECT" ]; then err "folder tidak ditemukan: $PROJECT"; return 1; fi
  # backup AGENTS.md project bila bukan tulisan DEV-BRAIN (marker)
  if [ -f "$PROJECT/AGENTS.md" ] && ! grep -q 'DEV-BRAIN (project ini)' "$PROJECT/AGENTS.md" 2>/dev/null; then
    cp "$PROJECT/AGENTS.md" "$PROJECT/AGENTS.md.bak.$(date +%s)"
    wrn "AGENTS.md project dibackup (isi asli dipertahankan di .bak)"
  fi
  # prune instalasi lama di project biar tidak ada file sisa
  rm -rf "$PROJECT/.opencode/agent" "$PROJECT/.opencode/skill" "$PROJECT/.opencode/command"
  mkdir -p "$PROJECT/.opencode/memory"
  cp -r "$CFG/agent"   "$PROJECT/.opencode/" 2>/dev/null
  cp -r "$CFG/skill"   "$PROJECT/.opencode/" 2>/dev/null
  cp -r "$CFG/command" "$PROJECT/.opencode/" 2>/dev/null
  [ -f "$PROJECT/.opencode/memory/MEMORY.md" ] || cp "$CFG/memory/MEMORY.md" "$PROJECT/.opencode/memory/"
  cat > "$PROJECT/AGENTS.md" <<'EOF'
# DEV-BRAIN (project ini)
Otak utama: DEV — caveman mode ULTRA, pipeline otomatis:
recall+scan → think → imagine+architect → plan (rencana 8 blok TAMPIL dulu) → coder → test → audit → fix → (BUG? debug) → (DOK? doc-full) → (MAHAL? cost) → memory → lapor.
Memori project: `.opencode/memory/`. Doctrine lengkap: `~/.config/opencode/AGENTS.md`.
Tidak perlu command manual — ketik tugas, DEV mengorkestrasi sendiri.
EOF
  ok "terpasang di $PROJECT/.opencode + AGENTS.md"
}

# ── verifikasi instalasi ──
check_install(){
  step "CHECK INSTALASI DEV-BRAIN"
  BAD=0
  [ -f "$CFG/AGENTS.md" ] || { err "doctrine hilang: $CFG/AGENTS.md"; BAD=1; }
  [ -f "$CFG/opencode.json" ] || { err "config hilang: $CFG/opencode.json"; BAD=1; }
  grep -q '"devbrain"' "$CFG/opencode.json" 2>/dev/null || { wrn "opencode.json tanpa marker devbrain (bukan tulisan installer)"; }
  for d in agent command memory skill; do
    [ -d "$CFG/$d" ] || { err "folder hilang: $CFG/$d"; BAD=1; }
  done
  N=$(find "$CFG/agent" "$CFG/skill" "$CFG/command" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${N:-0}" -ge 20 ] || { err "file otak cuma $N — install ulang"; BAD=1; }
  V=$(tr -d '[:space:]' < "$CFG/VERSION" 2>/dev/null)
  if [ -n "$V" ]; then ok "versi terpasang: $V"; else wrn "versi tidak tercatat (install lama) — update disarankan"; fi
  for s in "$CFG"/skill/*/run.sh; do
    [ -f "$s" ] || continue
    bash -n "$s" 2>/dev/null || { err "script rusak: $s"; BAD=1; }
  done
  if [ "$BAD" -eq 0 ]; then ok "instalasi sehat — $N file otak, semua script valid"; return 0; else return 1; fi
}

# ── pasang pre-commit hook git-guard ──
install_hook(){
  step "HOOK GIT-GUARD"
  [ -d .git ] || { err "bukan git repo — jalankan dari root project"; return 1; }
  mkdir -p .git/hooks
  if [ -f .git/hooks/pre-commit ] && ! grep -q 'devbrain' .git/hooks/pre-commit 2>/dev/null; then
    cp .git/hooks/pre-commit ".git/hooks/pre-commit.bak.$(date +%s)"
    wrn "pre-commit lama dibackup (.bak)"
  fi
  cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# DEV-BRAIN git-guard (marker: devbrain) — blokir secret/marker/debug di staged diff
GUARD="$HOME/.config/opencode/skill/git-guard/run.sh"
[ -f "$GUARD" ] && exec bash "$GUARD"
EOF
  chmod +x .git/hooks/pre-commit
  ok "pre-commit → git-guard terpasang (setiap commit otomatis di-scan)"
}

# ── verifikasi & banner akhir ──
finish(){
  step "VERIFIKASI"
  echo
  pc 213 '  ╔════════════════════════════════════════╗'
  pc 177 '  ║   D E V — B R A I N   O N L I N E      ║'
  pc 141 '  ╚════════════════════════════════════════╝'
  echo
  ok "9 agent • 56 skill (16 dengan bash script) • 31 command • memori + pelajaran persisten"
  echo
  pc 45  "  CARA PAKAI:"
  pc 45  "  1) buka folder project apa saja"
  pc 45  "  2) jalankan:  opencode"
  pc 45  "  3) DEV otomatis aktif (satu-satunya primary)"
  pc 45  "  4) ketik tugas bahasa bebas, contoh:"
  pc 213 "     \"buat halaman login, testnya sekalian, audit juga\""
  pc 45  "  5) DEV jalan: mikir→bayang→rencana tampil→bangun→test→audit→ingat"
  echo
  pc 45  "  SHORTCUT : /ship <tugas>   /fix   /memory"
  pc 214 "  API key  : jalankan  opencode auth login  bila belum"
  echo
}

# ═══ MAIN ═══
banner
[ "$SHOWVER" -eq 1 ] && { pc 45 "DEV-BRAIN v$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo '?')"; exit 0; }
[ "$UNINSTALL" -eq 1 ] && { uninstall; }
[ "$CHECK" -eq 1 ] && { check_install; exit $?; }
[ "$UPDATE" -eq 1 ] && { update; }
check_remote_version
write_brain
[ -n "$PROJECT" ] && install_project
[ "$HOOK" -eq 1 ] && install_hook
finish
if [ "$LINT" -eq 1 ] && [ -f "$SCRIPT_DIR/tests/lint-kit.sh" ]; then
  step "LINT VERIFIKASI"
  bash "$SCRIPT_DIR/tests/lint-kit.sh" && bash "$SCRIPT_DIR/tests/self-test.sh"
  echo
fi
exit 0
