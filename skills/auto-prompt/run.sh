#!/usr/bin/env bash
# auto-prompt — Generate prompt lengkap & matang dari input user yang kasar/pendek
# Usage: bash skills/auto-prompt/run.sh "input user"
set -euo pipefail

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  echo "✖ Usage: bash skills/auto-prompt/run.sh \"input user\""
  exit 1
fi

p(){ printf '\033[38;5;%sm%s\033[0m\n' "$2" "$1"; }
header(){ p "═══ AUTO-PROMPT GENERATOR ═══" 213; }
step(){ p "  → $1" 248; }
ok(){ p "  ✔ $1" 82; }
result(){ p "" 0; p "═══ PROMPT HASIL ═══" 82; }

header
step "Menganalisis input: \"$INPUT\""

# Deteksi domain/aktoritas
DOMAIN="umum"
case "$INPUT" in
  *login*|*auth*|*register*|*signup*|*signin*|*password*|*oauth*|*jwt*|*session*)
    DOMAIN="autentikasi";;
  *api*|*endpoint*|*rest*|*graphql*|*route*|*server*)
    DOMAIN="API/backend";;
  *ui*|*ux*|*design*|*component*|*button*|*form*|*modal*|*dashboard*|*page*|*layout*)
    DOMAIN="UI/UX";;
  *test*|*spec*|*assert*|*mock*|*coverage*|*unit*|*e2e*|*integration*)
    DOMAIN="pengujian";;
  *bug*|*fix*|*error*|*crash*|*broken*|*debug*|*issue*)
    DOMAIN="debugging";;
  *deploy*|*ci*|*cd*|*docker*|*kubernetes*|*nginx*|*server*|*hosting*|*cloud*)
    DOMAIN="devops/deployment";;
  *database*|*db*|*sql*|*migration*|*schema*|*query*|*model*|*orm*)
    DOMAIN="database";;
  *security*|*vulnerability*|*xss*|*csrf*|*injection*|*encrypt*|*hash*)
    DOMAIN="keamanan";;
  *perf*|*optim*|*speed*|*cache*|*fast*|*slow*|*latency*|*memory*)
    DOMAIN="performa";;
  *doc*|*readme*|*changelog*|*comment*|*javadoc*|*jsdoc*)
    DOMAIN="dokumentasi";;
  *refactor*|*clean*|*restructure*|*organize*|*simplify*)
    DOMAIN="refaktorisasi";;
  *feature*|*fitur*|*add*|*create*|*build*|*implement*|*bikin*|*buat*|*tambah*)
    DOMAIN="pengembangan fitur";;
esac

step "Domain terdeteksi: $DOMAIN"

# Deteksi bahasa target
LANG_TARGET="tergantung project"
case "$INPUT" in
  *javascript*|*js*|*node*|*express*|*react*|*vue*|*next*|*nuxt*)
    LANG_TARGET="JavaScript/TypeScript";;
  *python*|*django*|*flask*|*fastapi*|*pip*)
    LANG_TARGET="Python";;
  *golang*|*go*|*goroutine*)
    LANG_TARGET="Go";;
  *rust*|*cargo*|*rustc*)
    LANG_TARGET="Rust";;
  *java*|*spring*|*maven*|*gradle*)
    LANG_TARGET="Java";;
  *php*|*laravel*|*symfony*|*composer*)
    LANG_TARGET="PHP";;
  *ruby*|*rails*|*gem*)
    LANG_TARGET="Ruby";;
  *bash*|*shell*|*script*)
    LANG_TARGET="Bash/Shell";;
esac

step "Bahasa target: $LANG_TARGET"

# Generate prompt
cat <<PROMPT
╔══════════════════════════════════════════════════════════════╗
║                    AUTO-PROMPT GENERATED                      ║
╚══════════════════════════════════════════════════════════════╝

## KONTEKS
- Domain: $DOMAIN
- Bahasa: $LANG_TARGET
- Input awal: "$INPUT"

## TUJUAN
Buat/ubah/implementasikan: $INPUT

## ATURAN
1. Ikuti konvensi project yang sudah ada (jangan ubah style yang sudah jalan)
2. Semua perubahan wajib punya test (unit test minimal)
3. Diff kecil & fokus — jangan refactor yang tidak diminta
4. Error handling wajib ada
5. Dokumentasi update jika ada perubahan user-visible

## EXPECTED OUTPUT
- Kode bersih, tanpa TODO tersembunyi
- Test hijau (semua pass)
- Tidak ada breaking change kecuali diminta
- Commit message jelas: "type(scope): deskripsi"

## SUCCESS CRITERIA
- [ ] Fitur berfungsi sesuai input
- [ ] Test pass
- [ ] Tidak ada regression
- [ ] Code review ready

## EKSEKUSI
Pipeline: MIKIR → BAYANGKAN → GODOK → BANGUN → TEST → AUDIT → LAPOR
Jalur: AUTO (router tentukan berdasarkan kompleksitas)
PROMPT

ok "Prompt berhasil digenerate"
ok "Domain: $DOMAIN | Bahasa: $LANG_TARGET"
p "═══ SELESAI ═══" 82
