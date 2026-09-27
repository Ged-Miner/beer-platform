# 0023. No stored secrets in the MVP

- **Status:** Accepted
- **Date:** 2026-09-26

## Context

Stored secrets must be protected, rotated, and audited, and they are the most common thing leaked from CI systems and repositories. The architecture chosen in ADRs 0011, 0016, 0020, and 0022 authenticates every connection by identity rather than by shared secret.

## Decision

| Connection | Authentication |
| --- | --- |
| GitHub Actions → AWS | OIDC, short-lived role credentials (ADR 0016) |
| API and worker → Aurora DSQL | IAM authentication tokens (ADR 0011) |
| Worker → Bedrock | Lambda IAM role (ADR 0020) |
| Owner app → Cognito | Public client, PKCE (ADR 0022) |
| API → Cognito tokens | Public JSON Web Key Set |

- The MVP stores **no secrets**. Non-secret configuration (queue URLs, bucket names, user pool IDs) is passed as Lambda environment variables by Terraform.
- Repository secret scanning and push protection are enabled.
- When a real secret becomes necessary (for example, MakeShop API credentials for external sync), it is stored in AWS Secrets Manager or Systems Manager Parameter Store (SecureString), accessed by IAM role, and recorded in a new ADR. Per-tenant third-party tokens get a dedicated design at that time.

## Alternatives considered

- **API keys in environment variables or GitHub secrets.** Common and simple; exactly the practice this project avoids.

## Consequences

- Nothing to rotate, and nothing long-lived to leak.
- Least-privilege IAM becomes the primary security control; IAM policies are reviewed in pull requests like code.
