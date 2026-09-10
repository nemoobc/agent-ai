#!/usr/bin/env bash
# multi-model/run.sh — cek & routing model AI yang tersedia
set -u
MODE="${1:-check}"

check_keys(){
  local _found=0
  if [ -n "${OPENAI_API_KEY:-}" ]; then echo "  ✔ OpenAI ready"; _found=$((_found + 1)); else echo "  · OpenAI: set OPENAI_API_KEY"; fi
  if [ -n "${ANTHROPIC_API_KEY:-}" ]; then echo "  ✔ Anthropic ready"; _found=$((_found + 1)); else echo "  · Anthropic: set ANTHROPIC_API_KEY"; fi
  if [ -n "${GEMINI_API_KEY:-}" ]; then echo "  ✔ Gemini ready"; _found=$((_found + 1)); else echo "  · Gemini: set GEMINI_API_KEY"; fi
  if [ -n "${DEEPSEEK_API_KEY:-}" ]; then echo "  ✔ DeepSeek ready"; _found=$((_found + 1)); else echo "  · DeepSeek: set DEEPSEEK_API_KEY"; fi
  if [ -n "${GROK_API_KEY:-}" ]; then echo "  ✔ Grok ready"; _found=$((_found + 1)); else echo "  · Grok: set GROK_API_KEY"; fi
  if [ -n "${MISTRAL_API_KEY:-}" ]; then echo "  ✔ Mistral ready"; _found=$((_found + 1)); else echo "  · Mistral: set MISTRAL_API_KEY"; fi
  echo "  → $_found/6 provider tersedia"
}

case "$MODE" in
  check) check_keys ;;
  *) echo "multi-model: $MODE — cek ketersediaan provider"; check_keys ;;
esac