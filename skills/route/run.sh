#!/usr/bin/env bash
# route — router intensitas: NORMAL / FULL / ULTRA (sumber kebenaran pemicu)
# exit 0 selalu; baris "JALUR:" = hasil. Dilarang edit di luar sini (HUKUM 10).
set -u
PROMPT="${1:-}"
[ -z "$PROMPT" ] && { echo "JALUR: NORMAL (prompt kosong)"; exit 0; }
L=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')

# KELAS ULTRA — SUMMONS EKSLISIT: user minta semua kemampuan muncul.
# (semua bentuk "panggil/summon/ke/tunjukkan/luar + semua/semuanya/all",
#  kata kemampuan, all-out, mode terkuat, GPT-tertinggi)
ULTRA_RE='((panggil|panggilin|summon|panggill?lah|eksekusi|turunkan|kerahkan|bangkitkan|hidupkan|pakai|gunakan|bawa|keluarkan|tunjukkan|tunjukin|tampilin|perlihatkan|lihatin|show|bring|call|deploy|mobilize|unleash|activate|wake)[[:space:]]+(semua|semuanya|all|full|mux?es)[[:space:]]*(agent|skill|kemampuan|talenta|tim|forces|power|crew|battalion|team|otak|brain|squad|army|pasukan)?)|((semua|semuanya|all)[[:space:]]+(agent|skill|kemampuan|talenta|tim|forces|power|crew|team|otak|brain))|(kemampuanmu|talentamu|bakatmu|kemampuan lu|bakat lu|seluruh kemampuan|seluruh bakat|gabungin semua|gabung semua|kompilasi semua|himpun semua|himpunkan semua|kumpul(in)? semua|rarungkan semua|akumulasikan semua)|((all|full|full)[- ]?(out|power|force|throttle|max|maxed|blast|ga?m?ing|mode))|(mode[[:space:]]+(ultra|max|terkuat|paling kuat|titan|beast|monster))|(ultra|ultranya|terultra|ultra mode)|(gpt-?[5-9x]|o[3-9][[:space:]]?(pro|max)?)|(panggil[[:space:]]+otak|summon[[:space:]]+(the|semua|all)|rasakan[[:space:]]+kemampuan|show[[:space:]]+off[[:space:]]+(all|semua)|pamer(in)?[[:space:]]+(semua|kemampuan|bakat)|pertunjukkan[[:space:]]+(kemampuan|bakat))'

# KELAS FULL — minta kerja lebih dalam, TETAP respon biasa tanpa panggil semua.
# (perbaikan/matyen/lengkapi/perdalam/pertebal + superlative tanpa "semua")
FULL_RE='((lengkapi?|lengkapin|lebih lengkap|paling lengkap|terlengkap|matangkan?|matang lagi|matengin|mateng|paling matang|termatang|bagusin|baguskan|perbagus|perindah|rapikan|permak|pertajam|tajamkan|sempurnakan|upgrade|upgradein|perdalam|dalam(in)?|pertebal|tebalkan|perkuat|kuatkan|maksimalkan|optimalin|optimalkan|polish|refine|improve|better|deepen|enrich|expand|polishin|kerjain (abis|tuntas|beres)|abiskan|tuntaskan|beresin (abis|tuntas)|detail(in)?|terperinci|terperinci(in)?|jelaskan (detail|panjang|lengkap)|lebih (detail|dalam|dalam(in)|lengkap|matang|bagus|baik|keren|powerful|kuat)|paling (detail|dalam|keren|powerful)|super|ekstra|extra|depth)([[:space:]]+(lagi|banget|dong|ya|abie[sz]|abis))?)|(full|fullest|hardcore|inside[- ]?out)'

has_ultra=0
echo "$L" | grep -Eq "$ULTRA_RE" && has_ultra=1
has_full=0
echo "$L" | grep -Eq "$FULL_RE" && has_full=1

if [ "$has_ultra" -eq 1 ]; then
  echo "JALUR: ULTRA"
  echo "PEMICU: $(echo "$L" | grep -Eo "$ULTRA_RE" | sort -u | tr '\n' ' ')"
  echo "KELAS: ULTRA — PANGGIL SEMUA: 11 agent + caveman ULTRA + skill gerbang wajib + verify 10 gerbang"
elif [ "$has_full" -eq 1 ]; then
  echo "JALUR: FULL"
  echo "PEMICU: $(echo "$L" | grep -Eo "$FULL_RE" | sort -u | tr '\n' ' ')"
  echo "KELAS: FULL — kerja lebih dalam (riset+test+dok), respon biasa, delegasi seperlunya"
else
  echo "JALUR: NORMAL"
  echo "PEMICU: -"
  echo "KELAS: NORMAL — respon biasa, kerja langsung, tanpa delegasi; skill hanya bila dibutuhkan"
fi
exit 0