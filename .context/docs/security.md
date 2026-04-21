---
type: doc
name: security
description: Security policies, authentication, secrets management, and compliance requirements
category: security
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Security

Security for `frappe_docker` is largely about how the stack is composed:
the base `compose.yaml` intentionally stays minimal, and it is the
combination of overrides and environment variables that determines the
exposed surface. Frappe/ERPNext itself handles in-app authentication and
authorization; this repo focuses on transport, secrets, and image
hygiene.

## Threat Model

- Frappe/ERPNext is a public-facing web application. The main attack
  surface is HTTP(S) exposed through the reverse-proxy override
  (`overrides/compose.traefik*.yaml`,
  `overrides/compose.nginxproxy*.yaml`, or `overrides/compose.https.yaml`).
- Database credentials are sensitive. They can be provided as plain
  environment variables (see `example.env::DB_PASSWORD`) or as Docker
  secrets when using `overrides/compose.mariadb-secrets.yaml`
  (`DB_PASSWORD_SECRETS_FILE`).
- TLS termination happens either at Traefik/nginx-proxy (via ACME /
  Let's Encrypt) or at the bundled `compose.https.yaml` wrapper -
  operators must not expose the `frontend` service directly to the
  internet over plain HTTP.
- Compose network isolation separates `backend`, `websocket`, workers,
  DB and Redis from the host. Only the reverse proxy should bind host
  ports.

## Hardening Checklist

- Use `overrides/compose.mariadb-secrets.yaml` to supply DB credentials
  as Docker secrets instead of plain env vars.
- Enable HTTPS by composing one of `overrides/compose.https.yaml`,
  `overrides/compose.traefik-ssl.yaml`,
  `overrides/compose.nginxproxy-ssl.yaml`, or
  `overrides/compose.custom-domain-ssl.yaml`.
- Configure `UPSTREAM_REAL_IP_ADDRESS`, `UPSTREAM_REAL_IP_HEADER`, and
  `UPSTREAM_REAL_IP_RECURSIVE` on the `frontend` service (see
  `example.env`) so client IPs are trusted only from your real proxy.
- Confirm the image runs as a non-root user - the multi-stage
  `images/production/Containerfile` creates and switches to a dedicated
  Frappe user; downstream custom images built from
  `images/custom/Containerfile` / `images/layered/Containerfile`
  should preserve this.
- Keep images up to date. The `build_stable.yml`, `build_develop.yml`,
  and `build_bench.yml` workflows react to upstream
  `repository_dispatch` events, so pulling the latest tag after each
  Frappe/ERPNext release picks up security fixes.
- Restrict exposed ports to the reverse proxy only; never publish
  `backend` or `websocket` ports on the host.
- Set `LETSENCRYPT_EMAIL` correctly so ACME renewals do not silently
  fail.

## Dependencies & Supply Chain

- Base images and apt packages come from Docker Hub and the distro
  repositories baked into each Containerfile under `images/`.
- pre-commit hooks are pinned to specific versions in
  `.pre-commit-config.yaml` (black 25.1.0, isort 6.0.1, prettier 3.5.2,
  codespell 2.4.1, shellcheck v0.10, shfmt, pyupgrade py37+), which
  gives a deterministic lint environment.
- VitePress documentation dependencies are locked in
  `docs/pnpm-lock.yaml`.
- CI workflows in `.github/workflows/` use Docker Buildx and the
  reusable `docker-build-push.yml` workflow to publish images.

## Incident Response

- To roll back, redeploy the previous `ERPNEXT_VERSION` tag by updating
  `.env` (see `example.env`) and re-running `docker compose up -d`.
- Scheduled backups are handled by
  `overrides/compose.backup-cron.yaml`, which can push backups to S3-
  compatible storage; restore paths are covered by the Frappe docs
  linked from `docs/04-operations/`.
- For compromised credentials, rotate DB and Redis secrets, rebuild the
  stack, and invalidate user sessions inside Frappe.

## Test Coverage

- `tests/test_frappe_docker.py::test_files_html_security_headers`
  verifies that the HTML responses include expected security headers
  (e.g. `X-Frame-Options`).
- `tests/test_frappe_docker.py::test_https` verifies TLS termination on
  the HTTPS override stack.
- `tests/test_frappe_docker.py::test_push_backup` exercises the
  backup-to-S3 path, ensuring the backup override integrates end-to-end.
- `tests/_check_connections.py` and `tests/_ping_frappe_connections.py`
  guard against misconfigured DB/Redis wiring that could otherwise
  surface as authentication failures in production.
