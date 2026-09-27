# 0024. AWS account structure: Organizations with a separate workload account

- **Status:** Accepted
- **Date:** 2026-09-26

## Context

The project runs in a personal, paid AWS account (no free credits). AWS guidance is that humans sign in through federation with temporary credentials and that the root user is kept for root-only tasks. IAM Identity Center can grant access to AWS accounts only through an organization instance (AWS Organizations); an account instance manages access to applications only. Doc 05 originally assumed a single account for the Demo and Client-ready tracks.

## Decision

- Enable **AWS Organizations**. The existing account is the **management account**: billing, budgets, Cost Anomaly Detection, and IAM Identity Center only. No project resources are deployed there.
- Create one **workload account** for the project, holding both staging and production (consistent with ADR 0019).
- **IAM Identity Center** organization instance in Tokyo, with management of AWS account access enabled (optional at instance creation since 2026-08-05). Humans sign in with passkey MFA and use `aws sso login` for CLI credentials. No IAM users, no access keys.
- Root user: passkey MFA, no access keys, used only for root-only tasks.
- CI roles and the Terraform bootstrap (ADRs 0016, 0017) live in the workload account.

## Alternatives considered

- **Single standalone account with an IAM user and `aws login`.** Simpler; still avoids access keys (temporary credentials from console sign-in), but keeps a long-lived IAM user and mixes billing/identity with workloads.
- **Separate staging and production accounts now.** Stronger isolation; deferred to the Growth track to keep setup light.

## Consequences

- The same structure used by companies; directly transferable to workplace practice.
- Billing views and budgets in the management account cover the workload account.
- Permission sets start broad (AdministratorAccess) and are tightened as real needs become clear.
- Splitting staging and production into separate accounts later is an additive change.
