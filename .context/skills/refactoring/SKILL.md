---
type: skill
name: Refactoring
description: Refactor code safely with a step-by-step approach. Use when Improving code structure without changing behavior, Reducing code duplication, or Simplifying complex logic
skillSlug: refactoring
phases: [E]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

Refactors here rarely touch application logic — they consolidate compose duplication, unify image variants, or standardize env-var naming. Downstream users compose these files directly in production, so **backward compatibility is non-negotiable**. Use this skill when you observe:

- Duplication across `overrides/compose.*.yaml` (e.g., near-identical TLS stanzas in `compose.https.yaml`, `compose.traefik-ssl.yaml`, `compose.nginx-proxy-ssl.yaml`).
- Divergent logic between `images/custom/Containerfile` and `images/production/Containerfile` that should have stayed in lockstep.
- Inconsistent env-var defaults between `example.env` and override files.
- Repeated service stanzas that could reuse `x-backend-defaults` or `x-depends-on-configurator` anchors in `compose.yaml`.

## Instructions

1. Identify the duplication with `grep` across `overrides/` and `images/`.
2. Extract shared structure via YAML anchors in `compose.yaml` (see existing `x-backend-defaults`, `x-depends-on-configurator`).
3. Keep existing env-var names stable. If a rename is unavoidable, add the new name AND keep the old name working as an alias, then deprecate with a doc.
4. Add a migration note under `docs/06-migration/` any time downstream compose files may need edits.
5. Run the pytest suite against every affected override combination using `tests/compose.ci.yaml` before opening the PR.
6. Commit in small, single-purpose steps with `refactor:` (or `refactor(scope):`) prefix.

## Examples

- **Unify TLS overrides**: factor out the letsencrypt env and volume stanza into a shared YAML anchor; keep each top-level override file as a thin composition.
- **Consolidate MariaDB variants**: the three files (`overrides/compose.mariadb.yaml`, `compose.mariadb-shared.yaml`, `compose.mariadb-secrets.yaml`) can share a parameterized base; preserve each filename so existing user scripts keep working.
- **Align Containerfiles**: the `sites/assets` volume fix (commits `9ae6989` + `63f5169`) is the reference pattern — apply identical diffs to `images/production/` and `images/custom/` in the same PR.

## Guidelines

- Never silently change default env values.
- Never rename env vars without a deprecation window.
- Never delete an override file — rename/deprecate, add a shim if needed.
- Run `tests/test_frappe_docker.py` across all affected override combos before merging.
- Each refactor PR must be independently revertable.
