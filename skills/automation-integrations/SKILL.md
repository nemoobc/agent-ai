# Automation & Integrations

## When to use
Write scripts, schedulers, webhooks, API integrations, ETL pipelines, or batch automation. Optimize for reliability and repeatability over speed.

## Key rules
- All automation must be idempotent — safe to re-run without side effects
- Implement retry with exponential backoff; never retry blind on 4xx errors
- Log every step with timestamps; emit structured JSON for machine parsing
- Validate inputs before processing; fail fast with clear error messages
- Use temp files for intermediate state; clean up on failure

## Termux notes
- Use `cronie` or `termux-job-scheduler` for scheduling
- `curl` is your HTTP client; no `wget` by default
- Bind listeners to 127.0.0.1, ports >= 1024
