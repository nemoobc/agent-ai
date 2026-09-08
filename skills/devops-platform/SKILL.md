# DevOps & Platform

## When to use
Docker, CI/CD pipelines, Linux administration, deployment automation, infrastructure management, and reliability engineering.

## Key rules
- Automate deployments; no manual steps on production
- Use immutable infrastructure; replace, don't patch
- Monitor everything; alert on symptoms, not causes
- Implement rollback procedures before deploying
- Document runbooks for common failure modes

## Termux notes
- **No root, no sudo, no proot, no chroot**
- **No Docker** — use `proot-distro` if needed for full Linux
- Package manager: `pkg` only, not `apt`
- Services must bind 127.0.0.1, ports >= 1024
- No systemd; use `termux-services` or `crond`
