#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

docker compose --project-name nxz \
  --env-file nxz/.env \
  -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.noproxy.yaml \
  -f nxz/compose.create-site.yaml \
  down
