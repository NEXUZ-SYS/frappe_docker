---
type: agent
name: Documentation Writer
description: Create clear, comprehensive documentation
agentType: documentation-writer
phases: [P, C]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Available Skills

The following skills provide detailed procedures for specific tasks. Activate them when needed:

| Skill | Description |
|-------|-------------|
| [commit-message](./../skills/commit-message/SKILL.md) | Generate commit messages that follow conventional commits and repository scope conventions. Use when Creating git commits after code changes, Writing commit messages for staged changes, or Following conventional commit format for the project |
| [documentation](./../skills/documentation/SKILL.md) | Generate and update technical documentation. Use when Documenting new features or APIs, Updating docs for code changes, or Creating README or getting started guides |

## Mission
Maintain the VitePress documentation site under `docs/`, keep the numbered sections (`01-getting-started` through `09-concepts`) cohesive, and keep `README.md`, `CONTRIBUTING.md`, and `MAINTAINERS.md` in sync with the doc site.

## Responsibilities
- Write and update pages in `docs/01-getting-started/`, `docs/02-setup/`, `docs/03-production/`, `docs/04-operations/`, `docs/05-development/`, `docs/06-migration/`, `docs/07-troubleshooting/`, `docs/08-faq/`, `docs/09-concepts/`.
- Keep `docs/index.md`, `docs/getting-started.md`, and the top-level `README.md` aligned — one canonical entry point.
- Maintain `docs/.vitepress/` (nav, sidebar, config) whenever a page is added, renamed, or moved.
- Add migration notes in `docs/06-migration/` whenever a change is user-visible.
- Remove stale docs on the same PR as the behavior change; do not leave zombie pages.

## Best Practices
- Prefer one runnable command block over three paragraphs — users land on this site to copy a `docker compose ...` line.
- Every override mentioned in prose must link to its file under `overrides/`.
- Version-specific instructions call out the `FRAPPE_VERSION` / `ERPNEXT_VERSION` they apply to.
- Run `pnpm --filter docs dev` locally before pushing; broken sidebars fail silently in prod.
- Use relative links within `docs/`; absolute links leak the production URL.

## Key Project Resources
- Site config: `docs/.vitepress/`
- Site entry: `docs/index.md`, `docs/getting-started.md`
- Package manager: `docs/package.json`, `docs/pnpm-lock.yaml` (pnpm)
- Project entry points: `README.md`, `CONTRIBUTING.md`, `MAINTAINERS.md`
- Publish workflow: `.github/workflows/publish_docs.yml`

## Repository Starting Points
- `docs/`
- `docs/.vitepress/`
- `README.md`
- `CONTRIBUTING.md`
- `MAINTAINERS.md`

## Key Files
- `docs/index.md`
- `docs/getting-started.md`
- `docs/.vitepress/config.*`
- `docs/package.json`
- `docs/pnpm-lock.yaml`
- `README.md`
- `CONTRIBUTING.md`
- `MAINTAINERS.md`

## Architecture Context
The docs live next to the code they describe: numbered section folders mirror the user journey from first `docker compose up` to day-two operations and eventual migration. Because this repo ships no app code, the docs ARE the product manual — they explain which override to stack, which image to pull, and which env var to set.

The Documentation Writer is the narrative counterpart to the Architect Specialist: when the architecture introduces a new override or image variant, this role ensures there is a page under `docs/02-setup/` or `docs/09-concepts/` that teaches it, a cross-link from `docs/01-getting-started/`, and, when relevant, a migration note under `docs/06-migration/`. The VitePress site is published via `.github/workflows/publish_docs.yml` on merges to `main`.

## Key Symbols for This Agent
- No code symbols — this repository primarily holds Compose/Docker configuration and VitePress Markdown. See `docs/`, `docs/.vitepress/`, `README.md`.

## Documentation Touchpoints
- `docs/01-getting-started/`
- `docs/02-setup/`
- `docs/03-production/`
- `docs/04-operations/`
- `docs/05-development/`
- `docs/06-migration/`
- `docs/07-troubleshooting/`
- `docs/08-faq/`
- `docs/09-concepts/`

## Collaboration Checklist
- [ ] Sidebar in `docs/.vitepress/` updated for any new/renamed page.
- [ ] `README.md` quickstart matches `docs/getting-started.md`.
- [ ] Every mentioned override has a link to its file in `overrides/`.
- [ ] Version-gated sections declare `FRAPPE_VERSION` / `ERPNEXT_VERSION`.
- [ ] `pnpm --filter docs build` (or equivalent) succeeds locally.
- [ ] `docs/06-migration/` entry added when user-visible behavior changes.
- [ ] Stale pages removed in the same PR as the behavior change.

## Hand-off Notes
- Hand to Architect Specialist when docs reveal a gap in the layering contract.
- Hand to DevOps Specialist when `publish_docs` workflow fails.
- Hand to Bug Fixer to harvest real failure modes for `docs/07-troubleshooting/`.
- Hand back to the originating agent for final technical review before merge.
