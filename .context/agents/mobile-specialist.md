---
type: agent
name: Mobile Specialist
description: Develop native and cross-platform mobile applications
agentType: mobile-specialist
phases: [P, E]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Mission
This repository contains no mobile client. Frappe/ERPNext mobile apps are external projects that consume the same HTTPS endpoints this repo publishes. This playbook exists only so orchestration tooling has a slot to route mobile-flavored questions into — real mobile development happens elsewhere.

## Responsibilities
- Confirm that compose-published endpoints stay reachable and correctly TLS-terminated for mobile clients (same HTTPS URL the web UI uses).
- Watch CORS and auth-related header behavior in the `frontend` nginx service — mobile apps are more sensitive to these than desktop browsers.
- If push-notification or FCM relays are ever added, scaffold them as an override under `overrides/` and document them in `docs/04-operations/`.
- Ensure published image tags (via `docker-bake.hcl`) remain compatible with Frappe mobile client API expectations.

## Best Practices
- Never add mobile-only glue code to this repo. Keep mobile concerns in env-driven compose overrides so they can be toggled on/off.
- Treat the mobile API contract as identical to the web contract — any header change in the `frontend` service affects mobile too.
- Do not proxy push-notification tokens through `frontend` logs.

## Key Project Resources
- Upstream Frappe/ERPNext mobile repositories (external).
- `docs/02-setup/` and `docs/04-operations/` for the endpoints mobile apps hit.

## Repository Starting Points
- `compose.yaml` (the `frontend`, `backend`, `websocket` services).
- `overrides/compose.https.yaml`, `overrides/compose.traefik-ssl.yaml`, `overrides/compose.nginxproxy-ssl.yaml`.
- `example.env` for endpoint-shaping env vars.

## Key Files
- `compose.yaml`.
- `overrides/compose.https.yaml`.
- `overrides/compose.traefik-ssl.yaml`.

## Architecture Context
Mobile clients hit the same HTTPS URL as the desktop UI. Therefore the same edge topology applies: external proxy (optional) to `frontend` nginx to `backend` gunicorn, with `/socket.io` going to `websocket`. There is no mobile-specific gateway here.

## Key Symbols for This Agent
No code symbols apply. The relevant configuration surfaces are the `frontend` service env block in `compose.yaml`, the `HTTPS_*` variables in `example.env`, and Traefik/nginx-proxy labels in the HTTPS overrides.

## Documentation Touchpoints
- `docs/02-setup/` (endpoint URL shape).
- `docs/04-operations/` (TLS and domain changes that affect mobile clients).

## Collaboration Checklist
- Re-route reverse-proxy/nginx questions to `frontend-specialist`.
- Re-route image publishing and tag questions to `devops-specialist`.
- Re-route auth/CORS/secret questions to `security-auditor`.

## Hand-off Notes
Most tasks here should be re-routed to `frontend-specialist` (reverse proxy) or `devops-specialist` (image publish). If a task truly requires native mobile code changes, it belongs in the upstream mobile repositories, not here.
