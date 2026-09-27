# 0009. Kubernetes as a tested deployment target, not the production platform (Demo and Client-ready tracks)

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

Kubernetes skills are in demand for system engineering roles, and demonstrating them is a portfolio goal. But the EKS control plane alone costs $0.10 per cluster per hour (~$73/month), far above the ¥5,000 Demo budget (ADR 0008), and the platform's scale does not need Kubernetes in production.

## Decision

- Package the application as container images from day one.
- Maintain Kubernetes manifests or a Helm chart in the repository.
- **Test them in CI** against a throwaway local cluster created inside the CI job (for example, kind), deployed and smoke-tested on every relevant change.
- Provide a Terraform configuration for an **ephemeral EKS environment**: create, deploy, demonstrate, destroy. Used for demos and recordings; expected cost is cents to low dollars per session.
- Production runs on a lower-cost platform chosen in step 5.

## Alternatives considered

- **EKS in production.** Best resume signal, but breaks the cost ceiling and adds operational weight the product does not need.
- **No Kubernetes at all.** Cheapest, but gives up a portfolio goal.

## Consequences

- The same container images must run on both the production platform and Kubernetes, which enforces good twelve-factor habits (config from environment, stateless processes, health endpoints).
- CI takes longer when Kubernetes tests run; limit them to relevant changes or main-branch merges.
- The ephemeral EKS configuration must reliably destroy everything it creates; forgotten clusters are a budget risk. Budget alerts are the safety net.
- Revisit in the Growth track if workloads or team size justify an always-on cluster.
