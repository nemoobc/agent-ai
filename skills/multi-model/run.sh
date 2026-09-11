#!/usr/bin/env bash
# multi-model/run.sh — routing + cost guard + logging untuk semua model AI 2026
# Usage:
#   run.sh --list-models
#   run.sh --task-class <kelas> [--dry-run] [--prompt <teks>]
#   run.sh check   (alias legacy: cek ketersediaan provider)
set -euo pipefail

# ---- config: budget & log ----
MULTI_MODEL_BUDGET_USD="${MULTI_MODEL_BUDGET_USD:-5}"
MULTI_MODEL_LOG="${MULTI_MODEL_LOG:-$HOME/.config/opencode/cost-log.csv}"

# ---- config: pin versi (jangan -latest) ----
OPENAI_MODEL="${OPENAI_MODEL:-gpt-5.5}"
ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-claude-sonnet-5}"
ANTHROPIC_OPUS_MODEL="${ANTHROPIC_OPUS_MODEL:-claude-opus-5}"
GEMINI_MODEL="${GEMINI_MODEL:-gemini-3.8-flash}"
DEEPSEEK_MODEL="${DEEPSEEK_MODEL:-deepseek-flash}"
ZHIPU_MODEL="${ZHIPU_MODEL:-glm-5.2}"
XAI_MODEL="${XAI_MODEL:-grok-4.5}"
MISTRAL_MODEL="${MISTRAL_MODEL:-mistral-large-3}"
QWEN_MODEL="${QWEN_MODEL:-qwen-3.6}"
LLAMA_MODEL="${LLAMA_MODEL:-llama-4-maverick}"
ASTRA_MODEL="${ASTRA_MODEL:-astra-base}"
ASTRA_PRO_MODEL="${ASTRA_PRO_MODEL:-astra-pro}"
ASTRA_BASE_URL="${ASTRA_BASE_URL:-}"

# ---- chain per task-class: "label|key_env|model_var" x3 ----
resolve_chain() {
  case "$1" in
    code_heavy) printf '%s\n' "claude-opus-5|ANTHROPIC_API_KEY|$ANTHROPIC_OPUS_MODEL" "gpt-5.5|OPENAI_API_KEY|$OPENAI_MODEL" "glm-5.3|ZHIPU_API_KEY|glm-5.3" ;;
    code_daily) printf '%s\n' "glm-5.2|ZHIPU_API_KEY|$ZHIPU_MODEL" "gemini-3.8-flash|GEMINI_API_KEY|$GEMINI_MODEL" "qwen-3.6|ALIBABA_API_KEY|$QWEN_MODEL" ;;
    audit)      printf '%s\n' "claude-sonnet-5|ANTHROPIC_API_KEY|$ANTHROPIC_MODEL" "grok-4.5|XAI_API_KEY|$XAI_MODEL" "grok-4-fast|XAI_API_KEY|grok-4-fast" ;;
    reasoning)  printf '%s\n' "gpt-5.5-pro|OPENAI_API_KEY|gpt-5.5-pro" "claude-fable-5-1|ANTHROPIC_API_KEY|claude-fable-5-1" "claude-fable-5|ANTHROPIC_API_KEY|claude-fable-5" ;;
    longdoc)    printf '%s\n' "gemini-3.1-pro|GEMINI_API_KEY|gemini-3.1-pro" "llama-4-scout|TOGETHER_API_KEY|llama-4-scout" "grok-4-fast|XAI_API_KEY|grok-4-fast" ;;
    lang)       printf '%s\n' "gemini-3.8-flash|GEMINI_API_KEY|$GEMINI_MODEL" "qwen-3.5|ALIBABA_API_KEY|qwen-3.5" "glm-flash|ZHIPU_API_KEY|glm-flash" ;;
    budget)     printf '%s\n' "deepseek-flash|DEEPSEEK_API_KEY|$DEEPSEEK_MODEL" "gemini-3.5-flash-lite|GEMINI_API_KEY|gemini-3.5-flash-lite" "gpt-5.6-luna|OPENAI_API_KEY|gpt-5.6-luna" ;;
    selfhost)   printf '%s\n' "qwen-3.6|ALIBABA_API_KEY|$QWEN_MODEL" "mistral-small-4|MISTRAL_API_KEY|mistral-small-4" "llama-4-maverick|TOGETHER_API_KEY|$LLAMA_MODEL" ;;
    astra)      printf '%s\n' "$ASTRA_PRO_MODEL|ASTRA_API_KEY|$ASTRA_PRO_MODEL" "$ASTRA_MODEL|ASTRA_API_KEY|$ASTRA_MODEL" "deepseek-flash|DEEPSEEK_API_KEY|$DEEPSEEK_MODEL" ;;
    *) return 1 ;;
  esac
}

# ---- estimasi kasar USD per call per task-class (snapshot 2026-09-10) ----
estimate_usd() {
  case "$1" in
    code_heavy) echo "1.50" ;; code_daily) echo "0.40" ;;
    audit)      echo "0.80" ;; reasoning)  echo "2.00" ;;
    longdoc)    echo "1.20" ;; lang)       echo "0.20" ;;
    budget)     echo "0.05" ;; selfhost)   echo "0.10" ;;
    astra)      echo "0.30" ;; *)           echo "0.50" ;;
  esac
}

key_set() { [ -n "${!1:-}" ]; }

append_log() {
  local line="$1"
  mkdir -p "$(dirname "$MULTI_MODEL_LOG")" 2>/dev/null || true
  if command -v flock >/dev/null 2>&1; then
    if ! (flock -x 200 && printf '%s\n' "$line" >> "$MULTI_MODEL_LOG") 200>"$MULTI_MODEL_LOG.lock" 2>/dev/null; then
      echo "multi-model: GAGAL tulis log $MULTI_MODEL_LOG" >&2
      return 1
    fi
  else
    if ! printf '%s\n' "$line" >> "$MULTI_MODEL_LOG" 2>/dev/null; then
      echo "multi-model: GAGAL tulis log $MULTI_MODEL_LOG" >&2
      return 1
    fi
  fi
}

ensure_log_header() {
  mkdir -p "$(dirname "$MULTI_MODEL_LOG")" 2>/dev/null || true
  if [ ! -f "$MULTI_MODEL_LOG" ]; then
    if command -v flock >/dev/null 2>&1; then
      (flock -x 200 && printf '%s\n' "timestamp_iso,task_class,model_pin,est_usd,status" > "$MULTI_MODEL_LOG") 200>"$MULTI_MODEL_LOG.lock" 2>/dev/null || return 1
    else
      printf '%s\n' "timestamp_iso,task_class,model_pin,est_usd,status" > "$MULTI_MODEL_LOG" 2>/dev/null || return 1
    fi
  fi
}

list_models() {
  cat <<EOF
# Katalog 2026 (pin versi, jangan -latest):
code_heavy: claude-opus-5 → gpt-5.5 → glm-5.3
code_daily: glm-5.2 → gemini-3.8-flash → qwen-3.6
audit:      claude-sonnet-5 → grok-4.5 → grok-4-fast
reasoning:  gpt-5.5-pro → claude-fable-5-1 → claude-fable-5
longdoc:    gemini-3.1-pro → llama-4-scout → grok-4-fast
lang:       gemini-3.8-flash → qwen-3.5 → glm-flash
budget:     deepseek-flash → gemini-3.5-flash-lite → gpt-5.6-luna
selfhost:   qwen-3.6 → mistral-small-4 → llama-4-maverick
astra:      ${ASTRA_PRO_MODEL} → ${ASTRA_MODEL} → deepseek-flash (internal, TODO DEV)
EOL: ChatGPT 4.1/o3/4o retired 2026-02-13 (API only); Gemini 2.0 SHUTDOWN;
Claude 4.1/4.0/3.5 retired; DeepSeek V4-Pro reroute 2026-09-14;
Gemini 3.8 Flash intro \$0.75/\$3.75 s/d 2026-12-31.
EOF
}

check_keys() {
  local found=0
  local total=16
  for spec in "OPENAI_API_KEY|OpenAI" "ANTHROPIC_API_KEY|Anthropic" "GEMINI_API_KEY|Gemini" "DEEPSEEK_API_KEY|DeepSeek" "ZHIPU_API_KEY|Zhipu/GLM" "XAI_API_KEY|xAI/Grok" "MISTRAL_API_KEY|Mistral" "ALIBABA_API_KEY|Alibaba/Qwen" "TOGETHER_API_KEY|Together/Llama" "ASTRA_API_KEY|Astra (internal)" "OPENROUTER_API_KEY|OpenRouter (semua model)" "MOONSHOT_API_KEY|Moonshot/Kimi" "COHERE_API_KEY|Cohere" "PERPLEXITY_API_KEY|Perplexity/Sonar" "GROQ_API_KEY|Groq" "CEREBRAS_API_KEY|Cerebras"; do
    local env_name="${spec%%|*}" label="${spec##*|}"
    if key_set "$env_name"; then echo "  ✔ $label ready"; found=$((found + 1)); else echo "  · $label: set $env_name"; fi
  done
  echo "  → $found/$total provider tersedia"
}

list_providers() {
  cat <<EOF
# SEMUA PROVIDER BUMI 2026 (katalog lengkap):
# ── Frontier lab ──
OpenAI     gpt-5.5 / 5.5-pro / 5.4 / 5.5-mini / 5.5-nano / 5.6-luna-sol-terra
Anthropic  claude-opus-5 / sonnet-5 / fable-5(-5.1) / haiku-4.5
Google     gemini-3.8-flash / 3.7-flash / 3.1-pro / 3.5-flash-lite
xAI        grok-4.5 / grok-4-fast
# ── Open + value ──
DeepSeek   deepseek-flash (V4.1) / V4-Pro (reroute 2026-09-14)
Zhipu      glm-5.3 / glm-5.2 / glm-4.7 / glm-flash (+Plan Lite18/Pro72/Max160)
Alibaba    qwen-3.5 / qwen-3.6
Meta       llama-4-scout (ctx 10M) / llama-4-maverick
Mistral    mistral-large-3 / mistral-small-4
# ── Sisa bumi ──
Moonshot   kimi-k2 (agentic+tool-use)      MiniMax  minimax-m2 (multimodal)
Cohere     command-a (RAG+citasi)          Amazon   nova-premier (Bedrock)
Microsoft  phi-5 (SLM edge)                Perplexity sonar-pro (search-grounded)
Tencent    hunyuan-t (MoE open)            Baidu    ernie-x2
01.AI      yi-large                        IBM      granite-4 (watsonx)
NVIDIA     nemotron-ultra (NIM)            AI21     jamba-2-large
Reka       reka-core-3 (multimodal)
# ── Aggregator/inference (satu key semua model) ──
OpenRouter 400+ model semua vendor  |  Groq (LPU tercepat)
Cerebras   (throughput raksasa)     |  Fireworks + Together (open-weight)
# ── Internal ──
Astra/Astra Pro: TODO DEV (ASTRA_BASE_URL + auth + model + pricing)
EOL: ChatGPT 4.1/o3/4o retired 2026-02-13; Gemini 2.0 SHUTDOWN;
Claude 4.1/4.0/3.5 retired; DeepSeek V4-Pro reroute 2026-09-14.
EOF
}

fail_no_key() {
  echo "multi-model: model terpilih '$1' butuh $2 — set env dulu (tanpa key → stop, exit 2)" >&2
  exit 2
}

confirm_over_budget() {
  local est="$1"
  echo "multi-model: estimasi \$$est > budget \$${MULTI_MODEL_BUDGET_USD} (HUKUM 5) — lanjut? [y/N]" >&2
  if [ ! -t 0 ]; then echo "multi-model: non-interaktif, tanpa konfirmasi = TIDAK JALAN (exit 2)" >&2; exit 2; fi
  local ans=""
  if ! IFS= read -r ans < /dev/tty 2>/dev/null; then echo "multi-model: batal (tidak ada konfirmasi)" >&2; exit 2; fi
  case "$ans" in y|Y|ya|YA|yes|YES) return 0 ;; *) echo "multi-model: dibatalkan user" >&2; exit 2 ;; esac
}

TASK_CLASS=""; DRY_RUN=0; PROMPT_TEXT=""
MODE="run"

while [ $# -gt 0 ]; do
  case "$1" in
    --task-class) TASK_CLASS="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --list-models) MODE="list"; shift ;;
    --list-providers) MODE="providers"; shift ;;
    --prompt) PROMPT_TEXT="${2:-}"; shift 2 ;;
    check) MODE="check"; shift ;;
    -h|--help) echo "Usage: run.sh --list-models | --list-providers | --task-class <kelas> [--dry-run] [--prompt <teks>] | check"; exit 0 ;;
    *) echo "multi-model: arg tak dikenal: $1" >&2; exit 2 ;;
  esac
done

case "$MODE" in
  list) list_models; exit 0 ;;
  providers) list_providers; exit 0 ;;
  check) check_keys; exit 0 ;;
esac

if [ -z "$TASK_CLASS" ]; then
  echo "multi-model: --task-class wajib (code_heavy|code_daily|audit|reasoning|longdoc|lang|budget|selfhost|astra) atau --list-models" >&2
  exit 2
fi

case "$TASK_CLASS" in
  code_heavy|code_daily|audit|reasoning|longdoc|lang|budget|selfhost|astra) ;;
  *) echo "multi-model: task-class tak dikenal: $TASK_CLASS" >&2; exit 2 ;;
esac

# jalur astra wajib punya BASE_URL (cek URL dulu, bukan cuma key)
if [ "$TASK_CLASS" = "astra" ] && [ -z "$ASTRA_BASE_URL" ]; then
  echo "multi-model: TODO DEV: isi ASTRA_BASE_URL/auth/model/pricing sebelum pakai task-class astra" >&2
  exit 2
fi

mapfile -t CHAIN < <(resolve_chain "$TASK_CLASS")
if [ "${#CHAIN[@]}" -eq 0 ]; then
  echo "multi-model: chain kosong untuk task-class: $TASK_CLASS" >&2
  exit 2
fi

EST="$(estimate_usd "$TASK_CLASS")"

# --dry-run: estimasi tanpa call, jalan TANPA key (lihat EDGE CASE)
# dry-run TIDAK tulis log (hindari polusi repo + race)
if [ "$DRY_RUN" = "1" ]; then
  first="${CHAIN[0]}"; fmodel="${first##*|}"
  echo "MODEL  : $fmodel (#1 dari chain $TASK_CLASS) [DRY-RUN]"
  echo "BIAYA  : ~\$$EST (estimasi, tanpa call; budget \$$MULTI_MODEL_BUDGET_USD)"
  pos=0
  for entry in "${CHAIN[@]}"; do
    pos=$((pos + 1))
    label="${entry%%|*}"; rest="${entry#*|}"; keyenv="${rest%%|*}"; model="${rest##*|}"
    if key_set "$keyenv"; then st="key-ok"; else st="tanpa-key($keyenv)"; fi
    echo "  #$pos $model [$st]"
  done
  echo "LOG    : $MULTI_MODEL_LOG (dry-run: tanpa tulis)"
  exit 0
fi

# pilih kandidat pertama yang key-nya ada
PICK_LABEL=""; PICK_KEY=""; PICK_MODEL=""; PICK_POS=0
pos=0
for entry in "${CHAIN[@]}"; do
  pos=$((pos + 1))
  label="${entry%%|*}"; rest="${entry#*|}"; keyenv="${rest%%|*}"; model="${rest##*|}"
  if key_set "$keyenv"; then PICK_LABEL="$label"; PICK_KEY="$keyenv"; PICK_MODEL="$model"; PICK_POS="$pos"; break; fi
done

if [ -z "$PICK_LABEL" ]; then
  first="${CHAIN[0]}"; flabel="${first%%|*}"; frest="${first#*|}"; fkey="${frest%%|*}"
  if [ "$TASK_CLASS" = "astra" ] && { [ -z "$ASTRA_BASE_URL" ] || ! key_set "ASTRA_API_KEY"; }; then
    echo "multi-model: TODO DEV: isi ASTRA_BASE_URL/auth/model/pricing sebelum pakai task-class astra" >&2
  fi
  fail_no_key "$flabel" "$fkey"
fi

EST="$(estimate_usd "$TASK_CLASS")"

# pre-check budget: bandingkan float via awk
OVER="$(awk -v e="$EST" -v b="$MULTI_MODEL_BUDGET_USD" 'BEGIN{print (e+0>b+0)?1:0}')"
if [ "$OVER" = "1" ]; then
  confirm_over_budget "$EST"
fi

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)"
ensure_log_header || { echo "multi-model: GAGAL siapkan log" >&2; exit 1; }

# call nyata belum diimplementasikan di runner ini: catat penugasan + serahkan ke pemanggil
echo "MODEL  : $PICK_MODEL (#$PICK_POS dari chain $TASK_CLASS)"
echo "BIAYA  : ~\$$EST (budget \$$MULTI_MODEL_BUDGET_USD)"
echo "PROMPT : ${PROMPT_TEXT:-<dari pemanggil>}"
echo "NOTE   : runner mencatat routing; eksekusi HTTP dilakukan pemanggil dengan pin versi di atas."
append_log "$TS,$TASK_CLASS,$PICK_MODEL,$EST,routed" || exit 1
