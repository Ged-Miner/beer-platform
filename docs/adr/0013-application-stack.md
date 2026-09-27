# 0013. TypeScript application stack

- **Status:** Accepted
- **Date:** 2026-09-24

## Context

The developer works in TypeScript and Node.js. The DevOps practice is the primary goal, so the application stack should be modern, well supported, and familiar enough not to dominate the learning effort. The architecture requires a portable HTTP server (ADR 0012) and a typed public contract (ADR 0010).

## Decision

| Layer | Choice |
| --- | --- |
| Repository | pnpm workspaces monorepo: `apps/api`, `apps/worker`, `apps/owner`, `apps/catalog`, `packages/shared`, `packages/db`, `infra/`, `deploy/k8s/`, `docs/` |
| Supply chain | pnpm minimum release age for dependencies; lockfile committed; automated dependency updates |
| Runtime | Node.js 24 (Active LTS) in container images; planned upgrade to Node.js 26 after it enters Active LTS (October 2026), recorded as its own ADR |
| Language | TypeScript, strict mode |
| API framework | Hono (v4.12 line) with `@hono/node-server`; `@hono/zod-openapi` for validation and generated OpenAPI docs; Hono RPC client for the owner app |
| Contracts | Zod schemas in `packages/shared`, used by the owner app, the API, and the published snapshot format |
| Frontend | React single-page apps built with Vite 8, deployed as static files; owner app as an installable PWA; per-shop themes as CSS variables from the snapshot |
| Tests | Vitest (unit/integration); Playwright (end-to-end; MVP journeys as post-deploy smoke tests) |
| Infrastructure as code | Terraform (unchanged) |

Exact versions, linting, and formatting tools are pinned during the walking skeleton after checking current releases.

## Alternatives considered

- **Express 5 or Fastify.** Both viable; Hono is smaller, Web Standards based, and TypeScript-first, which suits Lambda cold starts and portability.
- **AWS CDK for infrastructure.** Would keep everything in TypeScript, but Terraform is the tool being adopted at work, is in demand, and is cloud-neutral.
- **Next.js or another SSR framework.** Adds server rendering the architecture deliberately avoids on the read path (ADR 0010).

## Consequences

- One language across the product; shared types catch contract drift at compile time.
- The catalog bundle size must be tracked in CI against the LCP target; a lighter UI library is the fallback if it grows.
- The Node 24 to 26 upgrade becomes a planned, demonstrable operational exercise.
