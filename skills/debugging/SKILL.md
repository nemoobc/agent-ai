# Debugging

## When to use
Diagnose failures, trace root causes, repair bugs, and prevent regressions. Evidence-based approach over guessing.

## Key rules
- Read the full error message first; don't skip the stack trace
- Form hypothesis, then design a minimal test to confirm or deny
- Reproduce before fixing; if you can't reproduce, you can't verify
- Fix the root cause, not the symptom
- Add a test that would have caught the bug

## Workflow
1. Capture exact error output and context
2. Identify recent changes (git log/diff)
3. Create minimal reproduction case
4. Form hypothesis, test it
5. Implement fix, verify with test
6. Document what happened and why
