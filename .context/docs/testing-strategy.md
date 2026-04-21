---
type: doc
name: testing-strategy
description: Test frameworks, patterns, coverage requirements, and quality gates
category: testing
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Testing Strategy

Because this repository ships orchestration rather than application
code, testing is integration-first. Tests spin up real Frappe/ERPNext
stacks with `docker compose`, hit the exposed endpoints with HTTP
clients, and assert on responses, headers, and upstream state. There is
no unit test layer: the "unit under test" is a composed stack.

## Test Framework

- Pytest (version pinned via `tests/requirements-test.txt`).
- HTTP clients (requests / httpx) used from helper functions in
  `tests/utils.py`.
- Docker Compose v2 is driven through a thin wrapper class
  `Compose` in `tests/utils.py` that shells out to `docker compose`.
- A dedicated CI compose overlay at `tests/compose.ci.yaml` defines the
  topology used by the GitHub Actions workflows.

## Test Structure

- All test files live in `tests/`.
- Shared fixtures live in `tests/conftest.py`: `env_file`, `compose`,
  `frappe_setup`, `frappe_site`, `erpnext_setup`, `erpnext_site`,
  `postgres_setup`, `python_path`, `s3_service`, and the
  `S3ServiceResult` helper.
- The main test module is `tests/test_frappe_docker.py`, which exports
  `test_links_in_backends`, `test_endpoints`, `test_assets_endpoint`,
  `test_files_reachable`, `test_files_html_security_headers`,
  `test_frappe_connections_in_backends`, `test_push_backup`, `test_https`,
  plus the `TestErpnext` and `TestPostgres` test classes.
- Internal helper scripts are prefixed with an underscore so pytest
  does not auto-collect them: `tests/_check_connections.py`,
  `tests/_ping_frappe_connections.py`, `tests/_create_bucket.py`,
  `tests/_check_website_theme.py`.
- CI wiring for the tests lives alongside them in
  `tests/compose.ci.yaml`.

## Coverage Expectations

The suite is integration-focused. Coverage is measured by scenarios
rather than code lines:

- Base topology: the frontend serves assets, files are reachable, and
  security headers are present.
- Backend health: workers can reach DB and Redis; `configurator` leaves
  the stack in a usable state.
- DB flavors: both MariaDB (default) and Postgres (via
  `overrides/compose.postgres.yaml`) are exercised through the
  `postgres_setup` fixture and `TestPostgres` class.
- ERPNext-specific flows: `TestErpnext` runs once ERPNext has been
  installed on top of Frappe.
- TLS: `test_https` validates the HTTPS override stack.
- Backups: `test_push_backup` validates the
  `overrides/compose.backup-cron.yaml` path against an S3-compatible
  service from the `s3_service` fixture.

## Testing Patterns

- Fixtures bring up compose stacks inside temporary directories with
  their own env files, so tests can run in parallel without colliding.
- The `Compose` class encapsulates `up`, `down`, `exec`, and `logs`,
  keeping the tests focused on assertions rather than subprocess
  plumbing.
- URL readiness is handled by `wait_for_url` / `check_url_content` in
  `tests/utils.py`, which poll with a timeout instead of sleeping.
- The same tests run in CI via the `docker-build-push.yml` reusable
  workflow (called from `build_stable.yml` / `build_develop.yml` /
  `build_bench.yml`) after images are built, so every image tag is
  validated against the real integration suite.
- Tests do not modify the repository; they only read compose files and
  env files into tmp locations.

## Running Tests Locally

1. Create a virtualenv and install dependencies:
   `pip install -r tests/requirements-test.txt`.
2. Ensure Docker Engine + Compose v2 are available and your user has
   access to the Docker daemon.
3. Run the full suite: `pytest tests/test_frappe_docker.py -v`.
4. To target a subset: `pytest tests/test_frappe_docker.py::TestPostgres -v`
   or `pytest tests/test_frappe_docker.py::test_https -v`.
5. When iterating on a specific override, point the fixtures at the CI
   compose via `tests/compose.ci.yaml` or adapt the `compose` fixture
   in `tests/conftest.py`.
