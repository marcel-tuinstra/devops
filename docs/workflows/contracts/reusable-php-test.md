# Workflow Contract: reusable-php-test.yml

**Version:** v1  
**Status:** Stable  
**Last Updated:** 2026-02-10

## Purpose

Reusable CI workflow for PHP projects. Runs PHPUnit tests with optional PostgreSQL service, coverage reporting, and diff-coverage enforcement on changed lines.

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
| `test-suites` | string | No | `""` | Comma-separated test suites (empty = all) |
| `database` | string | No | `"sqlite"` | Database: sqlite or postgres |
| `postgres-version` | string | No | `"16"` | PostgreSQL version (when database=postgres) |
| `coverage` | boolean | No | `false` | Generate coverage report |
| `diff-coverage-threshold` | string | No | `"0"` | Min % on changed lines (0 = disabled) |
| `run-migrations` | boolean | No | `true` | Run Doctrine migrations before tests |
| `workdir` | string | No | `"."` | Working directory |

## Outputs

| Output | Description |
|--------|-------------|
| `coverage-percentage` | Overall coverage percentage (when coverage=true) |

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
| `test` | Runs PHPUnit tests with optional coverage |

## Expected Behavior

1. Checkout code with full history (for diff-cover)
2. Setup PHP with specified version, extensions, and coverage driver (xdebug if coverage=true)
3. Start PostgreSQL service container (if database=postgres)
4. Cache Composer dependencies
5. Install dependencies via `composer install`
6. Create test directories
7. Run Doctrine migrations (if run-migrations=true)
8. Run PHPUnit (with or without coverage)
9. Install diff-cover (Python) if coverage + threshold configured
10. Enforce diff coverage threshold on PR (compares against base branch)
11. Upload coverage artifact

### Diff Coverage

When `coverage=true` and `diff-coverage-threshold` > 0:
- Uses [diff-cover](https://github.com/Bachmann1234/diff_cover) to check coverage on changed lines only
- Only enforced on pull requests (compares against `github.base_ref`)
- Allows gradual coverage improvement without requiring overall coverage threshold

## Breaking Change Policy

See [versioning-policy.md](../versioning-policy.md) for major version upgrade procedures.

Changes that require a major version bump:
- Removing or renaming existing inputs
- Changing default values in breaking ways
- Changing required permissions
- Changing database connection behavior

## Example Caller

```yaml
name: Tests

on:
  pull_request:
  push:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  # Simple test without coverage
  test:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-php-test.yml@v1
    with:
      php-version: "8.4"
      database: "postgres"

  # Test with coverage and diff-coverage enforcement
  test-coverage:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-php-test.yml@v1
    with:
      php-version: "8.4"
      database: "postgres"
      coverage: true
      diff-coverage-threshold: "70"

  # Test specific suites
  test-suites:
    uses: marcel-tuinstra/devops/.github/workflows/reusable-php-test.yml@v1
    with:
      test-suites: "Unit, Integration, Functional"
      database: "sqlite"
```
