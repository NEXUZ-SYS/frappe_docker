---
type: skill
name: Code Review
description: Review code quality, patterns, and best practices. Use when Reviewing code changes for quality, Checking adherence to coding standards, or Identifying potential bugs or issues
skillSlug: code-review
phases: [R, V]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

Apply this skill to every pull request in `frappe_docker`. The review surface is narrow but sensitive: compose YAML (`compose.yaml`, `pwd.yml`), overrides in `overrides/compose.*.yaml`, Containerfiles under `images/{production,custom,layered,bench}/`, pytest integration tests in `tests/`, GitHub Actions workflows in `.github/workflows/`, VitePress docs in `docs/`, and the build matrix in `docker-bake.hcl`.

## Instructions

1. **Pre-commit green**: confirm the PR passes `.pre-commit-config.yaml` hooks — `black 25.1.0`, `isort 6.0.1`, `pyupgrade` (py37+), `prettier 3.5.2`, `codespell 2.4.1`, `shellcheck v0.10`, `shfmt`. A red hook blocks review.
2. **Compose composability**: new override must compose on top of `compose.yaml` AND in combination with adjacent overrides. Run `docker compose -f compose.yaml -f overrides/compose.<new>.yaml config` locally.
3. **YAML anchor reuse**: prefer reusing `x-backend-defaults` / `x-depends-on-configurator` anchors over copy-pasted service stanzas.
4. **Env contract**: confirm `example.env` defaults unchanged (or documented as a breaking change under `docs/06-migration/`). Every new env MUST appear in `example.env`.
5. **Containerfile changes**: check that layer order preserves cache (rarely changed → frequently changed) and that multi-arch builds defined in `docker-bake.hcl` still succeed.
6. **Tests**: any behavior change must be covered in `tests/test_frappe_docker.py` using the `Compose` helper from `tests/utils.py`.
7. **Docs touched** if the change is user-facing (new override, new env, new image, breaking change).

## Examples

- A new TLS override PR must include: the YAML, an env documentation update in `docs/02-setup/04-env-variables.md`, a deploy doc under `docs/03-production/`, and a test fixture in `tests/conftest.py` that boots the override against `tests/compose.ci.yaml`.
- A Containerfile change in `images/production/Containerfile` must be mirrored (when relevant) in `images/custom/Containerfile` — see commit `63f5169` for the sites/assets volume removal.

## Guidelines

- Prefer explicit env-var names over implicit magic.
- Never silently drop backward compatibility on env names or override filenames.
- Keep PRs small, single-scope, and independently revertable.
- Approve only after CI (`Lint`, `Build Stable/Develop/Bench`, `docker-build-push`) is green.
- Praise good use of anchors, clear commit messages, and concise diffs.
