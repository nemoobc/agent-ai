# Data Analysis

## When to use
Analyze CSV, JSON, SQL data; compute metrics; generate reproducible reports; clean and transform datasets.

## Key rules
- Report data quality issues: missing values, duplicates, type mismatches
- Document all transformations; code must be re-runnable
- State limitations and assumptions explicitly
- Use sampling for large datasets; warn about performance
- Prefer `jq` for JSON, `sqlite3` for SQL, `awk`/`csvkit` for CSV

## Termux notes
- Install `sqlite3` via `pkg install sqlite`
- Use `python3` with `csv`/`json` modules for complex transformations
- `jq` available via `pkg install jq`
