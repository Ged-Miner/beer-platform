# 0004. Organization as tenant, Venue as location/channel

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

"Shop" is ambiguous. One business may operate an online store and a physical shop (Chouseiya does), a brewery may have a taproom, and a future distributor may have several channels. Beers should not be entered twice by the same business.

## Decision

- **Organization** is the tenant: the account, the billing unit, and the boundary of data isolation. Organizations own Breweries and Beers.
- **Venue** is a place or channel that belongs to one organization and owns Listings.
- In the MVP, signup creates one organization with one venue automatically; the UI does not expose venues.
- Beers are organization-owned (not shared between organizations) in the MVP. A shared cross-organization beer database is a possible later feature, made feasible by provenance (ADR 0001).
- Styles are shared, platform-managed data.

## Alternatives considered

- **Shop as a single location and tenant.** Simpler, but multi-location businesses would duplicate beers, and adding a parent level later means migrating every tenant-scoped record.
- **Globally shared beers from day one.** Enables network effects, but one organization's edits could affect another's catalog, and it needs moderation.

## Consequences

- Every tenant-scoped query must be scoped by organization. This must be enforced systematically (not left to each query author) and tested; the mechanism is decided in step 5.
- Multi-venue support becomes a UI feature later, not a schema change.
