---
type: doc
name: glossary
description: Project terminology, type definitions, domain entities, and business rules
category: glossary
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Glossary

This glossary captures the terms you will encounter across `compose.yaml`,
the `overrides/` files, the `images/*/Containerfile` set, the VitePress
documentation in `docs/`, and the integration tests in `tests/`. Most
terms come straight from the Frappe ecosystem - this repo adopts that
vocabulary without redefining it.

## Terms

- **Bench** - The Frappe CLI (`bench`) that manages sites, apps, and
  background processes. The `images/bench/Dockerfile` builds an image
  suitable for development use that ships `bench` pre-installed.
- **Site** - A single Frappe tenant: a database plus a directory under
  the shared `sites` volume containing `site_config.json` and uploaded
  files. Multiple sites can coexist on one bench; nginx resolves the
  active site from the `Host:` header via `FRAPPE_SITE_NAME_HEADER`.
- **App** - A Frappe application installed on a bench. Examples include
  `frappe` itself and `erpnext`. Extra apps can be baked in via the
  custom or layered image builds.
- **Configurator** - The init service defined in `compose.yaml` that
  runs once at stack start, reads environment variables, and writes
  `common_site_config.json` to the shared `sites` volume. All other
  services `depends_on` it via the `x-depends-on-configurator` anchor.
- **Override** - A compose file in `overrides/` that is layered on top
  of `compose.yaml` with `docker compose -f compose.yaml -f
  overrides/<file>.yaml ...`. Overrides are orthogonal (TLS, proxy,
  DB flavor, backup, multi-bench).
- **Custom image** - Built from `images/custom/Containerfile`. Produces
  a single-stage image that bundles Frappe plus the apps you specify via
  `apps.json` (see `development/apps-example.json`).
- **Layered image** - Built from `images/layered/Containerfile`. Starts
  FROM the official Frappe image and layers your custom apps on top,
  trading image size for rebuild speed.
- **Production image** - Built from `images/production/Containerfile`.
  The official, multi-stage release image published to Docker Hub.
- **Bench image** - Built from `images/bench/Dockerfile`. Intended for
  development containers, not production.
- **docker-bake** - The buildx bake specification in `docker-bake.hcl`
  that describes how to build the image variants (production, custom,
  layered, bench) with shared arguments.
- **pwd.yml** - A disposable, self-contained compose file for Play with
  Docker demos and local smoke tests. Not intended for production.
- **FRAPPE_SITE_NAME_HEADER** - Environment variable consumed by the
  `frontend` nginx service to map the incoming HTTP `Host:` header to a
  Frappe site directory on the `sites` volume. `SITES_RULE` plays the
  equivalent role for Traefik-based overrides.
- **CUSTOM_IMAGE / CUSTOM_TAG** - Environment variables referenced by
  the `x-customizable-image` YAML anchor in `compose.yaml`. They let
  operators swap the official image for a downstream build without
  editing the compose file.
- **sites volume** - Docker named volume shared by every Frappe service
  in `compose.yaml`. Holds `common_site_config.json`, site directories,
  and user uploads.
- **Overrides composition** - The practice of combining multiple
  `-f overrides/*.yaml` flags to produce a target deployment (e.g.
  Traefik SSL + MariaDB secrets + backup cron).
