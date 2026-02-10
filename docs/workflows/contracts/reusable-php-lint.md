# Workflow Contract: reusable-php-lint.yml

**Version:** v1  
**Status:** Stable  
**Last Updated:** 2026-02-10

## Purpose

Reusable CI workflow for PHP projects. Runs code style checking (PHP-CS-Fixer or ECS) and static analysis (PHPStan). Optionally runs Rector in dry-run mode.

## Trigger

```yaml
on:
  workflow_call:
```

## Inputs

| Input | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `php-version` | string | No | `"8.4"` | PHP version to use |
| `extensions` | string | No | `"intl, pdo_pgsql"` | Comma-separated PHP extensions |
| `phpstan-level` | string | No | `"max"` | PHPStan analysis level (1-9 or max) |
| `phpstan-config` | string | No | `""` | Path to custom phpstan.neon |
| `phpstan-memory-limit` | string | No | `"256M"` | Memory limit for PHPStan |
| `lint-tool` | string | No | `"php-cs-fixer"` | Lint tool: php-cs-fixer or ecs |
| `lint-paths` | string | No | `"src tests"` | Paths to lint (space-separated) |
| `run-rector` | boolean | No | `false` | Run Rector in dry-run mode |
| `workdir` | string | No | `"."` | Working directory |

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
| `lint` | Runs code style and static analysis checks |

## Expected Behavior

1. Checkout code
2. Setup PHP with specified version and extensions
3. Cache Composer dependencies
4. Install dependencies via `composer install`
5. Run PHP-CS-Fixer (if `lint-tool=php-cs-fixer`) or ECS (if `lint-tool=ecs`)
6. Run PHPStan with specified level and config
7. Run Rector dry-run (if `run-rector=true`)

## Breaking Change Policy

See [versioning-policy.md](../versioning-policy.md) for major version upgrade procedures.

Changes that require a major version bump:
- Removing or renaming existing inputs
- Changing default values in breaking ways
- Changing from non-failing to failing by default
- Changing required permissions

## Example Caller

```yaml
name: Lint

on:
  pull_request:
  push:
    branches: [main, develop]

jobs:
  lint:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-php-lint.yml@v1
    with:
      php-version: "8.4"
      phpstan-level: "8"
      lint-tool: "php-cs-fixer"

  # Alternative: for projects using ECS and Rector
  lint-ecs:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-php-lint.yml@v1
    with:
      php-version: "8.3"
      lint-tool: "ecs"
      run-rector: true
```
