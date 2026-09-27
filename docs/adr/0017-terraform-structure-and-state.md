# 0017. Terraform structure and state

- **Status:** Accepted
- **Date:** 2026-09-25

## Context

Infrastructure must be reproducible from code (NFR 6), with separate staging and production environments that are hard to confuse. CI cannot create the roles it needs to run.

## Decision

- **Layout:** `infra/bootstrap` (applied once by hand: state bucket, OIDC provider, CI roles), `infra/modules/*` (static-site, api, worker, database, observability), and thin root modules in `infra/envs/staging` and `infra/envs/production`.
- **Directories per environment, not workspaces:** separate state files, separate roles, explicit paths.
- **State:** S3 backend with versioning, encryption, and public access blocked; **native S3 locking** (`use_lockfile = true`). DynamoDB locking is deprecated and not used. Requires Terraform ≥ 1.10.
- **Pinning:** Terraform version pinned in CI; provider lock file (`.terraform.lock.hcl`) committed.
- **Checks on every pull request:** `fmt -check`, `validate`, tflint, an IaC security scanner, and `plan` for both environments.
- `apply` runs only in the main workflow, per environment, with that environment's role.

## Alternatives considered

- **Terraform workspaces.** Less duplication, but one misplaced `workspace select` can apply to the wrong environment, and roles cannot be separated as cleanly.
- **Terragrunt.** Reduces repetition at scale; unnecessary for two environments.
- **HCP Terraform (Terraform Cloud).** Managed state and runs; adds an external dependency and hides practices this project aims to demonstrate.

## Consequences

- The bootstrap layer is the one manual step, documented in a runbook with its own state file.
- Small duplication between the two environment root modules, kept thin by modules.
