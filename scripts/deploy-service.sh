#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  deploy-service.sh --service <name> --image <image-ref> --health-url <url> [options]

Options:
  --timeout <seconds>        Health check timeout (default: 180)
  --interval <seconds>       Health check interval (default: 5)
  --compose-file <path>      Docker Compose file (default: docker-compose.yml)
  --state-file <path>        Last-known-good state JSON (default: .deploy-state.json)
EOF
}

require_bin() {
  local bin=$1
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "Missing required command: $bin" >&2
    exit 2
  fi
}

SERVICE=""
IMAGE=""
HEALTH_URL=""
TIMEOUT=180
INTERVAL=5
COMPOSE_FILE="docker-compose.yml"
STATE_FILE=".deploy-state.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)
      SERVICE="$2"
      shift 2
      ;;
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --health-url)
      HEALTH_URL="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --interval)
      INTERVAL="$2"
      shift 2
      ;;
    --compose-file)
      COMPOSE_FILE="$2"
      shift 2
      ;;
    --state-file)
      STATE_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$SERVICE" || -z "$IMAGE" || -z "$HEALTH_URL" ]]; then
  echo "--service, --image and --health-url are required" >&2
  usage
  exit 2
fi

require_bin docker
require_bin curl
require_bin python3

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 2
fi

get_last_known_good() {
  if [[ ! -f "$STATE_FILE" ]]; then
    return 0
  fi

  python3 - "$STATE_FILE" "$SERVICE" <<'PY'
import json
import sys

state_file = sys.argv[1]
service = sys.argv[2]

try:
    with open(state_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)

services = data.get("services", {})
entry = services.get(service, {})
image = entry.get("image")
if image:
    print(image)
PY
}

write_last_known_good() {
  python3 - "$STATE_FILE" "$SERVICE" "$IMAGE" "$HEALTH_URL" <<'PY'
import json
from datetime import datetime, timezone
import os
import sys

state_file, service, image, health_url = sys.argv[1:5]
payload = {
    "services": {}
}

if os.path.exists(state_file):
    try:
        with open(state_file, "r", encoding="utf-8") as f:
            payload = json.load(f)
    except Exception:
        payload = {"services": {}}

services = payload.setdefault("services", {})
services[service] = {
    "image": image,
    "health_url": health_url,
    "deployed_at": datetime.now(timezone.utc).isoformat()
}

with open(state_file, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
PY
}

deploy_image() {
  local target_image=$1
  local override
  override=$(mktemp)
  cat > "$override" <<EOF
services:
  $SERVICE:
    image: $target_image
EOF

  docker compose -f "$COMPOSE_FILE" -f "$override" pull "$SERVICE"
  docker compose -f "$COMPOSE_FILE" -f "$override" up -d --no-deps "$SERVICE"
  rm -f "$override"
}

wait_for_health() {
  local deadline=$(( $(date +%s) + TIMEOUT ))

  while [[ $(date +%s) -lt $deadline ]]; do
    if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
      return 0
    fi

    sleep "$INTERVAL"
  done

  return 1
}

PREVIOUS_IMAGE="$(get_last_known_good || true)"

echo "Deploying service '$SERVICE' with image '$IMAGE'"
deploy_image "$IMAGE"

if wait_for_health; then
  echo "Service '$SERVICE' healthy, storing last-known-good image"
  write_last_known_good
  exit 0
fi

echo "Deployment health check failed for '$SERVICE'"

if [[ -n "$PREVIOUS_IMAGE" && "$PREVIOUS_IMAGE" != "$IMAGE" ]]; then
  echo "Rolling back service '$SERVICE' to '$PREVIOUS_IMAGE'"
  deploy_image "$PREVIOUS_IMAGE"

  if wait_for_health; then
    echo "Rollback succeeded; last-known-good remains '$PREVIOUS_IMAGE'"
    exit 1
  fi

  echo "Rollback failed for '$SERVICE'" >&2
  exit 1
fi

echo "No previous last-known-good image available for rollback" >&2
exit 1
