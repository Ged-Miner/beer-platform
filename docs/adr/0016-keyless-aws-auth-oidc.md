# 0016. Keyless AWS authentication from CI via GitHub OIDC

- **Status:** Accepted
- **Date:** 2026-09-25

## Context

Long-lived AWS access keys stored in CI secrets never expire on their own and are a prime target for supply-chain attacks. GitHub Actions can mint a short-lived OIDC token per run that AWS STS exchanges for temporary credentials.

## Decision

- Register the GitHub OIDC identity provider in the AWS account (in `infra/bootstrap`).
- Three IAM roles with narrowly scoped trust policies: `ci-plan` (pull requests, read-only), `deploy-staging` (`staging` environment), `deploy-production` (`production` environment).
- Trust policies require `aud = sts.amazonaws.com` and an exact `sub` match.
- **Use the immutable subject format**: repositories created after 2026-07-15 receive subjects of the form `repo:<owner>@<owner_id>/<repo>@<repo_id>:...`. Trust policies must include the numeric IDs.
- Use `aws-actions/configure-aws-credentials` (v6 line at time of writing), pinned by commit SHA.
- No AWS access keys stored in GitHub.

## Alternatives considered

- **IAM user access keys in GitHub secrets.** Simple, widely used in older tutorials, and exactly the practice this project aims to replace.
- **Wildcard subjects (`repo:<owner>/*`).** Convenient but lets any repository or branch assume the roles.

## Consequences

- A leaked token is short-lived and limited to one role's permissions.
- Trust policies copied from pre-2026 guides will not match this repository; the numeric IDs must be looked up (`gh api repos/<owner>/<repo>`).
- Renaming or transferring the repository changes nothing in the IDs, but trust policies should be re-verified after any such change.
