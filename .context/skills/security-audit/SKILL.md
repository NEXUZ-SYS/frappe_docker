---
type: skill
name: Security Audit
description: Review code and infrastructure for security weaknesses. Use when Reviewing code for security vulnerabilities, Assessing authentication/authorization, or Checking for OWASP top 10 issues
skillSlug: security-audit
phases: [R, V]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

Invoke this skill before every tagged release, and whenever a PR touches any of the following surfaces:

- Secret handling in `example.env`, `overrides/compose.mariadb-secrets.yaml`, or any new override that introduces credentials.
- TLS overrides (`overrides/compose.https.yaml`, `compose.traefik-ssl.yaml`, `compose.nginx-proxy-ssl.yaml`, `compose.custom-domain-ssl.yaml`, `compose.multi-bench-ssl.yaml`).
- Container user / privilege changes in `images/{production,custom,layered,bench}/Containerfile`.
- Security header changes in the `frontend` nginx service.
- Supply-chain concerns: pinned base images, pinned pre-commit hooks, pinned GitHub Action versions.

## Instructions

1. **Secrets**: any new env value that stores a credential MUST have a `_FILE` variant (Docker secrets compatible), modelled after `DB_PASSWORD_SECRETS_FILE` in `overrides/compose.mariadb-secrets.yaml`.
2. **TLS**: verify the override chains correctly with the `frontend` service; confirm `LETSENCRYPT_EMAIL` is required (not defaulted to a fake address); confirm HSTS/CSP headers where applicable.
3. **Non-root user**: confirm `images/<variant>/Containerfile` uses a non-root `USER` for the runtime and does not re-escalate via `chmod 777` or setuid binaries.
4. **Security headers**: confirm `tests/test_frappe_docker.py::test_files_html_security_headers` still covers any new `frontend` behavior; extend the test when adding new headers.
5. **Pinning**: pre-commit hooks in `.pre-commit-config.yaml` are already pinned (`black 25.1.0`, `isort 6.0.1`, `prettier 3.5.2`, `codespell 2.4.1`, `shellcheck v0.10`); never loosen a pin.
6. **Supply chain**: treat upstream `frappe/erpnext` image tags as a supply-chain risk — pin to a specific tag in `example.env` (currently `ERPNEXT_VERSION=v16.14.0`).

## Examples

- Adding `SMTP_PASSWORD` requires a `SMTP_PASSWORD_FILE` variant and doc under `docs/04-operations/`.
- A new Containerfile layer installing packages MUST avoid shipping dev tools (`build-essential`, `git`) to production images — remove them in a multi-stage build.
- A new workflow in `.github/workflows/` must pin each `uses:` to a full commit SHA, not a floating tag.

## Guidelines

- Apply Docker CIS benchmarks where feasible.
- Never commit real credentials; even rotated ones stay in git history.
- Treat every new env with a password, token, or key as a P0 review item.
- Prefer Docker secrets over env for anything sensitive in production.
- Re-run `pytest tests/test_frappe_docker.py -k security` after any frontend change.
