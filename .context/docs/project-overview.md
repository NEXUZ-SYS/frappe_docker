---
type: doc
name: project-overview
description: High-level overview of the project, its purpose, and key components
category: overview
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Project Overview

`frappe_docker` is the official Docker orchestration repository for the
Frappe Framework and ERPNext. It does not contain application source
code. Instead, it ships:

- Containerfiles that build production, custom, layered and development
  images of Frappe/ERPNext.
- A base `compose.yaml` plus a library of orthogonal `overrides/` files
  that let operators assemble deployment topologies (Traefik, nginx-proxy,
  HTTPS, MariaDB, Postgres, Redis, multi-bench, backups).
- A VitePress documentation site under `docs/` that walks users from
  first boot to production hardening.
- A pytest-based integration harness under `tests/` that drives
  `docker compose` and asserts the stack behaves correctly.

## Codebase Reference

- `README.md` - top-level entry point and orientation.
- `docs/getting-started.md` - ~32KB end-to-end walkthrough.
- `docs/index.md` and `docs/01-getting-started/` through
  `docs/09-concepts/` - VitePress site, numbered sections.
- `CONTRIBUTING.md` - contribution guidelines.
- `MAINTAINERS.md` - current maintainers.

## Quick Facts

- Language mix: Python, YAML, Shell, Dockerfile.
- License: MIT.
- No built-in application code - this repo packages external Frappe and
  ERPNext releases.
- Branching: trunk-based on `main` with PR reviews.
- Commit style: conventional (`fix:`, `docs:`, `chore:`, `feat:`).
- CI: GitHub Actions in `.github/workflows/` (8 workflows).
- Images are published to Docker Hub under `frappe/erpnext` (and
  companion tags) via the build workflows.

## Entry Points

- `compose.yaml` - base production compose.
- `pwd.yml` - Play with Docker demo compose.
- `images/production/Containerfile` - default image build.
- `images/custom/Containerfile` / `images/layered/Containerfile` -
  downstream customization image builds.
- `images/bench/Dockerfile` - development bench image.
- `development/installer.py` - CLI helper for creating a dev bench and
  a site inside it.

## Key Exports

Compose services exposed by `compose.yaml`:

- `configurator`, `backend`, `frontend`, `websocket`, `queue-short`,
  `queue-long`, `scheduler`.

Test helpers exported from `tests/`:

- `Compose`, `check_url_content`, `wait_for_url` (from `tests/utils.py`).
- `S3ServiceResult`, pytest fixtures `env_file`, `compose`,
  `frappe_setup`, `frappe_site`, `erpnext_setup`, `erpnext_site`,
  `postgres_setup`, `python_path`, `s3_service` (from
  `tests/conftest.py`).
- Integration tests and classes `test_endpoints`, `test_https`,
  `test_push_backup`, `TestErpnext`, `TestPostgres`, etc.

## File Structure

```
frappe_docker/
├── compose.yaml             # base compose topology
├── pwd.yml                  # Play-with-Docker demo stack
├── docker-bake.hcl          # buildx bake spec for all images
├── example.env              # reference environment file
├── install_x11_deps.sh      # shell helper for X11 in dev containers
├── images/                  # 4 image variants
│   ├── production/Containerfile
│   ├── custom/Containerfile
│   ├── layered/Containerfile
│   └── bench/Dockerfile
├── overrides/               # 17 compose override files
├── docs/                    # VitePress documentation site (01-09)
├── tests/                   # pytest integration suite
├── development/             # installer.py + VS Code devcontainer
├── devcontainer-example/    # standalone devcontainer sample
├── resources/               # helper scripts used by images/overrides
└── .github/workflows/       # 8 CI workflows
```

## Technology Stack Summary

- Docker + `docker compose` v2.
- Docker Buildx + `docker-bake.hcl` for multi-target image builds.
- Python 3.10.6 (CI lint), 3.11.6 (v15 image), 3.14.2 (v16 image).
- Node.js 20.19.2 (v15 image), 24.12.0 (v16 image).
- VitePress documentation site built with pnpm
  (`docs/package.json`, `docs/pnpm-lock.yaml`).
- pre-commit with black, isort, pyupgrade, prettier, codespell,
  shellcheck, shfmt.
- GitHub Actions CI, with reusable `docker-build-push.yml`.
- Pytest + httpx/requests for integration testing.

## Getting Started Checklist

1. Install Docker Engine and Docker Compose v2.
2. Clone the repo and copy `example.env` to `.env`; review the variables
   (`ERPNEXT_VERSION`, `DB_PASSWORD`, proxy hosts, etc.).
3. Boot the demo stack: `docker compose -f pwd.yml up -d`.
4. Read `docs/getting-started.md` for a production-style walkthrough.
5. Pick your reverse-proxy and DB overrides from `overrides/` and
   compose them with the base file.
6. (Optional) Open the repo in VS Code using the devcontainer in
   `development/vscode-example/` for bench-based development.

## Next Steps

- Architecture details: `.context/docs/architecture.md`.
- Request and service topology: `.context/docs/data-flow.md`.
- Process and branching: `.context/docs/development-workflow.md`.
- Tests: `.context/docs/testing-strategy.md`.
- Security surface: `.context/docs/security.md`.
- Tooling reference: `.context/docs/tooling.md`.
- Vocabulary: `.context/docs/glossary.md`.
