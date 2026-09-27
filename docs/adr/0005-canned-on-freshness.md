# 0005. Canned-on date as the basis of freshness

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

Freshness matters to craft beer customers, especially for hop-forward styles. Two dates may be available: canned-on (or bottled-on) and best-before. Best-before is a brewery policy, not a measurement: Japanese beer commonly carries around nine months, some large brewers use twelve, and many craft brewers set much shorter windows. Two beers canned the same day can therefore carry very different best-before dates. Some shops (for example, Chouseiya) publish only best-before dates, mainly on sale items.

## Decision

- Store both dates on the Listing; both are optional.
- **Canned-on is the basis of freshness:** displayed as "canned N days ago" and used for freshness filters ("canned within N days").
- When only best-before exists, display "N days remaining" and exclude the listing from canned-on filters rather than estimating a canned-on date.

## Alternatives considered

- **Best-before only.** Matches some shops' current data, but is not comparable across breweries.
- **Estimate canned-on from best-before.** Would require guessing each brewery's policy; presents a guess as a fact.

## Consequences

- Freshness filters are honest but only cover listings with a canned-on date. The UI should encourage owners to enter it.
- Canned-on is batch-level data; if restocks of different batches become common, introduce a Batch entity (new ADR).
