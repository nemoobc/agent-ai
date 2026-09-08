# Security (Defensive)

## When to use
Secure coding practices, threat modeling, vulnerability assessment, dependency auditing, and remediation guidance.

## Key rules
- Check for: injection (SQL, XSS, command), broken auth, sensitive data exposure
- Validate and sanitize all untrusted input at system boundaries
- Never hardcode secrets; use environment variables or secret managers
- Audit dependencies regularly; prefer minimal dependency sets
- Apply principle of least privilege everywhere

## Checklist
- [ ] Input validation on all external endpoints
- [ ] Authentication on sensitive routes
- [ ] No secrets in code or logs
- [ ] Dependencies scanned for CVEs
- [ ] Errors don't leak internal details
