# Branching Strategy

## Overview

All consumer repositories use a two-branch model with environment-linked deployments.

## Branches

| Branch | Purpose | Deploys to | Trigger |
|---|---|---|---|
| `develop` | Integration branch | Staging | Push |
| `main` | Production-ready code | Production | Push |
| `feat/SC-<id>` | Feature work | — | PR to `develop` |
| `chore/SC-<id>` | Chores / maintenance | — | PR to `develop` |
| `bug/SC-<id>` | Bug fixes | — | PR to `develop` |

## Flow

```
feature branch ──PR──> develop ──release PR──> main
                          │                      │
                     Deploy Staging         Deploy Production
```

1. Create a feature branch from `develop` (e.g. `feat/SC-123`).
2. Open a PR targeting `develop`. CI runs automatically.
3. Merge to `develop` — triggers Deploy Staging.
4. Verify on staging.
5. When ready for production: run the **Create Release PR** workflow (`workflow_dispatch`).
6. This creates a PR from `develop` → `main` with a changelog of all commits.
7. Merge the release PR — triggers Deploy Production.

## Release PR

Each consumer repo has a `.github/workflows/release.yml` workflow that creates a release PR:

- **Trigger**: Manual via `workflow_dispatch` (GitHub Actions "Run workflow" button)
- **Title**: `release: YYYY-MM-DD` (appends `.N` if a release PR already exists for that date)
- **Body**: Auto-generated list of commits on `develop` not yet in `main`
- **Effect of merge**: Pushes to `main` → triggers Deploy Production via CD workflow

No git tags or GitHub Releases are created on consumer repos. The release PR is the audit trail. The Docker image digest (pinned during CD) is the rollback unit.

See `templates/workflows/caller-release-pr.yml` for the workflow template.

## Repositories using this strategy

| Repo | Develop | Main | Notes |
|---|---|---|---|
| site-marcel | Staging (port 3100) | Production (port 3000) | Active |
| site-tuinstra | Staging (port 3101) | Production (port 3001) | Active |

## Exceptions

The **devops** repo itself does NOT use this model. It uses story-driven branches merged directly to `main`, with tag-based releases (`v1`, `v2`). See `release-procedure.md`.

## Branch protection

Branch protection rules on `main` (require PR, require CI) are recommended but not currently enforced — GitHub free plan for non-org accounts does not support branch protection on private repos. This will be revisited when repos move to an organization.
