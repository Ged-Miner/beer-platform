# 0003. Split Beer (identity) from Listing (commerce)

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

A beer's facts (name, brewery, style, ABV, hops, tasting notes) differ from how it is sold (container, size, price, stock, dates). The same beer can be sold in two sizes, at two venues, or on tap and in the fridge at once.

## Decision

- **Beer** holds identity: what the brewery made.
- **Listing** holds commerce: how one venue offers that beer.
- One Beer can have many Listings.

## Alternatives considered

- **Single flat product record.** Simpler for the MVP, but blocks multiple sizes, multiple venues, tap-plus-bottle, and any future shared beer database without a data migration.

## Consequences

- The "Add beer" flow creates or finds a Beer, then creates a Listing. The UI should hide this for the common case (one beer, one listing).
- Filters combine Beer fields (style, ABV, brewery) with Listing fields (price, stock, freshness), so queries join both.
- Enables the bar tap list, multiple venues, and a shared beer database later without restructuring.
