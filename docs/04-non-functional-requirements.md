# Non-Functional Requirements

> Status: Draft for MVP. Targets apply to the **Demo track** unless stated otherwise. See [05-deployment-tracks-and-costs.md](05-deployment-tracks-and-costs.md) for how targets and infrastructure change for paying clients.

Every requirement here should be measurable: a monitored SLO, an automated test, or a pipeline check.

## 1. Scale assumptions (year one)

- Up to ~50 organizations, 1–2 venues each.
- Up to ~2,000 listings per organization, a few hundred active (reference: Chouseiya has ~1,350 lifetime products, ~350 active).
- Hundreds to low thousands of catalog views per venue per day.
- Must handle 10x this without re-architecture. Does not need to handle 100x.

## 2. Availability and reliability

| Path | SLO (monthly) | Allowed downtime |
| --- | --- | --- |
| Public catalog (read) | 99.9% | ~43 min |
| Owner app (write) | 99.5% | ~3.6 hours |

- The public catalog keeps serving the last known data when the backend is down (CDN serves stale content on origin errors). A backend outage should look like a slightly stale menu, not a broken one.
- These are internal **SLOs**, not contractual SLAs. Contractual commitments are defined per track (see doc 05).

## 3. Performance

- Catalog pages meet Google's "good" Core Web Vitals threshold: Largest Contentful Paint under 2.5 s on a mid-range phone over mobile data.
- p95 filtered catalog API latency under 300 ms. (Revisit in step 5 once cold-start behavior of the chosen compute is measured.)
- Owner actions (save a beer, change status) complete in under 1 s from the owner's point of view.
- A stock change is visible in the public catalog within **30 seconds**. Deliberate trade-off: keeps caching simple while still far faster than a chalkboard.

## 4. Data durability and recovery

- **RPO:** at most 1 hour (point-in-time recovery).
- **RTO:** at most 4 hours for a full restore.
- **Backups are tested:** a scheduled automated job restores the latest backup into a scratch environment, runs checks, and destroys it. Results are recorded.
- Aurora DSQL replicates data across three Availability Zones in every track (ADR 0011). Backups through AWS Backup; restores create a new cluster, which the automated restore test uses.

## 5. Security and privacy

- **Tenant isolation is enforced systematically and tested:** automated tests prove an organization cannot read or modify another organization's data.
- No secrets in the repository; secrets come from a managed secrets store.
- Least-privilege IAM for every component, including CI. CI authenticates to AWS without long-lived access keys.
- TLS everywhere. Dependency and container image scanning in CI.
- Minimal personal data: owner/staff emails only; customers browse anonymously. Keeps APPI (Japan's personal information law) obligations light.
- Hosted in the Tokyo region (ap-northeast-1) for latency and a simple data residency story.
- Owners sign in with Cognito passwordless login (passkeys, email codes) (ADR 0022).
- No stored secrets in the MVP; every connection authenticates by identity (ADR 0023).

## 6. Delivery

- Every change goes through a pull request with automated tests.
- Merge to main deploys automatically to staging; production is a promotion of the same tested artifact.
- Zero-downtime deploys. Rollback in under 10 minutes.
- **All infrastructure is defined in Terraform.** No manual console changes. Environments are reproducible from code.
- The application is packaged as a container image (portable across compute platforms, see ADR 0009).

## 7. Observability

- Structured logs, metrics, and traces (OpenTelemetry) from every component (ADR 0021).
- One dashboard per SLO. Alerts on user-visible symptoms (error rate, latency, SLO burn), not on every resource metric.
- Synthetic check loading a demo catalog every few minutes, from outside AWS.
- AI metrics: translation calls, failures, and latency (platform-wide metrics); cost and usage per organization via log queries, not per-organization metric dimensions.
- Log retention kept short in the Demo track to control cost.

## 8. Cost

- **Demo track ceiling: ¥5,000 per month, including consumption tax** (~$29 of usage at ~154 JPY/USD, September 2026). See ADR 0008.
- AWS Budgets alerts at 50%, 80%, and 100% of the ceiling; forecast alert at 100%.
- Cost Anomaly Detection: AWS-managed linked-account monitor in the management account, daily summary, absolute threshold of $5 (percentage thresholds cannot fire while expected spend is zero).
- Cost-allocation tags on every resource (environment, component).
- No idle fixed costs: no VPC, NAT Gateway, load balancer, or Kubernetes control plane in the Demo track (ADRs 0011, 0012).
- Staging is always on (ADR 0019); with no idle fixed costs its cost is near zero when unused.
- Cost is a monitored metric, reviewed monthly and recorded in the repo.

## 9. Maintainability

- ADRs for every significant decision.
- Runbooks for predictable incidents: restore the database, AI provider outage, bad deploy, budget alert fired.

## 10. Accessibility and localization

- Japanese and English throughout the customer catalog and owner app.
- Customer catalog aims for WCAG 2.2 AA (contrast, tap targets, screen reader labels).
