# Backend API

## When to use
Build or maintain backend services, REST/GraphQL APIs, authentication, authorization, webhooks, or message queues.

## Key rules
- Validate all input at the boundary; reject early with descriptive errors
- Return consistent error envelopes: `{ error: { code, message, details } }`
- Implement rate limiting per client/key; return `429` with `Retry-After`
- Add health check endpoints; expose readiness and liveness probes
- Never log secrets, tokens, or PII; use structured logging

## Termux notes
- Use `pkg` to install runtimes (node, python, go)
- Servers must bind 127.0.0.1, ports >= 1024
- No root access; adjust system limits via `ulimit` only
