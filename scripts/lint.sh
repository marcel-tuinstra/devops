#!/usr/bin/env bash
set -euo pipefail

required_paths=(
  ".github/workflows/reusable-ci.yml"
  "README.md"
  "docs/testing.md"
  "templates/docker/nuxt-ssg-nginx.Dockerfile"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path"
    exit 1
  fi
done

echo "lint passed"
