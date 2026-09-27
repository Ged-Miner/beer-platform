# 0001. Source-aware data model from day one

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

The MVP is standalone: owners enter beers manually. But likely customers already run stores on platforms such as MakeShop and Color Me Shop, and will not enter every product twice. Later we will import from those systems, where the external store owns price and stock while this platform owns enrichment (structured facets, normalized styles, translations, freshness).

## Decision

Treat manual entry as the **first source**, not the only one:

- Beers and Listings record a `source` (`manual` in the MVP) and an optional external ID.
- Key fields record provenance: whether the value came from the owner, the AI, or an external system, and when.
- The idea of field ownership (which system is authoritative for a field) exists in the design, even though the owner owns everything in the MVP.

## Alternatives considered

- **Assume all data is owner-entered, add sync later.** Simpler now, but sync would require retrofitting provenance onto existing data and code paths.

## Consequences

- Small extra design and storage cost in the MVP.
- External sync adapters (MakeShop, Color Me Shop) become an additive milestone rather than a rewrite.
- Provenance also supports debugging and owner trust ("the AI didn't change that, you did").
