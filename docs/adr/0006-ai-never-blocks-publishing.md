# 0006. AI is never in the critical path of publishing

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

The MVP uses an LLM to draft English names and descriptions. External AI services can be slow, rate-limited, down, or produce poor output, and they cost money per call.

## Decision

- Saving a beer publishes it immediately with the owner's Japanese data.
- Translation runs asynchronously after save, and retries on failure.
- AI output is a **draft** until the owner approves it (tracked by `english_status` on Beer).
- AI output is recorded with provenance `ai`.

## Alternatives considered

- **Translate synchronously during save.** Simpler, but an AI outage or slow response would block the owner's core workflow.

## Consequences

- Requires a background job mechanism with retries (a useful operational component to demonstrate).
- The catalog must handle beers with missing or unapproved English gracefully.
- AI cost and latency should be measured and monitored per organization.
- The same principle applies to future AI features (label extraction, recommender): they assist, and the system works without them.
