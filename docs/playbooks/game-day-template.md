# Game Day Template

A game day is a planned incident simulation to validate playbooks and
practice incident response. Run these on **staging only**.

## Pre-Game Checklist

- [ ] Notify team that game day is happening
- [ ] Ensure staging environment is stable
- [ ] Have rollback procedure ready
- [ ] Set a time limit (e.g., 30 minutes max)
- [ ] Designate an observer to take notes

## Scenario 1: Failed Deploy

**Objective:** Verify CD auto-rollback and manual recovery.

### Setup

1. Create a branch with a broken Dockerfile:

```dockerfile
# Add after the build stage
RUN exit 1  # Force build failure
```

2. Or break the health endpoint:

```bash
# Remove the health file
rm public/health
```

3. Push to `develop` to trigger staging deploy

### Expected Outcome

- CD workflow should fail at health check
- Auto-rollback should restore previous version
- Site should remain accessible

### Validation

```bash
# Check site is still up
curl https://staging.<domain>/health

# Check workflow logs show rollback
gh run view <run-id>

# Verify correct image is running
ssh -p <port> <user>@<host>
docker compose ps
```

### Cleanup

```bash
git revert HEAD
git push
```

## Scenario 2: Container Crash

**Objective:** Practice unhealthy service recovery.

### Setup

```bash
ssh -p <port> <user>@<host>
cd /mnt/ssd1000-01/projects/<project>/staging

# Kill the container
docker compose kill <service>
```

### Expected Outcome

- Site becomes unreachable
- Manual restart restores service

### Validation

```bash
# Confirm site is down
curl -I https://staging.<domain>/health

# Restart
docker compose up -d <service>

# Confirm recovery
curl https://staging.<domain>/health
```

## Scenario 3: Resource Exhaustion

**Objective:** Practice diagnosing resource issues.

### Setup

```bash
# Create a large file to fill disk (be careful!)
ssh -p <port> <user>@<host>
dd if=/dev/zero of=/tmp/fillup bs=1M count=1000
```

### Validation

```bash
# Check disk usage
df -h

# Clean up
rm /tmp/fillup

# Verify services still work
docker compose ps
```

## Scenario 4: Rollback Drill

**Objective:** Practice manual rollback to previous image.

### Setup

1. Note the current image digest
2. Deploy a new version (any small change)
3. Pretend the new version is broken

### Execution

Follow the [Rollback Playbook](rollback.md) to:

1. Find previous image digest
2. Create override file
3. Deploy previous image
4. Verify health

### Validation

- Rollback completes without errors
- Health check passes
- Application functions correctly

## Post-Game Review

After each game day:

1. **What went well?**
2. **What was confusing or slow?**
3. **What documentation was missing?**
4. **What tooling would help?**

Update playbooks with lessons learned.

## Game Day Log Template

```markdown
## Game Day: [Date]

**Scenario:** [Which scenario]
**Environment:** Staging
**Duration:** [X minutes]
**Participants:** [Names]

### Timeline

- HH:MM — Started scenario
- HH:MM — Detected issue via [method]
- HH:MM — Began recovery
- HH:MM — Recovery complete

### Observations

- [What went well]
- [What was difficult]

### Action Items

- [ ] [Playbook update needed]
- [ ] [Tooling improvement]
```

## Frequency

Recommended: Run one game day scenario per quarter, rotating through
different scenarios.
