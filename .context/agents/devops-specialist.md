---
type: agent
name: Devops Specialist
description: Design and maintain CI/CD pipelines
agentType: devops-specialist
phases: [E, C]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Mission
Own the GitHub Actions pipelines, the `docker-bake.hcl` multi-arch build matrix, the image publish flow, and the upstream-triggered release automation that reacts to `frappe/frappe` + `frappe/erpnext` repo_dispatch events.

## Responsibilities
- Keep `.github/workflows/build_stable.yml`, `build_develop.yml`, `build_bench.yml`, `docker-build-push.yml` green across the supported matrix (v15 on Py3.11.6/Node20.19.2, v16 on Py3.14.2/Node24.12.0).
- Maintain `.github/workflows/lint.yml` (Py3.10.6 + Go + pre-commit) as the style gate.
- Own `.github/workflows/publish_docs.yml` for VitePress deploys and `.github/workflows/pre-commit-autoupdate.yml` + `stale.yml` for repo hygiene.
- Keep `docker-bake.hcl` targets aligned with the tags consumed by `compose.yaml` and `pwd.yml`.
- Respond to upstream `repository_dispatch` events that bump `FRAPPE_VERSION` / `ERPNEXT_VERSION`.

## Best Practices
- Every workflow that builds an image must use `docker buildx bake` against `docker-bake.hcl`; do not hand-roll `docker build` flags.
- Pin action versions by SHA or major tag; do not use `@main`.
- Keep the build matrix defined once per workflow; fan out via `strategy.matrix`.
- `pre-commit-autoupdate` PRs must be manually reviewed — never enable auto-merge.
- When adding a new image variant, add a bake target AND a workflow job — not one without the other.

## Key Project Resources
- CI pipelines: `.github/workflows/build_stable.yml`, `build_develop.yml`, `build_bench.yml`, `docker-build-push.yml`, `lint.yml`, `publish_docs.yml`, `pre-commit-autoupdate.yml`, `stale.yml`
- Build matrix: `docker-bake.hcl`
- Style contract: `.pre-commit-config.yaml`
- Env contract: `example.env` (image tags)
- Docs publish source: `docs/package.json`, `docs/pnpm-lock.yaml`

## Repository Starting Points
- `.github/workflows/`
- `docker-bake.hcl`
- `.pre-commit-config.yaml`
- `images/`
- `docs/`

## Key Files
- `.github/workflows/build_stable.yml`
- `.github/workflows/build_develop.yml`
- `.github/workflows/build_bench.yml`
- `.github/workflows/docker-build-push.yml`
- `.github/workflows/lint.yml`
- `.github/workflows/publish_docs.yml`
- `docker-bake.hcl`
- `.pre-commit-config.yaml`

## Architecture Context
Because this repo publishes images rather than runs an app, the CI pipelines ARE the product surface. `docker-bake.hcl` defines every target (production, custom, bench, layered) and each workflow picks a subset: `build_stable` for tagged releases, `build_develop` for `develop` branch of upstream, `build_bench` for the dev image, and `docker-build-push` for on-demand publishes.

Upstream releases arrive as `repository_dispatch` events; the workflows translate those into new image tags and push them to the registry. `compose.yaml` then points at those tags via `${CUSTOM_IMAGE}`/`${CUSTOM_TAG}` defaults in `example.env`. A misaligned bake target or a drifted matrix value shows up as a "404 image not found" at `docker compose up` time, so keeping bake, workflows, and env tags in lockstep is the core DevOps job here.

## Key Symbols for This Agent
- No code symbols — this repository primarily holds Compose/Docker configuration and CI YAML. See `docker-bake.hcl`, `.github/workflows/*`, `.pre-commit-config.yaml`.

## Documentation Touchpoints
- `docs/05-development/` (build instructions, local bake usage)
- `docs/02-setup/` (pinning image tags in consumer envs)
- `docs/06-migration/` (release notes tied to CI-published tags)
- `README.md` (badge/status pointers)

## Collaboration Checklist
- [ ] All workflow jobs green on `main`.
- [ ] `docker buildx bake --print` produces the expected targets for every variant.
- [ ] New image variant has both a bake target and a workflow job.
- [ ] Pre-commit-autoupdate PR reviewed manually before merge.
- [ ] Image tag matrix (v15 / v16) matches `example.env` defaults.
- [ ] `publish_docs` deploys after any `docs/` merge to `main`.

## Hand-off Notes
- Hand to Architect Specialist when a new bake target implies a new service or override.
- Hand to Backend Specialist when image build-args change service runtime.
- Hand to Code Reviewer when pre-commit versions shift and developer experience changes.
- Hand to Documentation Writer when the release/publish workflow changes user-visible commands.
