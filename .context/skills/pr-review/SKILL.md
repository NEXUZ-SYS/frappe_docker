---
type: skill
name: Pr Review
description: Review pull requests against team standards and best practices. Use when Reviewing a pull request before merge, Providing feedback on proposed changes, or Validating PR meets project standards
skillSlug: pr-review
phases: [R, V]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

Use this skill when opening a new PR in `frappe_docker`, or when reviewing someone else's. The repo follows trunk-based development against `main`, so PRs land fast — both the description and the review must be crisp.

## Instructions

**For PR authors:**

1. Start the description with WHY (the problem, the user impact, the upstream issue link if relevant).
2. List exactly which overrides, images, env keys, and docs were touched — reviewers should not have to grep the diff.
3. Link to upstream Frappe/ERPNext issues when the PR follows an upstream bug or feature.
4. Keep the PR small and single-scope. If you touched both `overrides/` and `images/`, explain why they are inseparable.
5. Suggest a label: `compose`, `overrides`, `images`, `docs`, `ci`, `tests`.

**For PR reviewers:**

1. Confirm CI is green: `Lint`, `Build Stable`, `Build Develop`, `Build Bench`, `docker-build-push` on `.github/workflows/`.
2. Confirm pre-commit ran clean (`black 25.1.0`, `isort 6.0.1`, `pyupgrade`, `prettier 3.5.2`, `codespell 2.4.1`, `shellcheck v0.10`, `shfmt`).
3. Confirm docs were updated when the change is user-facing.
4. For override changes: run `docker compose -f compose.yaml -f overrides/compose.<file>.yaml config` locally if the change is non-trivial.
5. For Containerfile changes: confirm `images/production/` and `images/custom/` stay consistent where they mirror each other.

## Examples

- Reviewing PR `#1879 fix: remove nested sites assets volume` — verify both `images/production/Containerfile` and `images/custom/Containerfile` are updated, verify the migration note was moved into `docs/06-migration/`, verify no test regression in `tests/test_frappe_docker.py`.
- A new TLS override PR — require cross-linked doc under `docs/03-production/`, env-var documentation in `docs/02-setup/04-env-variables.md`, and a test that probes the TLS endpoint using `tests/_check_connections.py`.

## Guidelines

- Prefer small PRs — break large features down with the feature-breakdown skill.
- Never force-push after review has started; add commits.
- Label PRs by area so release notes stay organized.
- Do not approve on faith — confirm CI and pre-commit explicitly.
- Warn the author (do not block) when an override could be expressed as a flag on an existing override.
