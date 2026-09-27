# 0018. Application releases separate from Terraform

- **Status:** Accepted
- **Date:** 2026-09-25

## Context

Code releases happen far more often than infrastructure changes, need fast rollback, and should not require the broad permissions of a Terraform apply.

## Decision

- Terraform creates and configures the Lambda functions, aliases, and permissions, and **ignores changes to the function image** (`lifecycle.ignore_changes`).
- A release script (run in the pipeline) updates the function to a new **image digest**, publishes a new version, smoke-tests it, and moves the `live` alias. CloudFront and triggers point at the alias.
- Rollback moves the `live` alias to the previous version.
- Static assets: content-hashed files uploaded first, `index.html` last.

## Alternatives considered

- **Release everything through Terraform** (image digest as a variable). One tool and visible plans, but slower releases, broader deploy permissions, and rollback requires another apply.

## Consequences

- Rollback in seconds, without Terraform.
- Terraform plans won't show the running code version; the release script records it (digest, version, commit) in the deployment log and GitHub deployment history.
- Weighted aliases make canary releases a straightforward future addition.
