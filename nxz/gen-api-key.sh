#!/usr/bin/env bash
set -euo pipefail

# Gera/rotaciona api_key + api_secret de um usuário Frappe e imprime em stdout.
# Opcionalmente salva em nxz/.secrets/<user>.env (gitignored).
#
# Uso:
#   ./nxz/gen-api-key.sh                         # Administrator, só imprime
#   ./nxz/gen-api-key.sh someone@example.com     # usuário arbitrário
#   ./nxz/gen-api-key.sh Administrator --save    # imprime + salva em nxz/.secrets/
#
# ATENÇÃO: chamar generate_keys ROTACIONA as chaves — api_secret antigo fica inválido.

cd "$(dirname "$0")/.."

# shellcheck disable=SC1091
[ -f nxz/.env ] && . nxz/.env
SITE="${SITES:-erpnext.localhost}"

USER_NAME="${1:-Administrator}"
SAVE="${2:-}"

OUTPUT=$(docker compose --project-name nxz \
  --env-file nxz/.env \
  -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.noproxy.yaml \
  -f nxz/compose.create-site.yaml \
  exec -T backend bench --site "$SITE" execute \
    frappe.core.doctype.user.user.generate_keys \
    --kwargs "{\"user\":\"$USER_NAME\"}" 2>/dev/null)

API_KEY=$(echo "$OUTPUT"  | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("api_key",""))')
API_SECRET=$(echo "$OUTPUT" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("api_secret",""))')

if [ -z "$API_KEY" ] || [ -z "$API_SECRET" ]; then
  echo "erro: resposta do bench execute sem api_key/api_secret:" >&2
  echo "$OUTPUT" >&2
  exit 1
fi

echo "site:       $SITE"
echo "user:       $USER_NAME"
echo "api_key:    $API_KEY"
echo "api_secret: $API_SECRET"
echo
echo "authorization header:"
echo "  Authorization: token ${API_KEY}:${API_SECRET}"

if [ "$SAVE" = "--save" ]; then
  mkdir -p nxz/.secrets
  SAFE_USER=$(echo "$USER_NAME" | tr '/@' '__')
  FILE="nxz/.secrets/${SAFE_USER}.env"
  cat > "$FILE" <<EOF
# gerado por nxz/gen-api-key.sh em $(date -Iseconds)
# site: $SITE
# user: $USER_NAME
FRAPPE_API_KEY=$API_KEY
FRAPPE_API_SECRET=$API_SECRET
EOF
  chmod 600 "$FILE"
  echo
  echo "salvo em $FILE (chmod 600)"
fi
