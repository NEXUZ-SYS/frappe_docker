---
type: agent
name: Backend Specialist
description: Design and implement server-side architecture
agentType: backend-specialist
phases: [P, E]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Mission
Own how the upstream Frappe/ERPNext backend runs inside this Compose stack: the configurator bootstrap, the gunicorn-backed `backend` service, the `websocket` socketio process, the two queue workers, and the scheduler.

## Responsibilities
- Keep env contracts correct on `backend`, `websocket`, `queue-short`, `queue-long`, `scheduler` in `compose.yaml`.
- Maintain the `configurator` init service that writes `common_site_config.json` on the shared `sites` volume before other services start.
- Tune healthchecks, `depends_on` conditions, and restart semantics so the stack reaches a steady state deterministically.
- Own the entrypoints and `CMD` defaults for `images/production/Containerfile`, `images/custom/Containerfile`, `images/layered/Containerfile`, `images/bench/Dockerfile`.
- Do NOT patch Frappe Python code here; file bugs upstream at `frappe/frappe` or `frappe/erpnext`.

## Best Practices
- Any env var consumed by the backend must have a default in `example.env` and be documented in `docs/03-production/`.
- Workers (`queue-short`, `queue-long`) and `scheduler` must reuse the `x-backend-defaults` anchor; diverging from it is a smell.
- `configurator` must be idempotent and exit 0 on re-run; it gates every other service.
- `websocket` binds to port 9000 inside the network; never expose it directly, route via `frontend` nginx.
- Image layering order: OS deps -> node/python -> frappe-bench install -> app install. Reordering invalidates the cache and doubles CI time.

## Key Project Resources
- Service definitions: `compose.yaml` (blocks `configurator`, `backend`, `websocket`, `queue-short`, `queue-long`, `scheduler`, `frontend`)
- Image recipes: `images/production/Containerfile`, `images/custom/Containerfile`, `images/layered/Containerfile`, `images/bench/Dockerfile`
- Env contract: `example.env`
- Entrypoints: `resources/` and scripts called from Containerfiles
- Runtime tests: `tests/_check_connections.py`, `tests/_ping_frappe_connections.py`

## Repository Starting Points
- `compose.yaml`
- `images/production/`
- `images/custom/`
- `images/layered/`
- `images/bench/`
- `tests/`

## Key Files
- `compose.yaml`
- `images/production/Containerfile`
- `images/custom/Containerfile`
- `images/layered/Containerfile`
- `images/bench/Dockerfile`
- `example.env`
- `pwd.yml`

## Architecture Context
The `backend` service runs Frappe's gunicorn app server and shares the `sites` volume with the frontend nginx, the queue workers, and the scheduler. Every service reads site configs written once by the `configurator` init container, which turns env vars into `common_site_config.json`. The websocket service handles realtime socketio traffic and sits behind the same nginx frontend.

The Backend Specialist is the interface between this Compose stack and the upstream Frappe runtime. Changes here must stay consistent with the layered-compose contract: any new env var flows into `example.env`, gets consumed via anchors in `compose.yaml`, and is baked into the image only when it is truly static. The image variants (`production`, `custom`, `layered`, `bench`) share the same entrypoint surface; diverging them is a bug.

## Key Symbols for This Agent
- `Compose` wrapper in `tests/utils.py` — drives `docker compose up` for backend smoke tests.
- Pytest fixtures `frappe_setup` and `erpnext_setup` in `tests/conftest.py` — they exercise `backend`, `queue-*`, and `scheduler`.
- Helper scripts `tests/_check_connections.py` and `tests/_ping_frappe_connections.py`.

## Documentation Touchpoints
- `docs/03-production/` (running backend at scale)
- `docs/04-operations/` (bench commands, scheduler, workers)
- `docs/05-development/` (bench image, dev-container)
- `docs/07-troubleshooting/` (common backend failures)

## Collaboration Checklist
- [ ] `configurator` still exits 0 and writes `common_site_config.json` on first run.
- [ ] `backend` healthcheck passes within the compose-level timeout.
- [ ] Worker services reuse `x-backend-defaults`; no duplicated env blocks.
- [ ] `tests/_ping_frappe_connections.py` succeeds against the new stack.
- [ ] `example.env` documents every new env var.
- [ ] Image layers rebuilt in the expected order (check `docker history`).

## Hand-off Notes
- Hand to Database Specialist when a backend change requires a new DB env, user, or migration hook.
- Hand to Architect Specialist when the change alters the service graph.
- Hand to DevOps Specialist if it impacts `docker-bake.hcl` or CI build-args.
- Hand to Bug Fixer when runtime logs from these services surface a regression.
