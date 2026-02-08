# Workflow Contracts

This directory contains the contract specifications for all reusable workflows in the devops platform.

## Purpose

Workflow contracts document the stable API surface of each reusable workflow:
- Inputs, outputs, and their types
- Required secrets and permissions
- Expected behavior and guarantees
- Breaking change policy

## Available Contracts

| Workflow | Version | Status |
|----------|---------|--------|
| [reusable-ci.yml](reusable-ci.md) | v1 | Stable |
| [reusable-cd-nuxt-ssg.yml](reusable-cd-nuxt-ssg.md) | v1 | Stable |

## Governance

Changes to workflow contracts require:
1. Platform owner approval (enforced via CODEOWNERS)
2. Adherence to [versioning policy](../versioning-policy.md)
3. 60-day deprecation window for breaking changes

## Adding New Contracts

When creating a new reusable workflow:
1. Create a contract document in this directory
2. Follow the template structure from existing contracts
3. Add entry to CODEOWNERS for review enforcement
