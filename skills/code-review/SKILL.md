# Code Review

## When to use
Review code changes for defects, security issues, regressions, and missing validation. Prioritize risk over style.

## Key rules
- Flag correctness bugs first, security second, style last
- Use severity tags: `[HIGH]` must fix, `[MED]` should fix, `[LOW]` nice to have
- Format: `[SEV] file:line — description of issue`
- Check for: injection, auth bypass, data leaks, missing error handling, race conditions
- Praise good patterns; suggest alternatives, not just criticisms

## Output format
```
[HIGH] src/auth.ts:42 — SQL injection via unsanitized query param
[MED]  src/api.ts:87 — Missing rate limit on login endpoint
[LOW]  src/utils.ts:15 — Unused variable `temp`
```
