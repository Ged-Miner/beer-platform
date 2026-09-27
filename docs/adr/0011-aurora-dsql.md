# 0011. Aurora DSQL as the primary database

- **Status:** Accepted
- **Date:** 2026-09-24
- **Supersedes:** the database bullet of ADR 0008 ("smallest suitable instance, single-AZ")

## Context

RDS PostgreSQL requires a VPC. Code that talks to RDS must then run in the VPC, and any component that also calls the external AI API needs internet egress, normally via a NAT Gateway (~$32+/month before data), which breaks the ¥5,000 ceiling. The smallest RDS instance alone (~$18/month in Tokyo) is also most of the Demo budget, and it is single-AZ.

Aurora DSQL (checked 2026-09-24):

- Serverless, PostgreSQL-compatible; authenticates with **IAM tokens**, so clients do not need to be inside a VPC.
- Available in Tokyo (ap-northeast-1).
- Scales to zero when idle. Free tier each month: 100,000 DPUs and 1 GB storage. Beyond that (US East list price): $8 per million DPUs, $0.33 per GB-month. Tokyo pricing to be confirmed before quoting clients.
- Replicated across three Availability Zones; billed for one logical copy.
- Backups through AWS Backup; restores always create a new cluster.
- Official Node.js connector for node-postgres handles IAM token generation and refresh.

## Decision

Use Aurora DSQL (single-Region cluster in Tokyo) as the primary database for all tracks.

## Alternatives considered

- **RDS PostgreSQL (db.t4g.micro).** Full PostgreSQL, most common in job postings. Requires VPC design that avoids NAT (for example, S3 gateway endpoints as a message bus), single-AZ in the Demo budget, and ~$18/month fixed.
- **Aurora Serverless v2 with auto-pause.** Full PostgreSQL and scales to zero, but still VPC-bound, and resuming takes on the order of 15 s, unacceptable for customer-facing paths.
- **DynamoDB.** No VPC and very cheap, but the relational domain model (organizations, venues, beers, listings, provenance) fits SQL better.

## Consequences

- **No VPC or NAT Gateway anywhere in the architecture** (see ADR 0012).
- Database cost in the Demo track drops to near zero; three-AZ durability comes built in, so the Growth track no longer needs a Multi-AZ upgrade.
- DSQL is a PostgreSQL subset. Known constraints to design around:
  - One DDL statement per transaction; DDL and DML cannot share a transaction.
  - No extensions; no `SAVEPOINT`; no `TRUNCATE`; indexes created with `CREATE INDEX ASYNC`.
  - Optimistic concurrency: conflicting transactions fail with a retriable error (SQLSTATE 40001), so writes need a retry wrapper.
  - Transaction size and duration limits; bulk operations must be batched.
  - UUIDs recommended for primary keys.
  - Foreign key constraints were added on 2026-08-26; treat them as new and test them explicitly.
- Data access and migrations are designed around these constraints (ADR 0014).
- **Fallback plan:** if the walking skeleton shows a blocking incompatibility, revert to RDS PostgreSQL with a NAT-free VPC design, recorded in a new ADR.
- Portfolio note: the RDS vs DSQL evaluation against a hard cost ceiling is itself a documented architecture trade-off.
