---
type: skill
name: Bug Investigation
description: Investigate bugs systematically and perform root cause analysis. Use when Investigating reported bugs, Diagnosing unexpected behavior, or Finding the root cause of issues
skillSlug: bug-investigation
phases: [E, V]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

Most defects in `frappe_docker` are **deployment or configuration regressions**, not application bugs — real application bugs belong upstream in `frappe/frappe` or `frappe/erpnext`. Invoke this skill when:

- A GitHub Actions job (`build_bench`, `build_develop`, `build_stable`, `docker-build-push`, `lint`) fails red.
- An override combination under `overrides/compose.*.yaml` fails to come up.
- A regression appears between ERPNext tags (e.g. bump of `ERPNEXT_VERSION` in `example.env`).
- A user report mentions containers stuck in restart loops (`configurator`, `backend`, `frontend`, `websocket`, `queue-short`, `queue-long`, `scheduler`).

## Instructions

1. **Reproduce minimally**: start from `pwd.yml` alone (`docker compose -f pwd.yml up -d`). If it works, layer overrides one by one until the failure reappears.
2. **Capture logs**: `docker compose logs configurator`, `docker compose logs backend`, `docker compose logs frontend`. The `configurator` container runs once and sets `common_site_config.json` — most boot-time failures surface here.
3. **Diff the override**: compare the failing override against `compose.yaml` to spot stray volume names, misspelled service anchors, or overridden env that shadows a default from `example.env`.
4. **Check `docs/07-troubleshooting/`** for known issues before filing a report.
5. **Bisect `ERPNEXT_VERSION`** in `example.env` to isolate regressions that come from upstream tags.
6. Reproduce the fix via `pytest tests/test_frappe_docker.py -k <relevant>` with `tests/compose.ci.yaml` to prove the regression is caught.

## Examples

- **Configurator restart loop**: check `DB_HOST`, `DB_PORT`, `REDIS_CACHE`, `REDIS_QUEUE` env; compare against `overrides/compose.mariadb.yaml` vs `overrides/compose.postgres.yaml`.
- **TLS failure with `overrides/compose.https.yaml`**: verify `LETSENCRYPT_EMAIL` env is set, inspect `traefik` logs, confirm port 80 is reachable for the ACME challenge.
- **Push-backup failure with `overrides/compose.backup-cron.yaml`**: reproduce bucket creation using `tests/_create_bucket.py`; check `BACKUP_*` env keys.
- **Frontend 502**: probe connections with `tests/_check_connections.py` and `tests/_ping_frappe_connections.py`.

## Guidelines

- Always attach full `docker compose logs` before hypothesizing.
- Bisect over override combinations, not over commits — the root cause is usually YAML.
- Check upstream Frappe/ERPNext changelogs before blaming this repo.
- Add a regression test in `tests/test_frappe_docker.py` when the fix lands.
- File the fix commit with `fix:` prefix following the repo's conventional commits.
