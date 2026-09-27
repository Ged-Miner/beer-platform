# Craft Beer Catalog Platform: Design Docs

> Working name TBD. Status: **Blueprint phase** (last updated 2026-09-26)

A multi-tenant SaaS for craft beer bottle shops, bars, and breweries in Japan. Owners manage their beer catalog quickly on a phone; customers browse a fast, bilingual, filterable catalog.

The project has two goals:

1. **Portfolio:** demonstrate DevOps and system engineering practice (CI/CD, infrastructure as code, observability, reliability, multi-tenancy) on a real product.
2. **Product:** something craft beer businesses would actually pay for.

## Documents

| Doc | Contents |
| --- | --- |
| [01-user-journeys.md](01-user-journeys.md) | MVP user journeys, plus deferred journeys |
| [02-mvp-scope.md](02-mvp-scope.md) | What is in the MVP, what is deferred, and why |
| [03-domain-model.md](03-domain-model.md) | Entities, relationships, tenancy and freshness rules |
| [04-non-functional-requirements.md](04-non-functional-requirements.md) | SLOs, performance, recovery, security, delivery, observability, cost |
| [05-deployment-tracks-and-costs.md](05-deployment-tracks-and-costs.md) | Demo vs client-ready vs growth infrastructure, cost model, price sheet framework |
| [06-architecture.md](06-architecture.md) | System overview, components, key flows, environments |
| [07-delivery-pipeline.md](07-delivery-pipeline.md) | CI/CD workflows, AWS roles, release and rollback, Terraform layout |
| [adr/](adr/README.md) | Architecture Decision Records |
| [progress-log.md](progress-log.md) | Session-by-session progress and next steps |

## Blueprint process

| Step | Status |
| --- | --- |
| 1. User journeys | Done (MVP journeys drafted) |
| 2. Choose MVP journeys | Done |
| 3. Domain model | Done (first pass) |
| 4. Non-functional requirements | Done (draft) |
| 5. Architecture sketch and stack ADRs | Done (ADRs 0010–0024) |
| 6. Walking skeleton (deploy "hello world" through the full pipeline) | Next (in Claude Code, see `CLAUDE.md`) |

Technology choices are intentionally absent from these docs until step 5. Every stack decision should trace back to a journey or a non-functional requirement.
