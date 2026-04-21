---
type: skill
name: Feature Breakdown
description: Break down features into implementable tasks. Use when Planning new feature implementation, Breaking large tasks into smaller pieces, or Creating implementation roadmap
skillSlug: feature-breakdown
phases: [P]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

In `frappe_docker`, a "feature" is rarely application code — it is almost always one of:

- A new deployment override under `overrides/compose.*.yaml`.
- A new image variant under `images/{production,custom,layered,bench}/`.
- A new pytest scenario in `tests/` or a new CI job in `.github/workflows/`.
- A new documentation section in `docs/`.

Invoke this skill before opening a non-trivial PR that touches more than one of the areas above.

## Instructions

Decompose every feature into the following ordered sub-tasks, each independently reviewable:

1. **Compose YAML** — draft the new `overrides/compose.<name>.yaml`, reusing `x-backend-defaults` and `x-depends-on-configurator` anchors from `compose.yaml` whenever possible.
2. **Env-var contract** — add defaults to `example.env` with an inline comment for each new key.
3. **Bake target** — update `docker-bake.hcl` if a new image or tag is introduced.
4. **Image** — add or modify `images/<variant>/Containerfile` if the feature requires a new runtime layer.
5. **Tests** — add a fixture in `tests/conftest.py` and an integration test in `tests/test_frappe_docker.py` (or a new `tests/test_<area>.py`), wired through `tests/compose.ci.yaml`.
6. **Docs** — add a page under the correct numbered section in `docs/`.
7. **CI** — add or update a workflow in `.github/workflows/` if the build matrix changes.

## Examples

- **S3-compatible backup**: (1) new `overrides/compose.backup-cron.yaml` variant or extension, (2) `BACKUP_ENDPOINT`, `BACKUP_ACCESS_KEY`, `BACKUP_SECRET_KEY` in `example.env`, (3) no new bake target, (4) no image change, (5) pytest using `tests/_create_bucket.py`, (6) doc under `docs/04-operations/`, (7) no CI matrix change.
- **New `layered` image variant flavor**: (1) no compose change, (2) one env for the new apps list, (3) new bake target in `docker-bake.hcl`, (4) new `images/layered/Containerfile` sibling, (5) CI build job added in `.github/workflows/docker-build-push.yml`, (6) doc under `docs/05-development/`.

## Guidelines

- Each sub-task must be independently testable and revertable.
- Do not bundle unrelated overrides in a single PR.
- Flag upstream Frappe/ERPNext dependencies early (e.g., minimum `ERPNEXT_VERSION`).
- Identify CI cost before adding a new build matrix row.
- Prefer extending an existing override with an opt-in env over forking a new override file.
