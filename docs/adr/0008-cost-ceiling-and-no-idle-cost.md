# 0008. ¥5,000 monthly cost ceiling and a no-idle-cost architecture

- **Status:** Accepted (database bullet superseded by ADR 0011; staging bullet superseded by ADR 0019)
- **Date:** 2026-09-23

## Context

The project is self-funded during a job search. The maximum acceptable spend for the Demo track is ¥5,000 per month including consumption tax (~$29 of AWS usage at ~154 JPY/USD). Many standard AWS setups carry fixed costs that run with zero traffic: an EKS control plane (~$73/month), a NAT Gateway (~$32+/month before data charges), an Application Load Balancer (~$16/month plus usage), and $3.60/month per public IPv4 address. Any one of the first two exceeds the entire budget.

## Decision

- The Demo track must cost **≤ ¥5,000/month including tax**, enforced by AWS Budgets alerts at 50%, 80%, and 100%.
- **No idle fixed costs** beyond the database: no always-on NAT Gateway, load balancer, or Kubernetes control plane.
- Serve the customer catalog through CloudFront on the flat-rate Free plan; use on-demand compute for the API and background jobs.
- The database is the one accepted fixed cost: smallest suitable instance, single-AZ.
- Staging is ephemeral, created and destroyed with Terraform.
- Infrastructure changes for paying clients are planned in [05-deployment-tracks-and-costs.md](../05-deployment-tracks-and-costs.md), not built in the Demo track.

## Alternatives considered

- **Container service behind a load balancer with NAT (common tutorial setup).** Well understood, but the fixed networking costs alone consume the budget.
- **EKS in production.** Strong resume value, but ~$73/month before nodes. Addressed separately in ADR 0009.
- **Multi-AZ database.** Roughly doubles database cost; deferred to the Growth track.

## Consequences

- Architecture choices in step 5 must be justified against this ceiling, which makes cost a first-class design input (a FinOps practice worth demonstrating).
- Private networking needs care: components that call external APIs (the AI provider) cannot rely on a NAT Gateway. Resolved in step 5.
- Single-AZ database accepted; the 4-hour RTO and stale-serving CDN cover the risk for a demo.
- If paying clients arrive, moving to the Client-ready track is a planned, documented change funded by revenue.
