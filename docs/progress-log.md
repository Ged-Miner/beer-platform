# Progress Log

Newest entries at the top. Update at the end of every working session.

## 2026-09-26: Blueprint complete, AWS account prepared

**Done**
- Design steps 1–5 complete (docs 01–07, ADRs 0001–0024).
- AWS account hardened: root user secured with a passkey; budget alerts (50/80/100% actual, 100% forecast) and Cost Anomaly Detection enabled.
- AWS Organizations enabled; workload account created for the project; IAM Identity Center (organization instance, Tokyo) with SSO access to both accounts.

**Next up (first Claude Code session)**
1. Create the GitHub repository (public) and commit `docs/` and `CLAUDE.md`.
2. Set up `.claude/settings.json` permission deny rules matching the safety rules in `CLAUDE.md` (verify current syntax first).
3. Select the Learning output style via `/config`.
4. Start the walking skeleton: repository scaffolding (pnpm workspace, TypeScript config), then Terraform bootstrap (ADR 0017).
