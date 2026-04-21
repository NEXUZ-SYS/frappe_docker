---
type: skill
name: Documentation
description: Generate and update technical documentation. Use when Documenting new features or APIs, Updating docs for code changes, or Creating README or getting started guides
skillSlug: documentation
phases: [P, C]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

This repo ships its documentation as a VitePress site in `docs/` (with `docs/package.json` using pnpm, an `index.md` landing page, `getting-started.md`, and nine numbered sections `01-` through `09-`). Trigger this skill whenever a change affects:

- A new or renamed override under `overrides/compose.*.yaml`.
- A new or changed env variable in `example.env`.
- A new image variant under `images/` or a new bake target in `docker-bake.hcl`.
- A changed default behavior of any compose service.
- A breaking change that requires migration steps.

## Instructions

Route the change to the right numbered section:

1. `docs/01-getting-started/` — introduction and quickstart narrative.
2. `docs/02-setup/` — environment variables, build prerequisites, compose setup (`04-env-variables.md` is the env reference).
3. `docs/03-production/` — deploy recipes (TLS, traefik, nginx-proxy, multi-bench).
4. `docs/04-operations/` — day-2 ops (backups, logs, metrics).
5. `docs/05-development/` — contributor workflow, `development/installer.py`, devcontainer-example.
6. `docs/06-migration/` — breaking changes and upgrade notes (this is where the `sites/assets` volume migration note lives).
7. `docs/07-troubleshooting/` — FAQ, known issues.
8. `docs/08-reference/` — exhaustive reference tables.
9. `docs/09-concepts/` — deep dives (architecture, bench model, Frappe services).

Also touch `README.md` if the entry-point behavior changes, and keep `docs/.vitepress/` navigation consistent when adding pages.

## Examples

- Adding `overrides/compose.minio.yaml`: create a new page under `docs/02-setup/` (or `docs/04-operations/` if it is an ops concern), link it from `docs/getting-started.md`, and add the related env keys in `docs/02-setup/04-env-variables.md`.
- Removing a volume from `images/production/Containerfile` and `images/custom/Containerfile`: add a migration note under `docs/06-migration/` (see the recent `sites/assets` volume change).
- Bumping `ERPNEXT_VERSION` default in `example.env`: update `docs/02-setup/04-env-variables.md` and add a changelog entry.

## Guidelines

- One topic per page; cross-link aggressively.
- Show minimal runnable `docker compose` commands users can copy.
- Do not document the obvious — focus on the WHY and the gotchas.
- Remove stale pages when the underlying override or env is deleted.
- Keep terminology aligned with Frappe upstream (`bench`, `site`, `apps`).
