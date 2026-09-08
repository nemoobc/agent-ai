# Database

## When to use
Design schemas, write migrations, optimize queries, manage ORM config, or ensure data integrity in relational or document databases.

## Key rules
- Always use constraints (NOT NULL, UNIQUE, CHECK, FK); never trust app-level validation
- Wrap multi-statement writes in transactions; keep them short
- Index columns used in WHERE, JOIN, ORDER BY; avoid over-indexing
- Test migrations rollback before applying to production
- Never expose raw database errors to clients

## Termux notes
- `sqlite3` available via `pkg install sqlite`
- No MySQL/PostgreSQL servers typically; prefer SQLite for local work
- Use WAL mode for better concurrency: `PRAGMA journal_mode=WAL;`
