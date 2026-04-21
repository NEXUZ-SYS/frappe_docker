---
type: skill
name: Commit Message
description: Generate commit messages that follow conventional commits and repository scope conventions. Use when Creating git commits after code changes, Writing commit messages for staged changes, or Following conventional commit format for the project
skillSlug: commit-message
phases: [E, C]
generated: 2026-04-21
status: filled
scaffoldVersion: "2.0.0"
---

## When to Use

Every commit in `frappe_docker` follows the Conventional Commits spec. The recent git log confirms this:

- `fix: remove nested sites assets volume`
- `docs: document volume migration notes for sites/assets change`
- `fix: removed sites/assets volume from custom & production Containerfile too`
- `docs: move sites/assets volume upgrade note to migration docs`
- `chore: Update example.env` (produced by CI automation).

Use this skill whenever you stage changes in this repo — trunk-based development means every commit reaches `main` quickly, so the log must stay legible.

## Instructions

1. Review staged changes with `git diff --staged` before writing the message.
2. Pick a type: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `build`.
3. Optionally add a scope reflecting the affected area: `compose`, `overrides`, `images`, `docs`, `tests`, `ci`, `env`.
4. Write the subject in lowercase imperative mood, no trailing period, ≤72 characters.
5. Keep one logical change per commit — never mix an override change and a docs fix in the same commit unless they are inseparable.
6. When the change is non-obvious (security, performance, upstream regression), add a body explaining WHY.
7. Reference GitHub issues or PRs when relevant (`Closes #1879`).

## Examples

- `fix: remove nested sites assets volume`
- `docs: document volume migration notes for sites/assets change`
- `chore: Update example.env` (ERPNEXT_VERSION bump via CI)
- `feat(overrides): add s3-compatible backup override`
- `test(tests): cover postgres override in ci harness`
- `ci: pin pre-commit autoupdate to quarterly schedule`
- `refactor(compose): extract x-backend-defaults anchor`

## Guidelines

- Never mix scopes. Split the commit instead.
- Do not capitalize the subject — match existing style (`fix: remove ...`, not `Fix: Remove ...`).
- Avoid vague subjects like `fix: bug` or `chore: cleanup`; be specific.
- Keep body lines wrapped at 72 characters.
- Do not reference Claude or automation signatures in commit bodies unless the user explicitly asks.
- For user-facing changes, pair the commit with a `docs:` commit if the docs sit in a separate patch.
