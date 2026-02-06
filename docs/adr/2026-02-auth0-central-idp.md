# ADR: Auth0 as Central Identity Provider

- Status: proposed
- Date: 2026-02-06
- Related stories: SC-231, SC-232, SC-236, SC-237

## Context

AirportToday currently uses Keycloak and Subtrack uses a custom auth implementation. The DevOps platform requires a central identity model to reduce operational load and improve consistency.

## Decision

Use Auth0 as the central identity provider for the DevOps platform and for future alignment of AirportToday and Subtrack authentication.

## Rationale

- Reduces auth platform maintenance overhead.
- Improves security posture through managed controls.
- Enables faster integration into CI/CD and platform-level access policies.

## Consequences

- Requires migration planning for existing applications.
- Introduces recurring licensing cost.
- Creates dependency on a managed external identity service.
