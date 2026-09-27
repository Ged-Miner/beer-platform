# 0012. Serverless compute on Lambda container images, with no VPC

- **Status:** Accepted
- **Date:** 2026-09-24

## Context

The Demo track forbids idle fixed costs (ADR 0008). ADR 0009 requires the same container image to run in production and on Kubernetes. With Aurora DSQL (ADR 0011), no component needs to be inside a VPC.

## Decision

- **API:** a Hono application on `@hono/node-server`, packaged as a container image with the **AWS Lambda Web Adapter**, deployed to Lambda and fronted by CloudFront. The same image runs locally, in CI, and on Kubernetes.
- **Background work:** the API enqueues jobs on **SQS** (translate a beer, rebuild a venue snapshot). A **worker** Lambda consumes the queue, calls the AI provider directly over the internet, writes results to DSQL, and publishes snapshots to S3.
- **Static apps and snapshots:** S3 behind CloudFront (flat-rate Free plan in the Demo track).
- **No VPC, NAT Gateway, load balancer, or interface endpoints.**
- Container images stored in ECR. arm64 preferred where dependencies allow (lower Lambda price per GB-second); confirm during the walking skeleton.

## Alternatives considered

- **ECS Fargate behind an Application Load Balancer.** Always-on cost (load balancer plus tasks) and usually NAT for egress; too expensive for the Demo track.
- **Lambda zip packages with a native Hono Lambda handler.** Slightly faster cold starts, but breaks the "one image everywhere" requirement from ADR 0009.
- **Single small EC2 instance.** Cheap, but a fixed cost, manual patching, and a single point of failure.

## Consequences

- Near-zero compute cost at Demo traffic; costs scale with use.
- Cold starts on the owner API are possible; measure against the p95 targets and consider provisioned concurrency only if needed (it has a fixed cost).
- ADR 0006 (AI never blocks publishing) is implemented structurally: the API returns after the DSQL write and enqueue; AI work happens in the worker.
- Failed jobs go to a dead-letter queue with an alarm and a runbook.
- Lambda-to-DSQL traffic travels over the public AWS network with TLS and IAM authentication, by design. PrivateLink can be added later if a client requires it.
