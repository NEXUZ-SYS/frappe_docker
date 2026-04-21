---
type: doc
name: tooling
description: Scripts, IDE settings, automation, and developer productivity tips
category: tooling
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Tooling

Tooling in `frappe_docker` is thin but deliberate: a buildx bake file
for images, pre-commit for quality gates, GitHub Actions for CI, and
VitePress for documentation. Developer ergonomics are handled through
devcontainer samples and a small Python CLI for bootstrapping benches.

## Build Tooling

- **Docker Buildx + bake.** `docker-bake.hcl` at the repo root defines
  the build targets for every image variant. Use
  `docker buildx bake -f docker-bake.hcl <target>` to build locally.
- **Containerfiles.** The four image variants live under `images/`:
  `images/production/Containerfile`, `images/custom/Containerfile`,
  `images/layered/Containerfile`, `images/bench/Dockerfile`.
- **Resources.** Shared runtime helpers (entrypoints, scripts) live in
  `resources/` and are copied into images during build.

## Lint & Format

Configured in `.pre-commit-config.yaml`:

- `black` 25.1.0 - Python formatter.
- `isort` 6.0.1 - import sorter.
- `pyupgrade` - target Python 3.7+ syntax.
- `prettier` 3.5.2 - YAML, JSON and Markdown formatter; excludes
  `docs/pnpm-lock.yaml`.
- `codespell` 2.4.1 - spellcheck.
- `shellcheck` v0.10 - shell script linter.
- `shfmt` - shell script formatter.
- `end-of-file-fixer`, `trailing-whitespace` - whitespace hygiene.
- `check-shebang-scripts-are-executable` - ensures scripts with a
  shebang have the executable bit.

Run once locally with `pre-commit install` to enable the hooks on every
commit; `pre-commit run --all-files` checks the whole tree.

## CI/CD

Workflows in `.github/workflows/`:

- `lint.yml` - pre-commit lint on Python 3.10.6 with Go and shell
  tooling installed.
- `build_stable.yml` - builds the v15 (Python 3.11.6 / Node 20.19.2)
  and v16 (Python 3.14.2 / Node 24.12.0) stable image sets.
- `build_develop.yml` - builds nightly/develop branch images.
- `build_bench.yml` - builds the development bench image.
- `docker-build-push.yml` - reusable workflow that actually performs
  buildx bake and pushes to Docker Hub; called by the build workflows.
- `publish_docs.yml` - builds the VitePress site in `docs/` and
  publishes it.
- `pre-commit-autoupdate.yml` - periodically bumps pre-commit hook
  versions.
- `stale.yml` - closes stale issues and PRs.

## Documentation

- **VitePress site.** Source lives in `docs/`. The site is organized
  into numbered sections `01-getting-started/` through `09-concepts/`,
  with top-level `docs/index.md` and `docs/getting-started.md`.
- **Package manager.** `docs/package.json` + `docs/pnpm-lock.yaml` -
  use `pnpm install` and `pnpm run docs:dev` / `docs:build` from inside
  `docs/`.
- **Publishing.** Handled by `.github/workflows/publish_docs.yml` on
  pushes to `main`.

## Dev Environment

- `development/vscode-example/` - VS Code devcontainer sample wired for
  Frappe bench development.
- `devcontainer-example/` - alternative standalone devcontainer setup.
- `development/installer.py` - Python CLI that bootstraps a bench and
  creates a site inside it. Exposes `cprint`, `main`,
  `get_args_parser`, `init_bench_if_not_exist`, `create_site_in_bench`.
- `development/apps-example.json` - reference `apps.json` used when
  building custom or layered images.
- `install_x11_deps.sh` - installs X11 dependencies needed for browser
  testing inside the devcontainer.

## Editor Config

- `.editorconfig` - line endings, indentation and charset defaults
  enforced across editors.
- `.vscode/` - shared VS Code settings and recommended extensions.
- `.shellcheckrc` - project-wide shellcheck tuning consumed by both
  pre-commit and CI.
