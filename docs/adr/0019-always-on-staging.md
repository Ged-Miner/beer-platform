# 0019. Always-on staging

- **Status:** Accepted
- **Date:** 2026-09-25
- **Supersedes:** the "staging is ephemeral" bullet of ADR 0008

## Context

Staging was planned as ephemeral (created and destroyed with Terraform) to avoid idle costs under the ¥5,000 ceiling. After ADRs 0011 and 0012, the architecture has no idle fixed costs: no VPC, NAT Gateway, or load balancer; Lambda and Aurora DSQL scale to zero.

## Decision

- Staging stays up permanently and receives every merge to `main` (ADR 0015).
- Staging mirrors production's modules with smaller limits and separate data.
- Confirm during the walking skeleton how many CloudFront flat-rate Free plans one account can hold; if only one, staging uses standard pay-as-you-go CloudFront pricing (negligible at staging traffic).

## Alternatives considered

- **Ephemeral staging per deploy.** Near-zero savings now, but adds minutes to every pipeline run and more moving parts.

## Consequences

- Simpler, faster pipeline; staging is always available for demos and manual checks.
- Staging costs are monitored like production's, with the same budget alerts.
- Per-pull-request preview environments become an optional stretch goal.
