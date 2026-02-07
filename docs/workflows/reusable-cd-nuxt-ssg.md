# Reusable CD Workflow for Nuxt SSG

Workflow: `.github/workflows/reusable-cd-nuxt-ssg.yml`

## What it does

- Builds static Nuxt output into an nginx runtime image.
- Pushes image to GHCR.
- Uploads the compose file from the consumer repo to the target host via SCP.
- Deploys immutable image digest via SSH to a Docker Compose host.
- Verifies deployment health using a configurable endpoint.

## Required inputs

- `service-name` — Docker Compose service name on target host
- `image-name` — Full GHCR image name without tag
- `health-url` — Health endpoint URL on target host
- `environment` — GitHub Environment name (`staging` or `production`)
- `remote-path` — Deploy path on target host (compose file is uploaded here automatically)
- `ssh-user` — SSH user for deploy host

## Required environment configuration

The deploy job runs within the specified GitHub Environment and reads SSH configuration directly from environment-level vars/secrets:

| Type | Name | Description |
|---|---|---|
| Variable | `SSH_HOST` | Hostname or IP of the deployment target |
| Secret | `SSH_PRIVATE_KEY` | SSH private key for authentication |

Configure these per environment (staging/production) in your repository settings.

## Why environment-level?

GitHub Actions resolves `vars` and `secrets` at the workflow level where they're referenced. By setting the `environment` on the deploy job and reading SSH config directly within that job's steps, GitHub correctly resolves the environment-specific values. This ensures proper environment isolation — staging and production can have different hosts and keys without risk of cross-contamination.

## Example callers

- Staging example: `templates/workflows/caller-cd-nuxt-staging.yml`
- Production example: `templates/workflows/caller-cd-nuxt-production.yml`

## Migration from v1.0 (breaking change)

v1.1 removes the `ssh-host` input and `ssh-private-key` secret from the workflow interface. Update your caller workflows:

**Before (v1.0):**
```yaml
jobs:
  deploy:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-cd-nuxt-ssg.yml@v1
    with:
      ssh-host: ${{ vars.SSH_STAGING_HOST }}
    secrets:
      ssh-private-key: ${{ secrets.SSH_STAGING_PRIVATE_KEY }}
```

**After (v1.1):**
```yaml
jobs:
  deploy:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-cd-nuxt-ssg.yml@v1
    # No ssh-host input, no ssh-private-key secret
    # These are read automatically from the environment
```

Rename your environment variables/secrets:
- `SSH_STAGING_HOST` → `SSH_HOST` (in staging environment)
- `SSH_STAGING_PRIVATE_KEY` → `SSH_PRIVATE_KEY` (in staging environment)
- `SSH_PRODUCTION_HOST` → `SSH_HOST` (in production environment)
- `SSH_PRODUCTION_PRIVATE_KEY` → `SSH_PRIVATE_KEY` (in production environment)
