# AGENTS

This repository is maintained through story-driven branches.

## Delivery Rules

- Branch naming: `feat/SC-<id>`.
- Every story must run `make lint` and `make test`.
- PR titles use `<type>[SC-<id>] <title>` where `<type>` is `feat`, `chore`, or `bug`.
- Do not merge story branches automatically.

## Release Tags

- Reusable workflows are consumed via major version tags (`v1`, `v2`, ...).
- After merging to `main`, update the tag: `make release-tag TAG=v1`.
- Never force-push `main`. Only force-push tags via `make release-tag`.
- See `docs/workflows/release-procedure.md` for full procedure.
