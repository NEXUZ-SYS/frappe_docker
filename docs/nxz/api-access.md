# API Access

Guia prático de consumo HTTP. Para o contrato estável (URL, porta, site), ver [Access Contract](./access-contract.md).

Exemplos usam `localhost:8080`. Ajuste para sua porta local (`nxz/.env` → `HTTP_PUBLISH_PORT`).

## Gerar chaves

```bash
./nxz/gen-api-key.sh Administrator --save
```

Saída: `nxz/.secrets/Administrator.env` com:

```bash
FRAPPE_API_KEY=...
FRAPPE_API_SECRET=...
```

- Sem `--save`: imprime no stdout, não grava.
- Sem usuário: default `Administrator`.
- **Rotaciona a cada chamada:** tokens antigos param de funcionar. Gere uma vez, distribua, e só rode de novo quando precisar rotacionar de propósito.

## Header de autenticação

Formato fixo do Frappe:

```http
Authorization: token <api_key>:<api_secret>
Host: erpnext.localhost
```

O `Host` é sempre obrigatório (ver [Access Contract](./access-contract.md#host-header-obrigatório)).

**CSRF:** não se aplica quando autenticando com token. `X-Frappe-CSRF-Token` é necessário apenas pra requests de sessão cookie-based (UI).

## Endpoints base

O Frappe expõe duas famílias de endpoints:

### `/api/method/<dotted.path>`

Chama uma função Python exposta via `@frappe.whitelist()`. Usado pra RPC e utilitários.

```bash
curl -H "Host: erpnext.localhost" http://localhost:8080/api/method/ping
# {"message":"pong"}
```

```bash
source nxz/.secrets/Administrator.env
curl -H "Host: erpnext.localhost" \
     -H "Authorization: token $FRAPPE_API_KEY:$FRAPPE_API_SECRET" \
     http://localhost:8080/api/method/frappe.auth.get_logged_user
# {"message":"Administrator"}
```

### `/api/resource/<Doctype>`

CRUD sobre doctypes. Padrão REST.

**Listar:**

```bash
curl -H "Host: erpnext.localhost" \
     -H "Authorization: token $FRAPPE_API_KEY:$FRAPPE_API_SECRET" \
     "http://localhost:8080/api/resource/User?limit_page_length=3"
```

**Buscar por nome (PK do doctype):**

```bash
curl -H "Host: erpnext.localhost" \
     -H "Authorization: token $FRAPPE_API_KEY:$FRAPPE_API_SECRET" \
     http://localhost:8080/api/resource/User/Administrator
```

**Criar (exemplo ToDo):**

```bash
curl -X POST \
     -H "Host: erpnext.localhost" \
     -H "Authorization: token $FRAPPE_API_KEY:$FRAPPE_API_SECRET" \
     -H "Content-Type: application/json" \
     -d '{"description":"Integrar com stack Nxz"}' \
     http://localhost:8080/api/resource/ToDo
```

## Paginação e filtros

Query params aceitos por `/api/resource/<Doctype>`:

- `limit_page_length` — tamanho da página (default 20).
- `limit_start` — offset (0-based).
- `fields` — JSON array: `["name","email","enabled"]` url-encoded.
- `filters` — JSON de filtros: `[["enabled","=",1]]` url-encoded.
- `order_by` — ex.: `creation desc`.

Exemplo:

```bash
curl -H "Host: erpnext.localhost" \
     -H "Authorization: token $FRAPPE_API_KEY:$FRAPPE_API_SECRET" \
     "http://localhost:8080/api/resource/User?limit_page_length=10&limit_start=0&fields=%5B%22name%22%2C%22email%22%5D"
```

## WebSocket

O `backend` emite eventos via `websocket` (service próprio) e o `frontend` proxia `/socket.io`. Disponível no mesmo host/porta da API (`http://localhost:8080/socket.io`). **Não verificado end-to-end neste setup** — confirme antes de depender.

## Códigos de status comuns

- `200` — sucesso.
- `401` — token ausente, inválido ou revogado (rotação).
- `403` — permissão insuficiente no doctype para o usuário das chaves.
- `404` — doctype ou endpoint inexistente (cheque spelling e app instalado).
- `417` — validação do Frappe (ex.: campo obrigatório faltando no POST).
- `500` — erro de server; cheque `docker logs nxz-backend-1`.
