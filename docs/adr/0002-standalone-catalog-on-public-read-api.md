# 0002. Standalone catalog built on a public read API

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

Customers need a catalog page. Some businesses have no website at all; others (like existing online stores) will eventually want the catalog embedded in their own pages.

## Decision

- The MVP customer catalog is a **standalone page** on this platform, one per venue, linked from the shop's site, social profiles, and QR codes.
- The catalog gets its data from a **public read API** (published listings, filtered), not by querying the database directly.
- An embedded widget is a planned later client of the same API.

## Alternatives considered

- **Embedded widget first.** Fits existing stores better, but requires cross-origin handling, style isolation, and host-page constraints before the core product works, and doesn't serve shops without a site.
- **Catalog pages query the database directly.** Faster to start, but the embed would require building the data layer twice.

## Consequences

- The API is the natural place for caching, rate limiting, and tenant scoping of public data.
- Each venue needs its own catalog address and basic theming (see Journey 0).
- The embed later means adding a small script, CORS configuration, and styling isolation, not a second backend.
