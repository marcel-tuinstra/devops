# Workflow Contract: reusable-cd-nuxt-ssg.yml

**Version:** v1  
**Status:** Stable  
**Last Updated:** 2026-02-08

## Purpose

Reusable CD workflow for deploying Nuxt SSG (static site generation) applications via Docker to a remote host.

## Trigger

```yaml
on:
  workflow_call:
```

## Inputs

| Input | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `service-name` | string | Yes | - | Docker Compose service name on target host |
| `image-name` | string | Yes | - | Full GHCR image name without tag |
| `health-url` | string | No | `""` | Public health URL (informational) |
| `port` | number | No | `80` | Exposed service port |
| `environment` | string | Yes | - | GitHub Environment name (staging/production) |
| `workdir` | string | No | `.` | Project working directory |
| `dockerfile` | string | No | `Dockerfile` | Dockerfile path relative to repo root |
| `remote-path` | string | Yes | - | Deploy path on target host |
| `ssh-user` | string | Yes | - | SSH user for deploy host |
| `ssh-port` | number | No | `22` | SSH port |
| `compose-file` | string | No | `docker-compose.yml` | Compose file path |
| `build-args` | string | No | `""` | Newline-separated Docker build args |

## Outputs

None exposed to caller. Internal outputs:

| Output | Source Job | Description |
|--------|-----------|-------------|
| `image-ref` | `build-and-push` | Immutable image reference with digest |

## Required Secrets

These must be configured in the GitHub Environment:

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | Ed25519 private key for deploy host access |

## Required Environment Variables

| Variable | Description |
|----------|-------------|
| `SSH_HOST` | Target host for deployment |

## Required Permissions

```yaml
permissions:
  contents: read
  packages: write
```

## Jobs

| Job | Description |
|-----|-------------|
| `build-and-push` | Build Docker image and push to GHCR |
| `deploy` | Deploy image to remote host via SSH |

## Expected Behavior

### build-and-push
1. Checkout code
2. Setup Docker Buildx
3. Login to GHCR
4. Build and push image with SHA tag
5. Output immutable image reference (digest)

### deploy
1. Checkout code
2. Configure SSH with environment secrets
3. Upload compose file to remote host
4. Deploy using digest-pinned image reference
5. Run health check on localhost (via SSH tunnel)

## Health Check Contract

The deployed container must:
- Expose a `/health` endpoint on the configured `port`
- Return HTTP 200 within 180 seconds of container start
- Health check runs via SSH on localhost, not public URL

## Breaking Change Policy

See [versioning-policy.md](../versioning-policy.md) for major version upgrade procedures.

Changes that require a major version bump:
- Removing or renaming existing inputs
- Changing required secrets or environment variables
- Modifying health check behavior
- Changing image tagging strategy

## Example Caller

```yaml
name: Deploy Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-cd-nuxt-ssg.yml@v1
    with:
      service-name: my-site
      image-name: ghcr.io/my-org/my-site
      environment: production
      remote-path: /opt/my-site
      ssh-user: deploy
    secrets: inherit
```
