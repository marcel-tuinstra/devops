# Reusable Workflow Versioning Policy

## Goals

- Keep consumer repositories stable during workflow evolution.
- Allow safe validation of upcoming changes.
- Provide clear communication and migration guidance for breaking changes.

## Channels

- Stable channel:
  - `@v1` for generally available workflows.
- Next major channel:
  - `@v2` after breaking-change rollout.
- Canary channel:
  - `@main` for rapid validation.
  - Optional rolling preview tag `@v1-next` for controlled canary testing.

## Release Semantics

- Patch:
  - Non-functional fixes, minor hardening, documentation updates.
  - No input or behavior changes for callers.
- Minor:
  - Backward-compatible new inputs with defaults.
  - Additional optional jobs or diagnostics.
- Major:
  - Input changes, output changes, job contract changes, or behavior shifts.
  - Requires new major tag (`v2`, `v3`, ...).

## Compatibility Rules

- Existing required inputs may not be removed in stable major versions.
- New inputs must be optional or include safe defaults.
- Deprecations require a written migration path.

## Deprecation Window

- Minimum deprecation period: 60 days.
- Breaking changes must be announced before release of a new major.
- Stable major remains patched for critical fixes during deprecation window.

## Rollout Strategy

1. Ship change to canary (`@main` or `@v1-next`).
2. Validate in designated canary repositories.
3. Promote to stable major after validation.
4. Monitor and keep rollback path available.

## Rollback and Fallback

- Rollback mechanism: switch caller workflow back to previous tag (`@v1`).
- For urgent regressions, pin caller to known-good commit SHA temporarily.
- Document every rollback in release notes.

## Changelog Format

Each reusable workflow release includes:

- `Changed`: behavior and implementation updates.
- `Impact`: consumer-facing effect.
- `Action Required`: migration steps when needed.
- `Rollback`: safe fallback instructions.

## Communication Template

Release title example:

`workflow-release: reusable-ci v1.4.0`

Release message:

- Scope and reason for the change.
- Compatibility statement.
- Effective date and rollout plan.
- Link to migration checklist when applicable.

## Migration Checklist (v1 -> v2)

- Inventory repositories currently pinned to `@v1`.
- Validate `@v2` in canary repositories.
- Update caller workflow references from `@v1` to `@v2`.
- Verify environment secrets and required permissions.
- Run repository CI and deployment smoke tests.
- Keep rollback instruction (`@v1`) prepared until stabilization.
