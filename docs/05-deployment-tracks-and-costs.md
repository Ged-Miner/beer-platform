# Deployment Tracks and Cost Model

> Status: Draft. Prices checked 2026-09-23; **revised 2026-09-24** after the architecture decisions in ADRs 0010–0012 (Aurora DSQL, no VPC). All estimates are **rough**: recalculate with the AWS Pricing Calculator once the walking skeleton gives real usage numbers. Amounts in USD, Tokyo region, on-demand, before Japanese consumption tax (10%) unless noted.

This document describes how the platform's infrastructure and costs change as it moves from a portfolio demo to a product serving paying clients, and provides a framework for a client price sheet.

## The three tracks

| | **A. Demo** | **B. Client-ready** | **C. Growth** |
| --- | --- | --- | --- |
| Purpose | Portfolio, job hunting, demo to prospects | First 1–10 paying organizations | 10–50 organizations, contractual SLA |
| Budget | ≤ ¥5,000/month incl. tax | Covered by client revenue | Covered by client revenue |
| Database | Aurora DSQL, mostly within free tier | Aurora DSQL, usage-based; cross-Region backup copies | Aurora DSQL; multi-Region cluster only if an SLA requires it |
| Staging | Always on, near-zero idle cost (ADR 0019) | Always on | Always on, separate AWS account |
| CDN plan | CloudFront flat-rate Free | CloudFront flat-rate Pro | Pro, or Business for bot management |
| AWS accounts | Organizations: management account + one workload account (ADR 0024) | Same, strict tagging | Separate staging and production accounts |
| Observability | AWS-native, short retention | Longer retention, uptime monitoring | Longer retention, paging/on-call tool |
| Kubernetes | CI (kind) + ephemeral EKS for demos | Same | Re-evaluate if team or workloads grow |
| Commitment to client | None | Internal SLOs, best-effort support hours | Contractual SLA, defined support |

## What changes between tracks, and why

### Database: Aurora DSQL (revised, see ADR 0011)

- Originally planned as RDS PostgreSQL (db.t4g.micro ≈ $18/month single-AZ in Tokyo; db.t4g.small Multi-AZ ≈ $74/month). Replaced by Aurora DSQL.
- DSQL is serverless and scales to zero: no charge for compute when idle. Free tier each month: 100,000 DPUs and 1 GB storage. Beyond that (US East list price): $8 per million DPUs and $0.33 per GB-month. **Confirm Tokyo pricing before quoting a client.**
- Data is replicated across three Availability Zones at the price of one logical copy, so the Growth track no longer needs a separate Multi-AZ upgrade.
- Demo: expected to stay mostly within the free tier.
- Client-ready and Growth: cost scales with owner activity and snapshot rebuilds, not with customer catalog traffic (customers read snapshots from S3; ADR 0010). Measure DPU usage per organization during the pilot to refine these numbers.
- Multi-Region clusters bill replicated writes and storage in each Region; only worth it for a contractual SLA that demands it.

### CDN, WAF, and DNS: flat-rate plans

- CloudFront flat-rate plans (launched November 2025) bundle CDN, AWS WAF, DDoS protection, Route 53 DNS, a TLS certificate, CloudWatch Logs ingestion, and S3 storage credits, with no overage charges.
- **Free ($0): 1M requests, 100 GB transfer. Pro ($15): 10M requests, 50 TB.** Business ($200) and Premium ($1,000) are beyond this project's needs.
- Rough sizing: one catalog visit is roughly 10–20 requests (HTML, scripts, styles, images, API calls), so the Free plan covers roughly 50,000–100,000 visits per month across all tenants. Enough for the Demo track, likely not for 10 active shops, hence Pro in the Client-ready track.
- When allowances are exceeded, AWS reduces performance rather than charging overages. Useful for the Demo budget; unacceptable for paying clients, which is another reason for Pro.
- **Multi-tenant constraint:** one plan covers one distribution with one apex domain. Subdomains under the platform's own domain (`shopname.platform.jp`) share one plan. **A client's own custom domain needs its own distribution and plan**, which makes custom domains a natural paid add-on (see price sheet).

### Networking: the NAT Gateway trap, resolved

- A NAT Gateway bills from the first hour with no free tier (about $0.045/hour plus $0.045/GB in us-east-1; varies by region), and every public IPv4 address costs $0.005/hour (~$3.60/month).
- **Resolved by design (ADRs 0011, 0012):** because Aurora DSQL authenticates with IAM tokens, no component needs to run inside a VPC. There is no VPC, NAT Gateway, load balancer, or interface endpoint in any track. The worker calls the AI provider directly.
- If a client later requires private connectivity to the database, PrivateLink can be added as a priced option.

### Compute

- Demo and Client-ready: on-demand compute with no idle cost (specific service chosen in step 5). Expected to be near zero in the Demo track and single-digit to low-double-digit dollars in the Client-ready track.
- Kubernetes (EKS) costs $0.10 per cluster per hour (~$73/month) for the control plane alone, before nodes, so it is not a production option in tracks A or B. See ADR 0009.

### AI (translation, later recommender)

- Cost formula: `beers added per month × tokens per translation × provider price per token`.
- Provider: Claude on Amazon Bedrock, Japan inference profile (ADR 0020). Haiku 4.5 list price $1 / $5 per million input/output tokens, plus ~10% for geographic endpoints.
- Estimate: ~800 input + ~300 output tokens per translation ≈ ¥0.4 per beer; at 30 new beers per week, **≈ ¥50 per organization per month**. Must be measured during the pilot.
- The recommender (post-MVP) scales with customer traffic, not owner activity. It needs its own cost model and per-organization limits before launch.

### Other small costs

Secrets storage, log ingestion and retention, S3 storage for images, domain name registration (annual). Each is small; together a few dollars per month. Log retention is the one to watch as traffic grows.

## Rough monthly estimates

These are planning figures, not quotes.

| Item | A. Demo | B. Client-ready | C. Growth |
| --- | --- | --- | --- |
| Database (Aurora DSQL) | ~$0–2 | ~$10–25 | ~$25–60 |
| CDN/WAF/DNS plan | $0 | $15 | $15 (or $200 for Business) |
| Compute (Lambda, SQS) | ~$0–3 | ~$5–15 | ~$20–40 |
| Observability and logs | ~$1–3 | ~$5–10 | ~$20–40 (incl. paging tool) |
| Staging | ~$0–2 | ~$3–10 | ~$10–25 |
| Backups, secrets, storage, misc. | ~$2–4 | ~$5–10 | ~$10–20 |
| AI (Bedrock) | ~$0–1 | ~$1–5 | ~$5–15 |
| Auth (Cognito Essentials, SES email) | $0 (free tier) | ~$0–1 | ~$0–2 |
| **Estimated total (USD)** | **~$3–15** | **~$44–91** | **~$105–217** |
| **Approx. JPY incl. 10% tax** | **~¥500–2,500** | **~¥7,500–15,500** | **~¥18,000–37,000** |

The Demo track now sits well under the ¥5,000 ceiling. The headroom can fund a domain name, longer log retention, or occasional ephemeral EKS demos (ADR 0009). Budget alerts still enforce the ceiling.

## Unit economics

- Most infrastructure cost is **fixed and shared** across tenants (database, CDN plan, staging, observability). The **marginal cost of one more tenant** is small: storage, a share of compute, AI translations, and optionally a custom-domain distribution.
- At roughly ¥7,500–15,500/month for the Client-ready track, two or three clients paying ¥5,000/month cover infrastructure. That does **not** cover your time, which is the real cost: onboarding, support, maintenance, and upgrades.
- Price by value and time, not by infrastructure cost.

## Price sheet framework (hypotheses to validate)

> Not financial or tax advice. All prices below are hypotheses to test with real prospects (Chouseiya first), not recommendations.

### Market anchor

Untappd for Business (US) lists Essentials at $899/year and Premium at $1,199/year per location (checked earlier in the project). That is roughly ¥11,500–15,500 per month at current rates. Japanese small shops will likely be more price-sensitive, and a new product without a track record should price below established competitors.

### Structure

| Component | What it covers | Hypothesis |
| --- | --- | --- |
| **Setup fee** (one-time) | Onboarding, initial catalog import, theme setup, QR materials | ¥30,000–80,000 depending on catalog size |
| **Starter** (monthly) | 1 venue, JA/EN catalog, filters, QR menu, AI translation | ¥3,000–5,000 |
| **Standard** (monthly) | Starter + external store sync (MakeShop/Color Me Shop), social images | ¥8,000–12,000 |
| **Pro** (monthly) | Standard + recommender, custom domain, extra languages, priority support | ¥15,000–20,000 |
| **Add-on: custom domain** | Dedicated CDN distribution and plan (pass-through cost + management) | Cost + margin |
| **Add-on: extra venue** | Additional bar/shop/taproom | Per venue |
| **Custom design work** | Bespoke theme or site design (freelance) | Project or hourly rate |

### Before quoting anyone

- Define support hours and response times per tier, and do not promise an SLA the Client-ready infrastructure cannot meet.
- Decide annual vs monthly billing (annual prepayment improves cash flow and reduces churn).
- Japan's qualified invoice system (インボイス制度) affects whether business clients can claim consumption tax credits on your invoices. Decide whether to register as a qualified invoice issuer; consult a tax advisor.
- Include AI usage limits per tier once AI costs are measured (recommender especially).

## Sources (checked 2026-09-23)

| Topic | Source |
| --- | --- |
| AWS Free Tier (credits, Free vs Paid plan) | https://aws.amazon.com/about-aws/whats-new/2025/07/aws-free-tier-credits-month-free-plan/ |
| CloudFront flat-rate plans | https://aws.amazon.com/cloudfront/pricing/ , https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/flat-rate-pricing-plan.html |
| Flat-rate plan allowances | https://docs.aws.amazon.com/de_de/PricingPlanManager/latest/UserGuide/plans.html |
| One apex domain per plan (multi-tenant note) | https://www.duckbillhq.com/blog/the-complete-guide-to-cloudfronts-flat-rate-pricing/ |
| RDS db.t4g.micro / small regional prices | https://www.bytebase.com/dbcost/rds/instance/db.t4g.micro/ , https://www.bytebase.com/dbcost/rds/instance/db.t4g.small/ |
| RDS Multi-AZ Tokyo hourly | https://sparecores.com/database/aws/db.t4g.small |
| RDS PostgreSQL pricing (CPU credits) | https://aws.amazon.com/rds/postgresql/pricing |
| Aurora DSQL pricing and free tier | https://aws.amazon.com/rds/aurora/dsql/pricing/ |
| Aurora DSQL Regions (incl. Tokyo) | https://aws.amazon.com/about-aws/whats-new/2026/02/amazon-aurora-dsql-additional-aws-regions |
| Aurora DSQL foreign keys (2026-08-26) | https://aws.amazon.com/about-aws/whats-new/2026/08/aurora-dsql-foreign-key-constraints/ |
| Aurora Serverless v2 auto-pause | https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-auto-pause.html |
| NAT Gateway, public IPv4, EKS pricing | https://computingforgeeks.com/aws-costs-explained-real-numbers/ , https://costgoat.com/pricing/aws-nat-gateway |
| JPY/USD rate | https://www.murc-kawasesouba.jp/fx/past/index.php?id=260910 |

Always confirm against official AWS pricing pages before quoting a client.
