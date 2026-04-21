---
type: skill
name: Test Generation
description: Generate comprehensive test cases for code. Use when Writing tests for new functionality, Adding tests for bug fixes (regression tests), or Improving test coverage for existing code
skillSlug: test-generation
phases: [E, V]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

Tests in `frappe_docker` are pytest **integration** tests that drive `docker compose` — not unit tests. Use this skill when:

- Adding or modifying any file in `overrides/compose.*.yaml`.
- Adding or modifying any `images/<variant>/Containerfile`.
- Introducing new env-var behavior in `example.env` that changes a service's runtime contract.
- Fixing a regression — the fix MUST land with a pytest case that reproduces the bug.

## Instructions

1. Add or extend a fixture in `tests/conftest.py` to bring up the new compose combination. Reuse the `Compose` helper from `tests/utils.py`, which wraps `docker compose` lifecycle calls.
2. Add an integration test in `tests/test_frappe_docker.py`, or create a focused `tests/test_<area>.py` when the area is large (e.g., `test_backup.py` for the backup-cron override).
3. Use the existing probe helpers:
   - `tests/_check_connections.py` — verify service reachability.
   - `tests/_ping_frappe_connections.py` — verify Frappe can talk to DB and Redis.
   - `tests/_create_bucket.py` — provision S3-compatible storage for backup tests.
   - `tests/_check_website_theme.py` — confirm the frontend serves the expected theme/assets.
4. Wire the new case into CI via `tests/compose.ci.yaml` so the pre-merge matrix exercises it.
5. Ensure teardown is idempotent — fixtures must run `Compose.down(volumes=True)` to avoid polluting subsequent runs.

## Examples

- **New Postgres override**: extend the `postgres_setup` fixture in `tests/conftest.py`, add `test_postgres_backend_boots` in `tests/test_frappe_docker.py`, add the compose stack to `tests/compose.ci.yaml`.
- **New security header**: extend `test_files_html_security_headers` in `tests/test_frappe_docker.py` with the new header assertion.
- **Regression for the sites/assets volume fix**: add a test that inspects `docker inspect` output for the `backend` container and asserts the old nested volume no longer appears.

## Guidelines

- Tests must be idempotent — always tear down the compose project.
- Prefer integration over mocking for compose behavior; only mock at the boundary (e.g., external S3).
- Keep `requirements-test.txt` minimal — every dependency added here slows every CI run.
- Name tests after the behavior they verify, not the function.
- Run locally with `pytest tests/ -k <area>` before pushing.
- Failing tests must fail loud — never `xfail` a legitimate regression.
