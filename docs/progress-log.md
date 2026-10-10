# Progress Log

Newest entries at the top. Update at the end of every working session.

## 2026-10-10: Terraform 1.16.5 and the state bucket (bootstrap, part 1)

**Done**
- Terraform 1.16.1 → **1.16.5** from HashiCorp's apt repository, installed as `terraform=1.16.5-1` and held with `apt-mark hold`.
  - The repository source had been disabled by the Ubuntu 22.04 → 24.04 upgrade (2026-09-04), and HashiCorp rotated its package signing key on 2026-09-10. Replaced the key (fingerprint `D55C … 6560`, checked against hashicorp.com) and re-added the source for `noble`.
- `infra/bootstrap`: `versions.tf` (Terraform `~> 1.16.5`, AWS provider `~> 6.68`, locked at 6.68.0), `providers.tf` (Tokyo, `allowed_account_ids`, default tags), `state-bucket.tf`.
- State bucket `beer-platform-tfstate-<account-id>-ap-northeast-1-an` created with `beer-workload`: account regional namespace, versioning, SSE-S3, all public access blocked, `prevent_destroy`.
- Bootstrap state migrated from local into the bucket (`bootstrap/terraform.tfstate`, `use_lockfile = true`) with `terraform init -migrate-state`; `plan` reports no changes.

**Decisions** (details ADR 0017 left open)
- Bootstrap state: local for the first apply, then migrated into the bucket it created.
- Bucket name in the S3 account regional namespace, so only this account can ever create it. The account ID is visible in a public repo; AWS does not treat account IDs as secret.
- One bucket, one key per root module (`bootstrap/` now; `staging/` and `production/` later).
- The bucket half needs only S3 permissions, so it was applied with PowerUserAccess. `beer-workload-admin` is for the IAM half only.

**Learned**
- apt can only upgrade to versions listed in a repository index; a package with no source stays frozen with no warning. In `apt-cache policy`, `500` and `100` are priorities, not errors.
- Release upgrades disable third-party apt sources and leave `*.distUpgrade` backups.
- HTTPS proves which server you reached, not that the server is honest. A fingerprint published on a second site is a separate check.
- A version constraint (`~>`) is the allowed range; `.terraform.lock.hcl` is the chosen version plus checksums. `terraform init -upgrade` moves it.
- A `backend` block accepts literal values only: no functions, variables or data sources.
- "No changes" from `plan` after a state migration is the proof that it worked.

**Open questions**
- State bucket hardening: a TLS-only bucket policy, and a lifecycle rule to expire old noncurrent versions.
- Whether CI role ARNs (which contain the account ID) go in workflow files or GitHub variables.
- Docker, GitHub CLI and VS Code apt sources are still disabled since the release upgrade; 108 system updates pending.
- Carried over: how `packages/shared` is consumed; `exactOptionalPropertyTypes`; linter and formatter choice; `pnpm/action-setup` and `devEngines.packageManager`; repository license; Node 26 Active LTS timing.

**Next up**
1. Bootstrap part 2 with `beer-workload-admin`: GitHub OIDC provider and CI roles (ADR 0016), then the bootstrap runbook (ADR 0017).
2. Linting and formatting tools; first CI workflow running `typecheck`; then required status checks on the `main` ruleset.
3. `apps/api` hello world that imports `@beer-platform/shared`.


## 2026-10-04: Workspace scaffold and TypeScript base

**Done**
- PR #3: `.nvmrc` (Node 24.21.0, exact), `pnpm-workspace.yaml` (`apps/*`, `packages/*`; `minimumReleaseAge: 1440` with `minimumReleaseAgeStrict: true`), `node_modules/` ignored.
- TypeScript **6.0.3** pinned exactly as a root devDependency. Chose 6.0 over 7.0.2 (the native rewrite, `latest` on npm): 7.0 has no stable programmatic API yet, so tools such as typescript-eslint still need 6.0. 7 later as a planned upgrade.
- `tsconfig.base.json`: `strict`, `noUncheckedIndexedAccess`, `verbatimModuleSyntax`, `skipLibCheck`. Module and output settings live in each package's own config.
- `packages/shared` (`@beer-platform/shared`): `Language` type and `LANGUAGES`; `module: nodenext`, `noEmit`; a `typecheck` script, run for the whole workspace with `pnpm -r run typecheck`.
- Saw both guardrails fire: `pnpm config get minimumReleaseAgeStrict` returns `true`; an unchecked index access fails the type-check with exit code 2.

**Learned**
- A pushed branch lives in three places (GitHub, the remote-tracking ref, the local branch); auto-delete on merge removes only the first. After a merge: `git switch main`, `git pull --prune`, `git branch -D <branch>`.
- `pnpm-lock.yaml` is two YAML documents: the pinned pnpm itself, then the project's dependencies.
- `pnpm config get` shows configured values, not derived defaults. Set security settings explicitly so they can be read back.
- pnpm 11: the built-in `minimumReleaseAge` (1440) is non-strict unless set explicitly. Unlisted build scripts are denied and fail the install, so `allowBuilds` is only needed when a dependency asks for one.
- TypeScript does not follow semver; minor releases can add new errors. Pin exactly (`-E`).
- Types are always erased. `verbatimModuleSyntax` is about import and export statements (`import type`).
- `tsc` is silent on success; the exit code is what CI acts on.

**Open questions**
- How `packages/shared` is consumed (compiled `dist` or source): decide with the first consumer, `apps/api`.
- `exactOptionalPropertyTypes`: revisit when shared has real schemas.
- Linter and formatter choice (typescript-eslint needs the TypeScript 6 API).
- Carried over: `pnpm/action-setup` and `devEngines.packageManager`; repository license; Node 26 Active LTS timing (still "Current" on 2026-10-04).

**Next up**
1. Terraform 1.16.1 → latest 1.16.x (verify first), then the bootstrap (ADR 0017) with `beer-workload-admin`.
2. Linting and formatting tools; first CI workflow running `typecheck`; then add required status checks to the `main` ruleset.
3. `apps/api` hello world that imports `@beer-platform/shared`.

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
