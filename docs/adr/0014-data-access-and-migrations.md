# 0014. Data access with Drizzle and a DSQL-aware migration runner

- **Status:** Accepted
- **Date:** 2026-09-24

## Context

Aurora DSQL (ADR 0011) applies one DDL statement per transaction, forbids mixing DDL and DML in a transaction, has no `SAVEPOINT`, requires `CREATE INDEX ASYNC`, and uses optimistic concurrency. drizzle-kit's `migrate` command has been reported to apply several pending migration files within a single transaction, which conflicts with these rules. No official local DSQL emulator was found (checked 2026-09-24).

## Decision

- **Connection:** the official Aurora DSQL Connector for node-postgres (automatic IAM token generation and refresh).
- **Queries and schema:** Drizzle ORM, behind a thin repository layer in `packages/db` that uses DSQL-compatible SQL.
- **Keys:** UUID primary keys.
- **Retries:** a transaction wrapper that retries SQLSTATE 40001 (optimistic concurrency conflicts) with exponential backoff and jitter.
- **Tenant scoping:** repository functions require an organization ID; direct table access outside `packages/db` is disallowed by lint rules and covered by isolation tests (ADR 0004).
- **Migrations:**
  - `drizzle-kit generate` produces SQL files; files are reviewed in pull requests.
  - A custom runner applies them: one statement per transaction, idempotent statements (`IF NOT EXISTS`), `CREATE INDEX ASYNC` for indexes, progress recorded in a tracking table, safe to re-run after partial failure.
  - Runs as a pipeline step before each deploy, using a dedicated IAM role.
  - Schema changes follow expand/contract so old and new code can run side by side (zero-downtime deploys).
- **Testing:**
  - Fast tests run against local PostgreSQL in Docker, restricted to the DSQL-compatible subset.
  - CI integration tests run against a real DSQL development cluster (within the free tier), including migrations and concurrency-conflict retries.

## Alternatives considered

- **drizzle-kit migrate as-is.** Conflicts with DSQL's DDL transaction rules.
- **A different migration tool.** Most assume transactional multi-statement DDL; same problem.
- **Raw SQL without an ORM.** Workable, but loses typed queries.

## Consequences

- A small, well-tested piece of in-house tooling to maintain (and to show in the portfolio).
- Migrations are not atomic across statements; idempotency and expand/contract compensate.
- Local tests can pass while DSQL-specific behavior fails; the CI DSQL stage is mandatory before deploy.
