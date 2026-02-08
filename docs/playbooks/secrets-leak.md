# Secrets Leak Playbook

**Trigger:** Credentials, API keys, or other secrets are accidentally
exposed in logs, commits, or public repositories.

## Severity Assessment

| Exposure | Severity | Response Time |
|----------|----------|---------------|
| Production secrets in public repo | Critical | Immediate |
| Staging secrets in logs | High | Within 1 hour |
| Development secrets in private repo | Medium | Within 24 hours |

## Immediate Actions

### 1. Revoke the compromised credential

**Do this FIRST, before anything else.**

| Secret Type | Revocation |
|-------------|------------|
| GitHub token | GitHub > Settings > Developer settings > Personal access tokens > Delete |
| SSH key | Remove from `~/.ssh/authorized_keys` on server, delete in GitHub |
| GHCR token | GitHub > Settings > Developer settings > Personal access tokens |
| Auth0 secret | Auth0 Dashboard > Applications > Rotate secret |
| Database password | Change via hosting provider or direct DB access |
| API key (3rd party) | Provider's dashboard |

### 2. Rotate the credential

Generate a new credential immediately after revoking the old one.

### 3. Update secrets in GitHub

```bash
# Update repository secret
gh secret set <SECRET_NAME> --body "<new-value>"

# Or for environment-specific
gh secret set <SECRET_NAME> --env production --body "<new-value>"
```

### 4. Redeploy affected services

Trigger a new deploy to pick up the rotated credentials:

```bash
gh workflow run deploy-production.yml
```

## If Secret Was in Git History

### For commits not yet pushed

```bash
# Amend the last commit
git reset HEAD~1
# Remove the secret, recommit
```

### For pushed commits

1. **Do NOT force-push main** (protected)
2. Remove the secret from current code
3. Commit the removal
4. Consider the secret permanently compromised — always rotate
5. If repo is public, contact GitHub support to scrub from cache

### Using git-filter-repo (nuclear option)

Only for private repos where history rewrite is acceptable:

```bash
# Install git-filter-repo
pip install git-filter-repo

# Remove file containing secret from all history
git filter-repo --path <file-with-secret> --invert-paths

# Force push (requires temporarily disabling branch protection)
git push --force
```

## If Secret Was in Logs

### GitHub Actions logs

1. Go to the workflow run
2. Click the gear icon > "Delete all logs"
3. Note: logs may be cached — rotate the secret anyway

### Server logs

```bash
ssh -p <port> <user>@<host>
# Identify and remove log files containing secrets
sudo rm /var/log/<relevant-logs>
```

## Audit for Unauthorized Access

After rotating:

1. Check Auth0 logs for suspicious logins
2. Review GitHub audit log for the organization
3. Check GHCR for unexpected image pushes
4. Review server access logs

## Post-Incident

1. Document in Shortcut with timeline
2. Identify how the leak happened
3. Add safeguards:
   - Pre-commit hooks to detect secrets
   - GitHub secret scanning alerts
   - Review `.gitignore` patterns
4. Update team on proper secrets handling

## Prevention Checklist

- [ ] `.env` files in `.gitignore`
- [ ] No hardcoded secrets in code
- [ ] GitHub secret scanning enabled
- [ ] Secrets only in GitHub Secrets / environment variables
- [ ] Mask secrets in workflow logs (`::add-mask::`)
