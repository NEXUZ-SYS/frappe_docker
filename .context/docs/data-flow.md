---
type: doc
name: data-flow
description: How data moves through the system and external integrations
category: data-flow
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Data Flow & Integrations

Since this repo only orchestrates containers, the "data flow" is the
request path and the storage/queue topology that the compose services
establish at runtime. End users reach a reverse proxy (from an override
such as `overrides/compose.traefik.yaml` or
`overrides/compose.nginxproxy.yaml`, or the built-in `compose.https.yaml`
wrapper), which fronts the `frontend` nginx container. The frontend
terminates HTTP(S) and forwards dynamic traffic to `backend:8000` (Frappe
gunicorn) or `websocket:9000` (socketio). Backends then talk to an
external MariaDB or Postgres container (supplied via an override) plus
Redis for cache/queues.

## Module Dependencies

- `backend` depends on `configurator` (init container that writes
  `common_site_config.json`).
- `frontend` depends on `backend` and `websocket`.
- `queue-short`, `queue-long` and `scheduler` depend on `configurator`
  and share the `sites` volume with `backend`.
- External (declared by overrides):
  - Database: MariaDB via `overrides/compose.mariadb.yaml` /
    `overrides/compose.mariadb-shared.yaml` /
    `overrides/compose.mariadb-secrets.yaml`, or Postgres via
    `overrides/compose.postgres.yaml`.
  - Redis: `overrides/compose.redis.yaml` (shared cache + queue + socketio
    broker).
  - Reverse proxy: `overrides/compose.traefik*.yaml`,
    `overrides/compose.nginxproxy*.yaml`, `overrides/compose.proxy.yaml`,
    `overrides/compose.noproxy.yaml`.

## Service Layer

Services defined in `compose.yaml`:

- `configurator` - one-shot init service that renders
  `common_site_config.json` from environment variables.
- `backend` - Frappe gunicorn HTTP worker.
- `frontend` - nginx that serves static assets and proxies to backend /
  websocket (entrypoint `nginx-entrypoint.sh`).
- `websocket` - Node.js socketio server.
- `queue-short`, `queue-long` - RQ workers consuming Redis queues.
- `scheduler` - cron-style scheduler for Frappe background jobs.

All services share the `sites` named volume so uploaded files and
`sites/common_site_config.json` stay consistent across replicas.

## High-level Flow

1. A user browser hits the public host over HTTP(S).
2. The reverse-proxy override (Traefik, nginx-proxy, or the bundled
   `compose.https.yaml`) terminates TLS and routes by `Host:` header.
3. Traffic lands on the `frontend` nginx, which uses
   `FRAPPE_SITE_NAME_HEADER` / `SITES_RULE` to map the host to a Frappe
   site directory under the `sites` volume.
4. Dynamic requests proxy to `backend:8000`; realtime traffic proxies to
   `websocket:9000`.
5. Backends and workers read/write to the external DB and Redis declared
   by overrides, and to the shared `sites` volume for files.
6. The scheduler enqueues periodic jobs onto Redis; the queue workers
   consume them.

## External Integrations

- **Database:** MariaDB or PostgreSQL (via override), never bundled in
  the base file.
- **Redis:** cache, queue and socketio broker (via override).
- **SMTP:** configured per-site inside Frappe; not fixed by compose.
- **Object storage:** S3-compatible backends for scheduled backups
  (exercised in tests via `tests/_create_bucket.py` and the
  `s3_service` fixture).
- **TLS / ACME:** Let's Encrypt via `overrides/compose.https.yaml`,
  `overrides/compose.traefik-ssl.yaml`, or
  `overrides/compose.nginxproxy-ssl.yaml`.

## Observability & Failure Modes

- Health checks are exercised by `tests/_check_connections.py` and
  `tests/_ping_frappe_connections.py`, which verify the backend can reach
  DB and Redis before traffic tests run.
- Restart behavior is controlled by the `RESTART_POLICY` environment
  variable consumed through the `x-backend-defaults` YAML anchor in
  `compose.yaml`.
- Scheduled backups run under `overrides/compose.backup-cron.yaml` and
  are verified by `tests/test_frappe_docker.py::test_push_backup`.
- Secrets (e.g. DB password) can be supplied as Docker secrets via
  `overrides/compose.mariadb-secrets.yaml` instead of plain env vars.
