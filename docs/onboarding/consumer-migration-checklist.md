# Consumer Migration Checklist

Step-by-step guide for integrating a consumer repository with the devops reusable workflows.

## Prerequisites

- Consumer repo hosted on GitHub under `marcel-tuinstra` (or an org with access).
- Docker installed locally for testing container builds.
- SSH access to the target deployment server.

## 1. Dockerfile

Create a `Dockerfile` in the consumer repo root. Use the template at
`templates/docker/nuxt-ssg-nginx.Dockerfile` as a starting point:

```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run generate

FROM nginx:1.27-alpine
COPY --from=builder /app/.output/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Adjust the build command and output path to match your project.

## 2. Health Endpoint

Ensure your application serves a health endpoint (e.g. `/health`) that returns HTTP 200.
For static sites behind nginx, a simple static file or nginx location block works:

```nginx
location = /health {
    return 200 'ok';
    add_header Content-Type text/plain;
}
```

## 3. GitHub Environments

Create two GitHub Environments in your consumer repo settings:

| Environment | Purpose |
|---|---|
| `staging` | Auto-deploys on push to `main` |
| `production` | Manual deploy via `workflow_dispatch` (add required reviewers) |

## 4. Secrets and Variables (Environment-level)

The reusable CD workflow reads SSH configuration directly from each environment. Configure these **per environment**:

### Staging Environment

| Type | Name | Value |
|---|---|---|
| Secret | `SSH_PRIVATE_KEY` | SSH private key for the staging server |
| Variable | `SSH_HOST` | Hostname or IP of the staging server |

### Production Environment

| Type | Name | Value |
|---|---|---|
| Secret | `SSH_PRIVATE_KEY` | SSH private key for the production server |
| Variable | `SSH_HOST` | Hostname or IP of the production server |

> **Important:** These must be configured at the **environment level**, not repository level. The workflow sets `environment: staging` or `environment: production` on the deploy job, and GitHub resolves the vars/secrets from that specific environment context.

## 5. Caller Workflows

Copy the caller workflow templates from this repo into your consumer repo:

```bash
# From the consumer repo root:
mkdir -p .github/workflows

# Copy and customize:
cp <devops-repo>/templates/workflows/caller-cd-nuxt-staging.yml .github/workflows/deploy-staging.yml
cp <devops-repo>/templates/workflows/caller-cd-nuxt-production.yml .github/workflows/deploy-production.yml
```

Replace all `<YOUR-...>` placeholders with actual values for your project.

Note: The caller workflows do NOT pass SSH host or private key — these are read automatically from the environment configuration you set in step 4.

For CI (lint + typecheck + build):

```yaml
# .github/workflows/ci.yml
name: CI
on:
  pull_request:
    branches: [main]
jobs:
  ci:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-ci.yml@v1
```

## 6. Server Preparation

On each target server:

1. Create the deploy user: `sudo adduser deploy`
2. Add the deploy user's SSH public key to `~/.ssh/authorized_keys`
3. Install Docker and Docker Compose
4. Create the remote path directory (e.g. `/srv/site-marcel`)
5. Place a `docker-compose.yml` in the remote path (see `templates/compose/service-compose.yml`)

## 7. Validation

After setup, verify end-to-end:

1. **CI**: Open a PR and confirm the reusable CI workflow runs and passes.
2. **Staging CD**: Merge to `main` and confirm staging deployment succeeds.
3. **Health check**: Verify the health URL returns HTTP 200.
4. **Production CD**: Trigger a manual `workflow_dispatch` deploy and verify production.

## 8. Rollback

If a deployment fails:

- The reusable CD workflow includes automatic rollback on health check failure.
- Manual rollback: SSH to the server and run `docker compose up -d` with the previous image digest.
- Pin caller workflow to a known-good commit SHA if a workflow regression is suspected.

## Troubleshooting

| Symptom | Likely Cause |
|---|---|
| `image not found` during deploy | GHCR token missing or insufficient permissions |
| SSH connection refused | SSH key not configured or wrong host variable |
| `SSH_HOST` or `SSH_PRIVATE_KEY` not found | Secrets/vars configured at repo level instead of environment level |
| Health check timeout | Health endpoint not reachable or returns non-200 |
| `dockerfile not found` | Missing `Dockerfile` in consumer repo root |

## Breaking Changes from Earlier Versions

### v1.0 → v1.1

- **Removed**: `ssh-host` input and `ssh-private-key` secret from workflow interface
- **Changed**: SSH configuration now read directly from environment-level `SSH_HOST` (variable) and `SSH_PRIVATE_KEY` (secret)
- **Action required**: Rename environment variables/secrets and remove ssh-host/ssh-private-key from caller workflows
