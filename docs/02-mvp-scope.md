# MVP Scope

## Goals

1. Demonstrate DevOps and system engineering practice end to end on a working product.
2. Produce a demo that a real shop owner would understand in seconds: their beers, structured, filterable, and bilingual.

## In scope

| Area | Includes |
| --- | --- |
| Onboarding (Journey 0) | Signup, auto-created organization and venue, shop name, logo, colors, catalog address, QR code |
| Add a beer (Journey 1) | Manual entry form, controlled style list, brewery records, AI English translation with owner approval |
| Customer catalog (Journey 2) | Standalone public catalog, combinable filters, Japanese/English, freshness display, mobile-first |
| Stock updates (Journey 3) | One-tap status changes, immediate catalog update, undo via activity log |
| Platform | Multi-tenant data isolation, public read API consumed by the catalog, field provenance, activity log |

## Deferred (rough order)

1. External sync adapters (MakeShop first, via its GraphQL API; then Color Me Shop)
2. AI recommender
3. Bar tap list, TV board, printable menu
4. Social image generator
5. Embedded catalog widget
6. Label photo extraction
7. Translations table and additional languages (Korean and Traditional Chinese are the likely first additions, based on 2026 inbound visitor trends)
8. Shared cross-organization beer database

## Explicitly out of scope

- **Payments and alcohol sales.** The platform displays catalogs; checkout stays in the shop's existing store. This avoids payment compliance and Japanese liquor mail-order licensing concerns.
- Native mobile apps. The owner app is a mobile web app.
- LINE integration (revisit after MVP).

## Principles

- **Beat the chalkboard.** Owner actions must be faster than the manual alternative.
- **AI assists, never blocks.** Publishing never depends on an AI service being available (ADR 0006).
- **Design for sources from day one**, even though manual entry is the only source in the MVP (ADR 0001).
- **Every stack decision traces to a requirement.** Recorded as an ADR.

## MVP success criteria

- An owner can onboard, add 20 beers, and share a working catalog without help.
- Adding a beer takes under a minute; a stock change takes under five seconds.
- A customer reaches a specific beer in three or four taps, in either language.
- The system is deployed through an automated pipeline with infrastructure as code, monitoring, and tested backups. (Specific targets defined in step 4, non-functional requirements.)

## Demo plan for Chouseiya

A one-time import of a sample of their catalog into a private prototype, shown as a before-and-after: their current listing format beside the structured, filterable, bilingual version. Public demos and the portfolio use invented sample data unless the owner gives permission.
