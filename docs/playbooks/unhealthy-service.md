# Unhealthy Service Playbook

**Trigger:** A running service becomes unresponsive or unhealthy after a
previously successful deploy.

## Symptoms

- Site returns 502/503/504 errors
- Health endpoint stops responding
- Docker reports container as "unhealthy"
- Nginx Proxy Manager shows backend offline

## Immediate Actions

### 1. Verify the issue

```bash
# From your local machine
curl -I https://<domain>/health

# From the server (bypasses proxy)
ssh -p <port> <user>@<host>
curl -v http://localhost:<container-port>/health
```

### 2. Check container status

```bash
cd /mnt/ssd1000-01/projects/<project>/<environment>

# Container running?
docker compose ps

# Health status
docker inspect --format='{{.State.Health.Status}}' <container-id>

# Recent logs
docker compose logs --tail=100 --timestamps <service>
```

### 3. Check system resources

```bash
# Disk space
df -h

# Memory
free -h

# Docker disk usage
docker system df
```

## Common Causes

| Cause | Fix |
|-------|-----|
| Out of memory | Restart container, investigate memory leak |
| Disk full | Clean up old images: `docker system prune -a` |
| Container crash | Check logs, restart or rollback |
| Network issue | Check Docker networks, restart Docker daemon |
| Upstream dependency down | Check external API status |

## Recovery Options

### Option 1: Restart the container

```bash
docker compose restart <service>
```

If the issue is transient (OOM kill, temporary network glitch), a restart
often resolves it.

### Option 2: Recreate the container

```bash
docker compose up -d --force-recreate --no-deps <service>
```

This creates a fresh container from the same image.

### Option 3: Rollback to previous image

See [Rollback Playbook](rollback.md).

## Nginx Proxy Manager Issues

If the container is healthy but the site is unreachable:

1. Log into Nginx Proxy Manager UI
2. Check the proxy host configuration
3. Verify the upstream IP/port matches the container
4. Check SSL certificate status
5. Review NPM access logs

## Post-Incident

1. Document the root cause in Shortcut
2. If resource-related, consider adjusting container limits
3. If recurring, add monitoring/alerting
4. Update playbooks if new failure mode discovered

## Runbook Commands

```bash
# Quick health check sequence
ssh -p 2222 deploy@server.example.com
cd /mnt/ssd1000-01/projects/site-marcel/production

docker compose ps
docker compose logs --tail=20 web
curl http://localhost:3000/health

# If unhealthy, restart
docker compose restart web
sleep 5
curl http://localhost:3000/health

# If still failing, check resources
df -h /mnt/ssd1000-01
free -h
docker stats --no-stream
```
