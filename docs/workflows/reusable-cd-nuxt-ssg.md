# Reusable CD Workflow for Nuxt SSG

Workflow: `.github/workflows/reusable-cd-nuxt-ssg.yml`

## What it does

- Builds static Nuxt output into an nginx runtime image.
- Pushes image to GHCR.
- Deploys immutable image digest via SSH to a Docker Compose host.
- Verifies deployment health using a configurable endpoint.

## Required inputs

- `service-name`
- `image-name`
- `health-url`
- `environment` (`staging` or `production`)
- `remote-path`
- `ssh-user`
- `ssh-host`

## Required secret

- `ssh-private-key`

## Example callers

- Staging example: `templates/workflows/caller-cd-nuxt-staging.yml`
- Production example: `templates/workflows/caller-cd-nuxt-production.yml`
