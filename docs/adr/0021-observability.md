# 0021. Observability: structured logs, EMF metrics, OpenTelemetry tracing

- **Status:** Accepted
- **Date:** 2026-09-26

## Context

NFR 7 requires structured logs, metrics, traces, SLO dashboards, symptom-based alarms, and checks from outside AWS, within the ¥5,000 ceiling. CloudWatch's free tier includes 10 custom metrics, 10 standard alarms, 5 GB of logs, and 3 dashboards per month; custom metrics beyond that cost about $0.30 each, and **every unique metric name + dimension combination counts as a separate metric**. The AWS X-Ray SDKs entered maintenance mode on 2026-02-25 and reach end of support on 2027-02-25; AWS recommends OpenTelemetry. Powertools for AWS Lambda's Tracer is built on the X-Ray SDK (OpenTelemetry support in progress).

## Decision

- **Logs:** Powertools Logger, structured JSON. Every line includes `requestId`, `organizationId`, `venueId`; the request ID propagates through SQS messages. Retention: ~14 days (staging), ~30 days (production), set in Terraform.
- **Metrics:** Powertools Metrics (Embedded Metric Format). Custom metrics are **platform-wide only** (no per-organization dimensions): beers published, translation success/failure/latency, snapshot build duration, **publish lag** (owner write → snapshot published, measuring the 30 s freshness target). Per-organization analysis via Logs Insights queries.
- **Tracing:** **OpenTelemetry** SDK in the container image, exporting to AWS X-Ray. Implemented after logs, metrics, and alarms; wiring verified during the walking skeleton.
- **Alarms** (within the free 10): API error rate, API latency, worker errors, DLQ not empty, publish lag above target, CloudFront error rate. Delivered via SNS to email.
- **Dashboards:** one per SLO area, within the free 3.
- **Outside-in checks:** a free external uptime monitor on the production catalog every few minutes; a scheduled GitHub Actions workflow running the Playwright journeys against production hourly. Service chosen at walking-skeleton time.
- **Cost monitoring:** AWS Budgets alerts (ADR 0008) plus a monthly cost review recorded in the repo.

## Alternatives considered

- **X-Ray SDK / Powertools Tracer.** Easiest on Lambda today, but on a path to end of support.
- **Third-party observability SaaS.** Rich features, but external cost and another vendor.
- **Per-organization metric dimensions.** Convenient, but metric count (and cost) grows with every tenant.

## Consequences

- Observability stays within free tiers at Demo scale.
- OpenTelemetry works identically on Lambda and Kubernetes (ADR 0009) and is a transferable skill.
- Tracing arrives later than logs and metrics; incidents in the meantime are debugged from correlated logs.
