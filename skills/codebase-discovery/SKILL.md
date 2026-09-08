# Codebase Discovery

## When to use
Explore an unfamiliar repository: understand structure, conventions, dependencies, and change scope before making modifications.

## Key rules
- Read AGENTS.md, README, CONTRIBUTING first for project conventions
- Identify package manifests (package.json, Cargo.toml, go.mod, requirements.txt)
- Locate entry points and trace critical paths
- Check for existing tests, linting config, and CI/CD setup
- Map directory structure; note naming conventions and code patterns

## Workflow
1. `ls` root directory, read README and AGENTS.md
2. Read package manifest for dependencies and scripts
3. Find entry points (main, index, app)
4. Identify test directories and config files
5. Grep for TODO/FIXME to find known issues
