---
type: doc
name: architecture
description: System architecture, layers, patterns, and design decisions
category: architecture
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Architecture Notes

`frappe_docker` does not contain application source code. It is a Docker
orchestration repository that packages, builds, and deploys the upstream
Frappe Framework and ERPNext as container images. Architectural decisions
are therefore expressed primarily through Containerfiles, `docker compose`
files, and a handful of Python helpers for bench/site bootstrapping and
integration testing.

## System Architecture Overview

- **Compose-first orchestration.** A single base file `compose.yaml`
  defines the minimum set of services needed to run Frappe/ERPNext. All
  variations (HTTPS, Traefik, nginx-proxy, MariaDB, Postgres, Redis
  externalization, multi-bench, backups, etc.) are expressed as additive
  override files in `overrides/` composed via `docker compose -f ... -f ...`.
- **No built-in database or cache.** The base compose intentionally omits
  MariaDB, Postgres and Redis. Operators pick a flavor via an override.
- **Customizable image surface.** Images are parameterized via
  `CUSTOM_IMAGE` / `CUSTOM_TAG` environment variables and YAML anchors,
  allowing the same compose topology to run the official image or a
  downstream custom build without edits.
- **Separation of concerns.** Build definitions (`images/`), runtime
  topology (`compose.yaml`, `overrides/`), tests (`tests/`), local dev
  (`development/`) and the documentation site (`docs/`) are isolated so
  each can evolve independently.

## Architectural Layers

- **Base compose:** `compose.yaml`
- **Disposable demo compose:** `pwd.yml`
- **Image build configs:** `images/production/Containerfile`,
  `images/custom/Containerfile`, `images/layered/Containerfile`,
  `images/bench/Dockerfile`
- **Deployment overrides:** `overrides/` (17 compose files)
- **Build orchestration:** `docker-bake.hcl`
- **Test harness:** `tests/`
- **Local development environment:** `development/` and
  `devcontainer-example/`
- **Documentation site:** `docs/` (VitePress, sections `01-getting-started/`
  through `09-concepts/`)
- **CI/CD:** `.github/workflows/`

## Detected Design Patterns

| Pattern | Location | Notes |
| --- | --- | --- |
| YAML anchor reuse | `compose.yaml` (`x-customizable-image`, `x-depends-on-configurator`, `x-backend-defaults`) | All app services share image, restart policy, volumes and dependency rules via anchors. |
| Compose override composition | `overrides/compose.*.yaml` | Orthogonal concerns (TLS, proxy, DB flavor, backups) layered with `-f`. |
| Parameterized multi-target image build | `docker-bake.hcl` + `images/*/Containerfile` | Buildx bake targets produce production, custom, layered and bench images from one spec. |
| Init container | `configurator` service in `compose.yaml` | Writes `common_site_config.json` before backend/worker services start. |
| Externalized state | Shared `sites` volume, external DB/Redis via overrides | Stateful concerns kept out of the base file. |

## Entry Points

- `compose.yaml` - base production topology.
- `pwd.yml` - Play with Docker single-file demo.
- `images/production/Containerfile` - default released image build.
- `images/custom/Containerfile` / `images/layered/Containerfile` -
  downstream customization entry points.
- `development/installer.py` - CLI for bootstrapping a dev bench and
  creating a site inside it.
- `tests/test_frappe_docker.py` - pytest entry point for the integration
  suite.

## Public API

| Symbol | Type | Location |
| --- | --- | --- |
| `Compose` | class (compose wrapper) | `tests/utils.py` |
| `check_url_content` | function | `tests/utils.py` |
| `wait_for_url` | function | `tests/utils.py` |
| `S3ServiceResult` | dataclass/fixture result | `tests/conftest.py` |
| `env_file`, `compose`, `frappe_setup`, `frappe_site`, `erpnext_setup`, `erpnext_site`, `postgres_setup`, `python_path`, `s3_service` | pytest fixtures | `tests/conftest.py` |
| `TestErpnext`, `TestPostgres` | test classes | `tests/test_frappe_docker.py` |
| `test_links_in_backends`, `test_endpoints`, `test_assets_endpoint`, `test_files_reachable`, `test_files_html_security_headers`, `test_frappe_connections_in_backends`, `test_push_backup`, `test_https` | test functions | `tests/test_frappe_docker.py` |
| `cprint`, `main`, `get_args_parser`, `init_bench_if_not_exist`, `create_site_in_bench` | functions | `development/installer.py` |

## Top Directories Snapshot

- `images/` - 4 image variants (production, custom, layered, bench).
- `overrides/` - 17 compose override files.
- `docs/` - 12 subdirectories (9 numbered sections plus supporting
  folders) for the VitePress documentation site.
- `tests/` - 9 files: `conftest.py`, `test_frappe_docker.py`, `utils.py`,
  `_check_connections.py`, `_ping_frappe_connections.py`,
  `_create_bucket.py`, `_check_website_theme.py`, `compose.ci.yaml`,
  `requirements-test.txt`.
- `development/` - `installer.py`, `vscode-example/`, `apps-example.json`.
- `resources/` - helper scripts used by images and overrides.
- `.github/workflows/` - 8 CI workflows.

## Related Resources

- `.context/docs/project-overview.md`
- `.context/docs/data-flow.md`
- `docs/09-concepts/` (upstream concept documentation)
