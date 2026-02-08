# Health Check Standard

Every deployed service exposes a `/health` endpoint that the CD pipeline
uses to verify a successful deploy. The endpoint must return HTTP 200
with a known body so both automated checks and manual debugging work the
same way.

## Per-stack patterns

### Nuxt SSG (static site, nginx)

A static file at `public/health` containing a single line: `ok`.

- Template: `templates/health/nuxt-ssg-health.txt`
- The file is copied into the nginx html root during the Docker build.
- No runtime logic — nginx serves it as a plain text file.

### Nuxt SSR (server-rendered)

A Nitro server route at `server/api/health.get.ts` returning JSON:

```json
{ "status": "ok", "timestamp": "2026-02-08T12:00:00.000Z" }
```

- Template: `templates/health/nuxt-ssr-health.ts`
- The timestamp helps confirm the running instance was recently started.
- Extend with database or cache checks if needed in the future.

### Symfony (future)

A dedicated `/health` controller returning `{ "status": "ok" }` with
optional database connectivity check. Templates will be added when the
first Symfony project is onboarded.

## Docker HEALTHCHECK

Add a `HEALTHCHECK` instruction to the Dockerfile so Docker itself can
track container health independently of the CD pipeline:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1
```

- For nginx-based images, `curl` must be installed (alpine: `apk add --no-cache curl`).
- For Node-based images (SSR), replace port `80` with the Nitro listen port (default `3000`).

## Compose healthcheck

The compose file should mirror the Dockerfile health check for
orchestration-level awareness:

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/health"]
      interval: 30s
      timeout: 3s
      start_period: 5s
      retries: 3
```

See `templates/compose/service-compose.yml` for the full template.

## CD pipeline verification

The reusable CD workflow (`reusable-cd-nuxt-ssg.yml`) runs a post-deploy
health check over SSH:

1. Resolves the host port via `docker compose port <service> 80`.
2. Polls `curl -fsS http://localhost:<host-port>/health` every 5 seconds.
3. Fails the deploy after 180 seconds if the endpoint never responds 200.

This runs on the server itself (via SSH), bypassing DNS and reverse proxy
so deploys succeed even before DNS propagation completes.

## Compatibility notes

- The health endpoint path is always `/health` (no trailing slash).
- SSG returns plain text `ok`; SSR returns JSON. The CD pipeline only
  checks for HTTP 200 — it does not parse the body.
- Nginx Proxy Manager and any reverse proxy must not block `/health`.
