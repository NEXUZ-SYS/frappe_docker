---
type: skill
name: Api Design
description: Design RESTful APIs following best practices. Use when Designing new API endpoints, Restructuring existing APIs, or Planning API versioning strategy
skillSlug: api-design
phases: [P, R]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

This repository exposes no HTTP APIs of its own — the runtime APIs belong to upstream Frappe/ERPNext. Treat these artifacts as the repo's public surface instead:

- The **env-var contract** in `example.env` (consumed by every override and image).
- The **override catalog** in `overrides/compose.*.yaml` (17 files: `https`, `traefik`, `traefik-ssl`, `nginx-proxy`, `nginx-proxy-ssl`, `mariadb`, `mariadb-shared`, `mariadb-secrets`, `postgres`, `redis`, `proxy`, `noproxy`, `multi-bench`, `multi-bench-ssl`, `custom-domain`, `custom-domain-ssl`, `backup-cron`).
- The **frontend nginx reverse proxy** routing defined in the `frontend` service of `compose.yaml`.
- The **bake target names** in `docker-bake.hcl`.

Use this skill when adding or renaming any of the above, or when changing defaults that downstream users compose against.

## Instructions

1. Read `example.env` end-to-end before proposing any new env variable and confirm the default is safe for a naive first-time user.
2. Verify backward compatibility: existing env names MUST keep working. If you must rename, keep the old name as a deprecated alias and document the migration in `docs/06-migration/`.
3. Ensure new overrides compose cleanly with `pwd.yml` and with the other files in `overrides/`. No conflicting port bindings, no conflicting `volumes:` keys, no duplicated service definitions without YAML anchor reuse from `compose.yaml` (`x-backend-defaults`, `x-depends-on-configurator`, etc.).
4. Document every new env in `docs/02-setup/04-env-variables.md` and in `example.env` (with an inline comment).
5. For bake target renames, grep `.github/workflows/` for the old target name and update CI.

## Examples

- Adding `SOCKETIO_PORT`: append to `example.env` with default `9000`, document in `docs/02-setup/04-env-variables.md`, ensure `compose.yaml` `websocket` service picks it up.
- Adding `overrides/compose.minio.yaml` for S3-compatible storage: reuse `x-backend-defaults` anchor, expose only `BACKUP_*` env keys already declared in `example.env`, and cross-link the doc from `docs/04-operations/`.
- Renaming a bake target from `erpnext-custom` to `custom`: update `docker-bake.hcl`, `.github/workflows/build_*.yml`, and `docs/05-development/`.

## Guidelines

- Overrides must be composable in any order — no hidden ordering requirements.
- Every env var introduced MUST appear in `example.env` with a sensible default and a one-line comment.
- Never remove an env var without a deprecation window and a migration note.
- Prefer YAML anchors over duplicated service stanzas.
- Keep port defaults non-conflicting with `pwd.yml`.
