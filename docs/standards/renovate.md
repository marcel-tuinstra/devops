# Renovate Presets

This repo provides shared Renovate presets that consumer repos can extend
for consistent dependency update behavior across all projects.

## Available Presets

| Preset | Use Case |
|--------|----------|
| `renovate/default.json` | Base preset for all repos |
| `renovate/nuxt.json` | Nuxt/Vue projects |
| `renovate/symfony.json` | Symfony/PHP projects |

## Usage

In your consumer repo, create a `renovate.json` file that extends the
appropriate preset:

### Nuxt Projects

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "github>marcel-tuinstra/devops:renovate/nuxt"
  ]
}
```

### Symfony Projects

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "github>marcel-tuinstra/devops:renovate/symfony"
  ]
}
```

## Default Behavior

All presets inherit from `renovate/default.json` which provides:

- **Base branch:** `develop` (updates target develop, not main)
- **Automerge patches:** Patch updates merge automatically after CI passes
- **Group minor updates:** Minor updates are batched into a single PR
- **Pin Docker digests:** Docker images are pinned to immutable digests
- **Security priority:** Vulnerability alerts get `security` and `priority` labels
- **Lock file maintenance:** Weekly lock file refresh (Monday before 6am)

## Package Grouping

### Nuxt Preset

Groups related packages to reduce PR noise:

- `nuxt` — Nuxt core and plugins
- `vue` — Vue core and utilities
- `nuxt-ui` — Nuxt UI components
- `typescript` — TypeScript and type definitions
- `eslint` — ESLint and plugins
- `tailwind` — Tailwind CSS and plugins

### Symfony Preset

Groups PHP ecosystem packages:

- `symfony` — Symfony framework and bundles
- `doctrine` — Doctrine ORM and migrations
- `phpstan` — PHPStan static analysis
- `coding-standards` — PHP-CS-Fixer and Symplify
- `api-platform` — API Platform packages

## Overriding Settings

Consumer repos can override any setting by adding it after the extends:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "github>marcel-tuinstra/devops:renovate/nuxt"
  ],
  "automerge": false,
  "schedule": ["after 10pm and before 5am every weekday"]
}
```

## Requirements

- The `marcel-tuinstra/devops` repo must be public (it is).
- Consumer repos must have Renovate GitHub App installed.
- Consumer repos must have a `develop` branch (per branching strategy).
