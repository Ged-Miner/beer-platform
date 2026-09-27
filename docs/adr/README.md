# Architecture Decision Records

Each ADR records one significant decision: the context, the decision, and its consequences. ADRs are never edited after acceptance; a changed decision gets a new ADR that supersedes the old one.

| # | Title | Status |
| --- | --- | --- |
| [0001](0001-source-aware-data-model.md) | Source-aware data model from day one | Accepted |
| [0002](0002-standalone-catalog-on-public-read-api.md) | Standalone catalog built on a public read API | Accepted |
| [0003](0003-split-beer-and-listing.md) | Split Beer (identity) from Listing (commerce) | Accepted |
| [0004](0004-organization-and-venue-tenancy.md) | Organization as tenant, Venue as location/channel | Accepted |
| [0005](0005-canned-on-freshness.md) | Canned-on date as the basis of freshness | Accepted |
| [0006](0006-ai-never-blocks-publishing.md) | AI is never in the critical path of publishing | Accepted |
| [0007](0007-paired-language-fields.md) | Paired language fields for the MVP | Accepted |
| [0008](0008-cost-ceiling-and-no-idle-cost.md) | ¥5,000 monthly cost ceiling and a no-idle-cost architecture | Accepted (database bullet superseded by 0011; staging bullet by 0019) |
| [0009](0009-kubernetes-off-production.md) | Kubernetes as a tested deployment target, not the production platform | Accepted |
| [0010](0010-published-catalog-snapshots.md) | Published catalog snapshots as the public read path | Accepted |
| [0011](0011-aurora-dsql.md) | Aurora DSQL as the primary database | Accepted |
| [0012](0012-serverless-compute-no-vpc.md) | Serverless compute on Lambda container images, with no VPC | Accepted |
| [0013](0013-application-stack.md) | TypeScript application stack | Accepted |
| [0014](0014-data-access-and-migrations.md) | Data access with Drizzle and a DSQL-aware migration runner | Accepted |
| [0015](0015-ci-cd-with-github-actions.md) | CI/CD with GitHub Actions: build once, promote by digest | Accepted |
| [0016](0016-keyless-aws-auth-oidc.md) | Keyless AWS authentication from CI via GitHub OIDC | Accepted |
| [0017](0017-terraform-structure-and-state.md) | Terraform structure and state | Accepted |
| [0018](0018-app-releases-separate-from-terraform.md) | Application releases separate from Terraform | Accepted |
| [0019](0019-always-on-staging.md) | Always-on staging | Accepted |
| [0020](0020-ai-provider-claude-on-bedrock.md) | AI provider: Claude on Amazon Bedrock, behind a provider interface | Accepted |
| [0021](0021-observability.md) | Observability: structured logs, EMF metrics, OpenTelemetry tracing | Accepted |
| [0022](0022-owner-authentication-cognito.md) | Owner authentication: Amazon Cognito with passwordless sign-in | Accepted |
| [0023](0023-no-stored-secrets.md) | No stored secrets in the MVP | Accepted |
| [0024](0024-aws-account-structure.md) | AWS account structure: Organizations with a separate workload account | Accepted |

Template: [template.md](template.md)
