# Testing & QA

## When to use
Write unit, integration, E2E, and regression tests. Ensure coverage, catch edge cases, verify real output.

## Key rules
- Test behavior, not implementation; tests should survive refactors
- Cover edge cases: empty input, null, boundary values, errors
- Assert on real output; never assert `true` without conditions
- Keep tests fast and deterministic; no flaky tests
- Each test one concept; descriptive names that document intent

## Test pyramid
- **Unit**: Fast, isolated, high coverage (70%+)
- **Integration**: Fewer, test real interactions (20%)
- **E2E**: Minimal, critical user paths (10%)

## Termux notes
- Most test frameworks work via `pkg install` runtimes
- No GUI browsers; use headless or API-level tests
