---
description: multi-model — panggil AI model apa aja (OpenAI/Claude/Gemini/DeepSeek/Grok/Mistral) via DEV
agent: dev
---

TUGAS: $ARGUMENTS

DEV menjalankan skill multi-model: pilih model terbaik untuk konteks tugas, panggil, dan kembalikan hasil.

## Usage

```
/multi-model [model:prompt]
```

- `model` — nama model (openai, claude, gemini, deepseek, grok, mistral). Kosong = auto-select.
- `prompt` — pertanyaan/instruksi untuk model

## Triggers

- **skill multi-model** — routing ke model yang tepat
- **skill cost** — estimasi biaya sebelum panggil

## Example

```
/multi-model explain Kubernetes pod scheduling
/multi-model claude:review this code for security
/multi-model gemini:generate API schema from this OpenAPI spec
```

## Expected Output

```
MULTI-MODEL: auto → claude (konteks: code review)
├── MODEL: claude-3.5-sonnet
├── PROMPT: 248 token
├── RESPONSE: 1,024 token
├── COST: $0.003
└── RESULT:
    3 security issues found: ...
```

## Error Cases

- **Model tidak tersedia** → auto-select model lain + lapor
- **API key tidak ada** → lapor "API key tidak ditemukan untuk [model]"
- **Biaya > threshold** → eskalasi ke user (HUKUM 5)

## Related Commands

- `/cost** — estimasi biaya sebelum panggil
- `/data** — analisis data dengan model terbaik
