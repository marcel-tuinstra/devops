# Auth Outage Playbook

**Trigger:** Auth0 service disruption affecting user authentication.

## Symptoms

- Users cannot log in
- Auth0 API calls return 5xx errors
- Auth0 status page shows incident
- Application auth endpoints timeout

## Immediate Actions

### 1. Check Auth0 status

Visit: https://status.auth0.com/

Check for:
- Current incidents
- Affected regions (EU, US, AU)
- Estimated resolution time

### 2. Verify it's Auth0, not your app

```bash
# Test Auth0 directly
curl -I https://<your-tenant>.eu.auth0.com/

# Check your application's auth endpoint
curl -I https://<your-domain>/api/auth/session
```

### 3. Check application logs

```bash
ssh -p <port> <user>@<host>
cd /mnt/ssd1000-01/projects/<project>/<environment>
docker compose logs --tail=100 <service> | grep -i auth
```

## Response Based on Scope

### Auth0 is down (confirmed via status page)

1. **Wait and monitor** — Auth0 incidents are usually resolved within 30 minutes
2. **Communicate** — If user-facing, post status update
3. **Do NOT restart your services** — won't help
4. **Monitor status page** for resolution

### Auth0 is up, but your app can't reach it

Check:
1. **Network:** Can the container reach the internet?
2. **DNS:** Is Auth0 domain resolving?
3. **Firewall:** Are outbound connections blocked?
4. **Credentials:** Did Auth0 secrets expire or get rotated?

```bash
# From inside container
docker compose exec <service> sh
curl -I https://<tenant>.eu.auth0.com/
```

## Auth0 Tenant Issues (Not Global Outage)

If Auth0 status is green but your tenant has issues:

1. Log into Auth0 Dashboard
2. Check Logs > Logs for error patterns
3. Review Applications > Settings for misconfigurations
4. Check Rules/Actions for errors

## Failover Options

For critical applications, consider:

### Option A: Graceful degradation

- Allow read-only access without auth
- Queue actions that require auth
- Show maintenance message for protected routes

### Option B: Cached sessions

- If sessions are stored server-side, existing users stay logged in
- Disable new logins temporarily
- Clear cache after Auth0 recovers

### Option C: Alternative IdP (requires pre-configuration)

- Failover to backup identity provider
- Requires federation setup in advance

## Post-Incident

1. Review Auth0 post-mortem when published
2. Document impact and timeline in Shortcut
3. Consider:
   - Adding Auth0 status to monitoring
   - Implementing graceful degradation
   - Caching strategies for auth tokens

## Runbook Commands

```bash
# Check Auth0 connectivity from server
ssh -p 2222 deploy@server.example.com
curl -I https://tuinstra-dev.eu.auth0.com/

# Check application auth logs
cd /mnt/ssd1000-01/projects/<project>/production
docker compose logs --tail=50 <service> 2>&1 | grep -iE "(auth|token|login)"

# Test auth endpoint
curl -v https://<domain>/api/auth/session
```

## Auth0 Support

For tenant-specific issues:

- **Free tier:** Community forums only
- **Paid plans:** support.auth0.com
- **Critical:** Premium support has priority response
