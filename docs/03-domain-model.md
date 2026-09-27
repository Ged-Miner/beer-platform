# Domain Model (first pass)

Implementation details (table layout, column types, indexes) are deferred to step 5. This document fixes the concepts and their relationships.

## Entities

### Organization (tenant)

The business that signs up and pays. The unit of data isolation.

- name, default language, theme (logo, colors), plan/status, timestamps

### Venue

A place or channel with listings: online store, bar, taproom, bottle shop. Belongs to one organization. In the MVP each organization has exactly one venue, created automatically, and the UI never mentions venues.

- organization, name, type (online / bar / taproom / shop), catalog address, timestamps

### User

A person who manages an organization's catalog.

- organization, email, role (owner / staff), timestamps

### Style (shared, platform-managed)

The controlled style list, seeded by the platform and shared by all organizations.

- canonical key, name_ja, name_en, family (for example: Pale & IPA, Lager & Pilsner, Dark, Sour & Wild, Belgian & Farmhouse, Wheat, Specialty)
- Seed source to be decided: BJCP or Brewers Association guidelines as a starting point, with a simpler family layer for customers.

### Brewery (organization-owned in MVP)

- organization, name_ja, name_en, country, region/prefecture, website (optional)

### Beer (organization-owned): identity

What the brewery made. Facts that stay the same wherever it is sold.

- organization, brewery, style, name_ja, name_en, ABV, IBU (optional), hops (list, optional), description_ja, description_en, image
- english_status: pending / draft / approved / failed (see Journey 1)

### Listing (venue-owned): commerce

How one venue offers a beer.

- venue, beer, container (can / bottle; draft/keg deferred to tap list), volume_ml, price (tax-inclusive JPY), sale_price (optional), stock_status (in_stock / low / sold_out), published (yes / no), canned_on (optional), best_before (optional), created_at, updated_at

### Supporting concepts

- **Field provenance:** for key fields, where the current value came from (`owner`, `ai`, later `external:makeshop`, `external:colorme`), who or what set it, and when. Storage approach decided in step 5.
- **Activity log:** who changed what and when, per organization. Powers undo in Journey 3 and debugging.
- **Source:** each Beer and Listing records its source (`manual` in the MVP) and an optional external ID for future sync (ADR 0001).

## Relationships

```mermaid
erDiagram
    ORGANIZATION ||--|{ VENUE : has
    ORGANIZATION ||--|{ USER : has
    ORGANIZATION ||--o{ BREWERY : owns
    ORGANIZATION ||--o{ BEER : owns
    BREWERY ||--o{ BEER : brews
    STYLE ||--o{ BEER : classifies
    VENUE ||--o{ LISTING : offers
    BEER ||--o{ LISTING : "is offered as"
```

## Rules

### Tenancy

- Every organization-owned or venue-owned record is visible only within its organization, except published listings, which are public through the read API.
- Styles are the only shared, platform-managed data in the MVP.
- See ADR 0004.

### Freshness

- **Canned-on is the basis of freshness** (ADR 0005). Displayed as "canned N days ago"; filterable as "canned within N days".
- When only best-before exists, display "N days remaining" and do not include the listing in canned-on freshness filters.
- Canned-on is a property of a batch. It lives on Listing for now; a Batch entity is a possible later refinement if restocks become messy.

### Language

- Paired fields (`*_ja`, `*_en`) for the MVP (ADR 0007).
- Japanese is the source language entered by the owner; English is AI-drafted and owner-approved.

## Open questions

- Should breweries become shared platform data (like styles), given that brewery facts don't vary by shop?
- Filters for the MVP: confirm the final facet list.
- Show unreviewed English drafts to customers (labeled) or hide them until approved?
- Conflict handling for simultaneous edits: last write wins, or version checks?
