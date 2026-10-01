# Progress Log

Newest entries at the top. Update at the end of every working session.

## 2026-10-01: Cost guardrails verified, pnpm 11 pinned

**Done**
- Re-checked cost guardrails in the management account (`beer-mgmt-admin`):
  - Budget `beerfinder-monthly` (via `aws budgets describe-budgets`): $30/month, no filters (whole organization, including the workload account), `UnblendedCost`, alerts at 50/80/100% actual and forecasted; emails verified.
  - Cost Anomaly Detection had only the default AWS services monitor, with a `$100 AND 40%` subscription that cannot fire at our scale. Added AWS-managed **Linked account** monitor `org-linked-accounts` with subscription `beer-anomaly-daily` (daily summaries, absolute $5). Manual console change; not in Terraform.
- pnpm 10.32.1 → **11.28.2** (standalone install, `pnpm self-update`). Chose 11 over 12 (Rust rewrite released 2026-08-26) for maturity; 12 later as a planned upgrade.
- Root `package.json`: `private`, `type: module`, pnpm pinned exactly via `devEngines.packageManager` (`onFail: download`). `pnpm-lock.yaml` records the pnpm resolution with integrity hashes.

**Learned**
- An unfiltered budget in the management account covers the whole organization: the filter decides the scope, not the name.
- Budgets and Cost Explorer always display USD. ¥5,000 incl. tax ≈ $32; tax is included unless filtered out, so $30 leaves a small margin.
- Cost Explorer only lists accounts that have cost data.
- CAD percentage thresholds are N/A when expected spend is zero; use absolute thresholds for new accounts.
- `pnpm init` pinned pnpm 12.8.1 (the registry's latest), not the running 11.28.2, and wrote two pins. With `onFail: download` that would have silently switched pnpm. Always read generated files.

**Open questions**
- Does `pnpm/action-setup` read `devEngines.packageManager`, or only `packageManager`? Check when writing CI.
- Repository license (public repo; none chosen yet).
- Node 26 Active LTS timing (ADR 0013 expects October 2026; still "Current" on 2026-10-01).

**Next up**
1. `.nvmrc` (Node 24.21.0) and `pnpm-workspace.yaml` (package globs, release-age and `allowBuilds` settings), verifying pnpm 11 setting names first.
2. TypeScript base config (strict) and a trivial `packages/shared`.
3. Terraform bootstrap (ADR 0017) with `beer-workload-admin`; upgrade Terraform 1.16.1 → 1.16.4 first.


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

- Branch ruleset `main` active: PR required (0 approvals, solo owner), squash-only, linear history, no force pushes or deletions, **empty bypass list**. Required status checks to be added once the first CI workflow has run.
- First PR (#1) merged via squash.

**Next up**
1. Tidy up: `git branch -D chore/settings-and-progress-log` (`-D` because squash merges leave the branch looking unmerged), `git push origin --delete chore/settings-and-progress-log`, `git fetch --prune`; enable "Automatically delete head branches" in repo settings.
2. Check that budgets and Cost Anomaly Detection in the management account cover the new member account (Claude verifies AWS docs first; console check as `beer-mgmt-admin`).
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
