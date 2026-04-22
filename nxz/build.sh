#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# BuildKit é obrigatório pro --secret mount consumido por images/custom/Containerfile
export DOCKER_BUILDKIT=1

docker build \
  --file images/custom/Containerfile \
  --build-arg FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg FRAPPE_BRANCH=version-16 \
  --build-arg PYTHON_VERSION=3.14.2 \
  --build-arg NODE_VERSION=24.12.0 \
  --secret id=apps_json,src=nxz/apps.json \
  --tag nxz-erpnext:v16 \
  .

echo
echo "=== imagem buildada ==="
docker images nxz-erpnext:v16
