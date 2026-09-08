# Observability

## When to use
Implement logging, metrics, tracing, health checks, and alerting. Make systems debuggable and operations actionable.

## Key rules
- Use structured logging (JSON) with consistent fields: timestamp, level, request_id, message
- Alert on symptoms (error rate, latency p99), not causes (CPU usage)
- Health checks must verify dependencies, not just "are you up"
- Correlate logs with trace IDs across service boundaries
- Retain logs for defined periods; rotate aggressively on Termux

## Termux notes
- Log rotation via `logrotate` or manual cron
- Limited storage — monitor disk usage in log directories
- `termux-notification` can surface critical alerts
