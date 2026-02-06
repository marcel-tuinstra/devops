# Shared Deploy Script

`scripts/deploy-service.sh` provides a generic Docker Compose deploy flow with:

- health check polling,
- rollback to last-known-good image on failure,
- JSON state tracking for each service.

## Usage

```bash
./scripts/deploy-service.sh \
  --service web \
  --image ghcr.io/marcel-tuinstra/site-marcel:sha-abcdef \
  --health-url http://localhost:8080/health \
  --timeout 180 \
  --compose-file docker-compose.yml \
  --state-file .deploy-state.json
```

## Parameters

- `--service`: Docker Compose service name.
- `--image`: fully qualified image reference.
- `--health-url`: URL returning success when deployment is healthy.
- `--timeout`: maximum wait in seconds for health checks.
- `--interval`: polling interval in seconds.
- `--compose-file`: compose file path.
- `--state-file`: JSON file for last-known-good tracking.

## Behavior

1. Deploy target image to the selected Compose service.
2. Poll health endpoint until healthy or timeout.
3. On success, record image as last-known-good in JSON state.
4. On failure, rollback to previously stored image and verify health again.
