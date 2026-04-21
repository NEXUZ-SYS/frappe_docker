---
type: doc
name: development-workflow
description: Day-to-day engineering processes, branching, and contribution guidelines
category: workflow
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## Development Workflow

`frappe_docker` follows a lightweight trunk-based workflow focused on
compose files, Containerfiles and CI. Changes are proposed via pull
requests against `main`, reviewed by maintainers listed in
`MAINTAINERS.md`, and released implicitly through image builds triggered
by upstream Frappe/ERPNext releases.

## Branching & Releases

- Trunk-based development on `main`. Feature branches are short-lived and
  merged via PR.
- Conventional commit prefixes are the norm: `fix:`, `docs:`, `chore:`,
  `feat:`. See recent history in `git log`.
- Releases are not tagged in this repo directly for every change.
  Instead, GitHub Actions workflows (`.github/workflows/build_stable.yml`,
  `build_develop.yml`, `build_bench.yml`) react to upstream
  `repository_dispatch` events when Frappe/ERPNext publish a new version
  and push images to Docker Hub.
- `build_stable.yml` builds both the v15 series (Python 3.11.6 / Node
  20.19.2) and the v16 series (Python 3.14.2 / Node 24.12.0) in
  parallel.

## Local Development

- **Devcontainer:** open the repo in VS Code using
  `development/vscode-example/` (copy `.devcontainer` from it) or the
  top-level `devcontainer-example/`. This gives you a bench container
  pre-wired to a shared network.
- **Disposable stack:** `docker compose -f pwd.yml up -d` boots a
  self-contained demo (Play-with-Docker flavor) suitable for smoke-testing
  changes to overrides.
- **Bench bootstrap:** from inside the devcontainer run
  `python development/installer.py` to initialize a bench and create a
  site. The script exposes `init_bench_if_not_exist`,
  `create_site_in_bench`, and a `get_args_parser` CLI.
- **Image iteration:** rebuild locally with
  `docker buildx bake -f docker-bake.hcl <target>` or by pointing
  `docker build` at the relevant `images/*/Containerfile`.

## Code Review Expectations

- CI must be green before merge. The required jobs are:
  - `lint.yml` - pre-commit on Python 3.10.6 plus Go helpers and
    shellcheck/shfmt.
  - `build_stable.yml`, `build_develop.yml`, `build_bench.yml` - image
    builds across supported image variants.
- Pre-commit (`.pre-commit-config.yaml`) auto-formats and auto-lints on
  every commit: black 25.1.0, isort 6.0.1, pyupgrade (py37+),
  prettier 3.5.2, codespell 2.4.1, shellcheck v0.10, shfmt,
  `end-of-file-fixer`, `trailing-whitespace`, and
  `check-shebang-scripts-are-executable`.
- Keep compose overrides minimal and composable - a new override should
  be orthogonal to existing ones so stacks can be assembled with
  additional `-f` flags.
- Prefer adding env variables with sensible defaults (see `example.env`)
  over changing service definitions in the base file.

## Onboarding Tasks

1. Read `README.md`, `CONTRIBUTING.md`, and `MAINTAINERS.md`.
2. Work through `docs/getting-started.md` (a ~32KB end-to-end walkthrough)
   and the `docs/01-getting-started/` section of the VitePress site.
3. Boot `pwd.yml` locally to see the base topology in action.
4. Pick one deployment style from `docs/03-production/` (Traefik, nginx
   proxy, HTTPS, Postgres, etc.) and practice composing the right
   overrides from `overrides/`.
5. Run the integration tests (`pytest tests/test_frappe_docker.py -v`)
   against a local compose stack to understand how the test harness
   drives `docker compose`.
