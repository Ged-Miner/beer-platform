# 0015. CI/CD with GitHub Actions: build once, promote by digest

- **Status:** Accepted
- **Date:** 2026-09-25

## Context

The project's primary goal is to demonstrate well-principled delivery practice, transferable to a workplace currently deploying manually. The architecture (ADRs 0010–0014) needs coordinated infrastructure changes, database migrations, container releases, and static asset uploads.

## Decision

- **GitHub Actions** in a **public repository** on GitHub Free (free standard runners; environments and required reviewers available for public repos).
- **Pull-request workflow:** lint, typecheck, unit tests; image build without push; Terraform checks and plans (read-only role) posted to the PR; Kubernetes smoke test on a kind cluster when deployment files change. All required checks.
- **Main workflow:** build the image once (tag = commit SHA, immutable ECR tags, scan, record digest) → DSQL integration tests → staging (apply, migrate, release, upload, smoke) → production behind a required-reviewer environment, releasing **the same digest**.
- Concurrency groups per environment; automatic alias rollback on failed smoke tests.
- Supply-chain hardening: actions pinned to full commit SHAs with Dependabot updates; minimal per-job permissions.

Details: [07-delivery-pipeline.md](../07-delivery-pipeline.md).

## Alternatives considered

- **Private repository.** Environments and required reviewers would need GitHub Pro; Actions minutes limited. Not worth it for a portfolio project.
- **Rebuild per environment.** Simpler workflows, but staging would not test the exact production artifact.
- **Continuous deployment to production without approval.** Reasonable later; a manual gate is appropriate while the test suite matures.

## Consequences

- Production deploys are a one-click approval of an already-tested artifact.
- The pipeline itself is code, reviewed like any other change.
- Public workflows require care: never expose AWS roles or secrets to untrusted pull-request code.
