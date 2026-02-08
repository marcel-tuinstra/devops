# Failed Deploy Playbook

**Trigger:** CD workflow health check fails after deploying a new image.

## Symptoms

- GitHub Actions CD job fails at "Health check" step
- Error message: "Health check failed on localhost:<port>/health"
- New container is running but not responding

## Immediate Actions

### 1. Check the CD workflow logs

```bash
gh run view <run-id> --log
```

Look for:
- Image pull errors
- Container startup errors
- Health check timeout details

### 2. SSH to server and check container status

```bash
ssh -p <port> <user>@<host>
cd /mnt/ssd1000-01/projects/<project>/<environment>

# Check container status
docker compose ps

# Check container logs
docker compose logs --tail=100 <service>

# Check if health endpoint responds locally
curl -v http://localhost:<container-port>/health
```

### 3. Check Docker health status

```bash
docker inspect --format='{{.State.Health.Status}}' <container-id>
docker inspect --format='{{json .State.Health}}' <container-id> | jq
```

## Common Causes

| Cause | Fix |
|-------|-----|
| Missing health file | Ensure `public/health` exists with content `ok` |
| Nginx not serving static files | Check Dockerfile COPY paths |
| Container crash loop | Check `docker compose logs` for startup errors |
| Port mismatch | Verify compose file port mapping matches workflow input |
| Build failure (silent) | Check if `.output/public` was generated |

## Auto-Rollback

The CD workflow includes automatic rollback on health check failure.
If the previous deploy succeeded, the service should recover automatically.

If this is the first deploy (no previous image), manual intervention is required.

## Manual Recovery

### Option A: Fix forward

1. Identify the issue from logs
2. Push a fix to the branch that triggered the deploy
3. Wait for new CD run

### Option B: Rollback to previous image

See [Rollback Playbook](rollback.md) for manual rollback steps.

## Post-Incident

1. Add a comment to the Shortcut story with root cause
2. If a workflow or template change is needed, create a new story
3. Consider adding the failure scenario to the game-day template

## Runbook Commands (Nuxt SSG)

```bash
# SSH to server
ssh -p 2222 deploy@server.example.com

# Navigate to project
cd /mnt/ssd1000-01/projects/site-marcel/production

# Check current state
docker compose ps
docker compose logs --tail=50 web

# Test health endpoint from server
curl -v http://localhost:3000/health

# Restart container (keeps same image)
docker compose restart web

# Force pull and recreate
docker compose pull web
docker compose up -d --no-deps web
```
