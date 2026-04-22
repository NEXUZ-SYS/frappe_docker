#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Carrega .env para que o prompt mostre o SITES real (e não o fallback).
# shellcheck disable=SC1091
[ -f nxz/.env ] && . nxz/.env

echo "!! reset.sh vai apagar os volumes (sites, db-data, redis-*-data)"
echo "   o site '${SITES:-erpnext.localhost}' e todos os dados serão perdidos."
read -r -p "digite 'reset' para confirmar: " CONFIRM
[ "$CONFIRM" = "reset" ] || { echo "cancelado"; exit 1; }

docker compose --project-name nxz \
  --env-file nxz/.env \
  -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.noproxy.yaml \
  -f nxz/compose.create-site.yaml \
  down --volumes
