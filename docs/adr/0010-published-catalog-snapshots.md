# 0010. Published catalog snapshots as the public read path

- **Status:** Accepted
- **Date:** 2026-09-24
- **Refines:** ADR 0002

## Context

A venue's catalog is small (a few hundred active listings, ~2,000 at most). The public catalog has the strictest targets: 99.9% availability, LCP under 2.5 s on mobile, stock changes visible within 30 s, and it should keep working when the backend is down. Querying the database on every filter change would put compute and the database on the customer's critical path.

## Decision

- Each venue's published catalog is written as a **versioned JSON snapshot** to S3 and served through CloudFront.
- The browser downloads the snapshot and **filters locally**. Filter state lives in the URL.
- Any write that affects published data enqueues a snapshot rebuild (see ADR 0012).
- Snapshots are served with a short `max-age` plus `stale-while-revalidate` and `stale-if-error`, both of which CloudFront honors.
- The snapshot schema is defined in Zod in `packages/shared` and is **the public read API** from ADR 0002. The embedded widget will consume the same snapshot.

## Alternatives considered

- **Live query API behind the CDN.** Flexible, but every uncached filter combination hits compute and the database, and availability depends on both.
- **Server-side rendering per request.** Better for SEO, but reintroduces compute on the read path.

## Consequences

- The read path depends only on S3 and CloudFront, so the catalog SLO is largely delegated to them.
- Filtering is instant; traffic stays within the CloudFront flat-rate plan allowances.
- Freshness is bounded by rebuild time plus `max-age` (target ≤ 30 s).
- Very large catalogs would need splitting into pages or shards; not needed at 10x current scale.
- Search engines see a client-rendered page. If SEO becomes important, pre-render a static HTML summary per venue during the snapshot build (new ADR).
