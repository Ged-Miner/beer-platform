# 0022. Owner authentication: Amazon Cognito with passwordless sign-in

- **Status:** Accepted
- **Date:** 2026-09-26

## Context

Owners and staff are busy and often non-technical; sign-in must be fast on a phone (Journey 3) and must not become a support burden. Tenant isolation (ADR 0004) depends on reliably knowing which organization a user belongs to.

## Decision

- **Amazon Cognito user pool, Essentials tier:** managed login, passwordless sign-in (passkeys and email one-time codes). Free tier: 10,000 monthly active users, indefinitely.
- Sign-in flow: first sign-in with an emailed one-time code, then passkey registration; later sign-ins use Face ID / fingerprint.
- Owner app: **public client, authorization code flow with PKCE**; no client secret.
- API: Hono middleware verifies Cognito JWTs against the user pool's public keys.
- **Organization membership comes from DSQL, never from the client:** the API maps the authenticated user to their `User` record and organization. Roles (owner/staff) are enforced in the API.
- Cognito email is sent through Amazon SES (billed separately). Plan the SES production-access request; confirm the email requirements for passwordless codes during setup.
- Users and pools are defined in Terraform; staff are invited by owners (post-MVP UI).

## Alternatives considered

- **Hosted identity services (Clerk, Auth0).** Better developer experience; another external vendor and cost.
- **Self-hosted authentication library storing users in DSQL.** Full control; more security-critical code to own.

## Consequences

- No passwords to reset for owners; strong phishing-resistant credentials by default.
- Cognito's developer experience is known to be rough; authentication stays behind one middleware layer so it can be replaced.
- SES sandbox restrictions must be lifted before real clients onboard.
