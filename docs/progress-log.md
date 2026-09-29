# Progress Log

Newest entries at the top. Update at the end of every working session.

## 2026-09-29: AWS account structure fixed (ADR 0024 now actually in place)

**Done**
- Root `aws login` profile removed (`aws logout`, `[default]` deleted). Commands without `--profile` now fail with "Unable to locate credentials".
- Found that the workload account had never been created. Used root **once** to create an `AdministratorAccess` permission set (1-hour session) and assign it to `ged_miner` on the management account; everything after that was done as `ged_miner`.
- Created member account `beer-platform-workload` in AWS Organizations and assigned `ged_miner` both `PowerUserAccess` and `AdministratorAccess` there.
- `~/.aws/config` rewritten: one `[sso-session beer-platform-sso]`, and three profiles, all verified with `sts get-caller-identity`:
  - `beer-workload`: workload account, PowerUserAccess (daily)
  - `beer-workload-admin`: workload account, AdministratorAccess (bootstrap and IAM only)
  - `beer-mgmt-admin`: management account, AdministratorAccess (identity, organization and billing only)
- Removed `PowerUserAccess` from the management account.

**Learned**
- `organizations:CreateAccount` and assigning SSO access *to the management account* (needs IAMFullAccess or equivalent) are both impossible with PowerUserAccess. Assigning to member accounts has no such extra restriction.
- A permission set is a template; an assignment creates an `AWSReservedSSO_<set>_<suffix>` role in one account, with a different suffix in each account. Never hard-code those ARNs.
- Two timers: the permission-set session (how long role credentials last) and the Identity Center user session (when you must sign in again). Short admin sessions limit how long stolen cached credentials stay useful.
- Minimize root use: CloudTrail attributes Identity Center actions to a named user and an expiring session.

**Next up**
1. Branch ruleset on `main` (doc 07), then the first PR (settings.json change, progress log, README status).
2. Check that budgets and Cost Anomaly Detection in the management account cover the new member account.
3. Walking skeleton: pnpm workspace + TypeScript scaffolding, then Terraform bootstrap (ADR 0017) with `beer-workload-admin`.

## 2026-09-28: Repository live, safety rules in place, AWS profile problem found

**Done**
- Tutoring preferences agreed: complete files explained line by line at first, then pattern challenges once a pattern has repeated; batches of 3–5 commands; short understanding checks; ~1 hour sessions. The user runs all state-changing git commands.
- `.claude/settings.json`: deny rules for state-changing Terraform, AWS, git, `gh` and Docker commands, and for credential/state files; `ask` for every `terraform`, `aws`, `gh` and `docker` command. Output style set to Explanatory (Learning assumes Claude edits files).
- Public repo `Ged-Miner/beer-platform` created; first commit pushed (`cda6631`). That was the last direct push to `main`.
- Commit identity: repo-local `user.email` is the GitHub noreply address; "Keep my email addresses private" and push protection are on.

**Learned**
- Bash permission rules match command *text*: wide deny patterns can block harmless commands (e.g. a `git log` format string containing "committer"), and are not a security boundary. They work together with CLAUDE.md and reading every prompt.
- Git commits record an author and a committer; `--amend --reset-author` re-stamps both, and changing either creates a new SHA, so a force push is needed (`--force-with-lease`).
- GitHub owner names are case-sensitive in IAM trust conditions (the name is `Ged-Miner`).
- PowerUserAccess (v12) denies `iam:*`, `organizations:*` and `account:*`, so it cannot run the Terraform bootstrap (OIDC provider and roles).

**Found (unresolved)**
- `default` AWS profile was an `aws login` session as the **root user** of the management account (expired).
- `beer-platform-power-user` and `beerfinder` both point at the **management** account (confirmed: it is the organization's management account). The access portal shows only one account ("Ged Miner"); access to the workload account is missing or the account doesn't exist.
- Uncommitted change: `.claude/settings.json` now also denies reading `~/.aws/login/cache/**`. Commit via the first pull request.

**Next up**
1. `aws logout --profile default`; delete the `[default]` section from `~/.aws/config`; confirm `aws sts get-caller-identity` fails with "Unable to locate credentials". Delete `beerfinder` if unused.
2. Console check (report only, change nothing): Organizations → AWS accounts (does the workload account exist?); IAM Identity Center → AWS accounts (assignments per account); access portal roles under "Ged Miner".
3. Claude verifies which permissions Identity Center account assignments need (possible chicken-and-egg with PowerUserAccess), then plan the target setup: PowerUserAccess (daily) and AdministratorAccess (bootstrap only, short session) on the **workload** account; named profiles for each; nothing deployed in management.
4. Branch ruleset on `main` (doc 07), then the first PR (the settings.json change).
5. Walking skeleton: pnpm workspace + TypeScript scaffolding, then Terraform bootstrap (ADR 0017).

## 2026-09-26: Blueprint complete, AWS account prepared

**Done**
- Design steps 1–5 complete (docs 01–07, ADRs 0001–0024).
- AWS account hardened: root user secured with a passkey; budget alerts (50/80/100% actual, 100% forecast) and Cost Anomaly Detection enabled.
- AWS Organizations enabled; workload account created for the project; IAM Identity Center (organization instance, Tokyo) with SSO access to both accounts. *(Correction, 2026-09-29: the workload account had not actually been created, and SSO access existed only for the management account; fixed in the 2026-09-29 entry.)*

**Next up (first Claude Code session)**
1. Create the GitHub repository (public) and commit `docs/` and `CLAUDE.md`.
2. Set up `.claude/settings.json` permission deny rules matching the safety rules in `CLAUDE.md` (verify current syntax first).
3. Select the Learning output style via `/config`.
4. Start the walking skeleton: repository scaffolding (pnpm workspace, TypeScript config), then Terraform bootstrap (ADR 0017).
