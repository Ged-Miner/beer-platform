# 0020. AI provider: Claude on Amazon Bedrock, behind a provider interface

- **Status:** Accepted
- **Date:** 2026-09-26

## Context

The worker translates owner-entered Japanese beer data into English (ADR 0006). Options were Anthropic's API directly (Claude Console, prepaid credits, API key), another provider, or Claude through Amazon Bedrock. A Claude.ai subscription does not include API access; the Console is a separate product.

## Decision

- Call Claude through **Amazon Bedrock** from the worker Lambda, authenticated by the worker's **IAM role** (no API key).
- Use the **Japan geographic cross-Region inference profile** (for Claude Haiku 4.5: `jp.anthropic.claude-haiku-4-5-20251001-v1:0`), which keeps processing in Tokyo and Osaka.
- IAM policy allows invoking only the chosen inference profile and the foundation models it routes to.
- Model choice (Claude Haiku 4.5 vs Claude Sonnet 5 or a successor) is decided by a small evaluation: 20–30 realistic listings, compared for accuracy of beer terminology and naturalness of English. Prompt design is iterated in chat before any API spend.
- All AI access goes through a `TranslationProvider` interface in the worker. Implementations: `BedrockTranslationProvider` (staging, production) and `FakeTranslationProvider` (local development, CI: deterministic, free).
- Output is structured (JSON validated with Zod); invalid output is treated as a failure and retried, never published.

## Alternatives considered

- **Anthropic API directly.** Same models, no geographic premium, but requires storing an API key and managing prepaid credits outside the AWS bill.
- **Global Bedrock endpoint.** Standard price (no 10% premium) but no guarantee processing stays in Japan.
- **Other providers.** Viable; the interface keeps this option open.

## Consequences

- No AI secret to store or rotate (ADR 0023).
- AI costs appear on the AWS bill and fall under AWS Budgets alerts.
- Geographic endpoints cost ~10% more than global for Claude 4.5 and later models on Bedrock. At current list prices (Haiku 4.5: $1 / $5 per million input/output tokens before the premium), a translation of ~800 input and ~300 output tokens costs roughly ¥0.4, about ¥50 per shop per month at 30 new beers a week. To be measured, not assumed; Japanese text may tokenize differently.
- A data-residency statement ("AI processing stays in Japan") becomes part of the client pitch.
- Bedrock model access requirements and quotas in Tokyo are verified during the walking skeleton.
