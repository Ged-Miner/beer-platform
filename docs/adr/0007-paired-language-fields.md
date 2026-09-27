# 0007. Paired language fields for the MVP

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

The MVP supports Japanese and English. Korean and Traditional Chinese are likely future additions given inbound visitor trends.

## Decision

- Store translatable text as paired fields (`name_ja`, `name_en`, `description_ja`, `description_en`) on the relevant records.
- Japanese is the source language; English is AI-drafted and owner-approved.

## Alternatives considered

- **Separate translations table from day one.** Scales to any number of languages, but adds joins and complexity for a two-language MVP.

## Consequences

- Simple queries and forms in the MVP.
- Adding a third language requires a migration to a translations table. This migration is expected and should be done as a planned, zero-downtime schema change (a good operational exercise), recorded in a new ADR.
