# Workflow Contract: reusable-php-security.yml

**Version:** v1  
**Status:** Stable  
**Last Updated:** 2026-02-10

## Purpose

Reusable CI workflow for PHP projects. Runs Composer security audit to check for known vulnerabilities in dependencies.

## Trigger

```yaml
on:
  workflow_call:
```

## Inputs

| Input | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `php-version` | string | No | `"8.4"` | PHP version to use |
| `workdir` | string | No | `"."` | Working directory |
| `fail-on-vulnerabilities` | boolean | No | `true` | Fail if vulnerabilities are found |

## Outputs

None.

## Required Secrets

None. Use `secrets: inherit` if your project has private Composer dependencies.

## Required Permissions

```yaml
permissions:
  contents: read
```

## Jobs

| Job | Description |
|-----|-------------|
| `security` | Runs Composer security audit |

## Expected Behavior

1. Checkout code
2. Setup PHP with specified version
3. Cache Composer dependencies
4. Install dependencies via `composer install`
5. Run `composer audit` to check for vulnerabilities

### Vulnerability Handling

- By default, the workflow fails if any vulnerabilities are found
- Set `fail-on-vulnerabilities: false` to report vulnerabilities without failing

## Breaking Change Policy

See [versioning-policy.md](../versioning-policy.md) for major version upgrade procedures.

Changes that require a major version bump:
- Removing or renaming existing inputs
- Changing default values in breaking ways
- Changing required permissions

## Example Caller

```yaml
name: Security

on:
  pull_request:
  push:
    branches: [main, develop]
  schedule:
    # Run daily at 6am UTC
    - cron: '0 6 * * *'

jobs:
  security:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-php-security.yml@v1
    with:
      php-version: "8.4"
```
