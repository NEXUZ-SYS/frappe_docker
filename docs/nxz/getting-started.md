# Getting Started

Happy path do zero até o primeiro request autenticado. Leitura única; depois, pule pra [API Access](./api-access.md).

## Pré-requisitos

- Docker + Docker Compose plugin (v2).
- Git.
- Porta HTTP livre no host (padrão `8080`).
- ~10 GB de disco pra imagem + volumes.
- Conexão com GitHub (o build clona 6 repos de apps Frappe).

## 1. Clone

```bash
git clone https://github.com/NEXUZ-SYS/frappe_docker.git
cd frappe_docker
```

## 2. Configure o ambiente

Copie o template e revise:

```bash
cp nxz/.env.example nxz/.env
```

Variáveis relevantes em `nxz/.env`:

- `HTTP_PUBLISH_PORT` — porta exposta no host. Default `8080`. Se a porta estiver ocupada, troque (ex.: `8090`).
- `SITES` — deixe `erpnext.localhost`.
- `FRAPPE_SITE_NAME_HEADER` — deixe `erpnext.localhost`.
- `DB_PASSWORD` / `ADMIN_PASSWORD` — senhas de dev. Troque antes de expor além de `localhost`.

`nxz/.env` é **gitignored**. Ajustes locais não vazam.

## 3. Build da imagem

```bash
./nxz/build.sh
```

Builda `nxz-erpnext:v16`. O primeiro build leva **~15-25min** (imagem base + clone e bench de 6 apps). Builds subsequentes re-clonam os apps (~3-5min) porque o script força `--no-cache-filter=builder` pra garantir que edições em `nxz/apps.json` sejam sempre aplicadas.

## 4. Suba a stack

```bash
./nxz/up.sh
```

Sobe `backend`, `frontend`, `websocket`, `queue-short`, `queue-long`, `scheduler`, `db` (MariaDB 11.8), `redis-cache`, `redis-queue`, e dispara o one-shot `create-site`.

Na **primeira subida**, `create-site` cria o site `erpnext.localhost` e instala `erpnext`, `crm`, `lms`, `builder` (payments entra automaticamente como dependência de crm). Leva **~2-4min**. O `up.sh` retorna antes do site ficar pronto — acompanhe com:

```bash
docker logs -f nxz-create-site-1
```

## 5. Smoke test

Com o site pronto, dispare o ping:

```bash
curl -H "Host: erpnext.localhost" http://localhost:8080/api/method/ping
```

Esperado: `{"message":"pong"}`.

Se você trocou a porta no `.env`, ajuste (`http://localhost:8090/...`).

O header `Host: erpnext.localhost` é **obrigatório** em todas as requests — o nginx roteia por ele.

## 6. Gere um par de API key/secret

```bash
./nxz/gen-api-key.sh Administrator --save
```

Grava `nxz/.secrets/Administrator.env` (dir gitignored, chmod 600) com `FRAPPE_API_KEY` e `FRAPPE_API_SECRET`.

**Atenção:** cada chamada do script rotaciona o `api_secret` — quebra tokens em uso. Gere uma vez e reuse.

## 7. Request autenticado

```bash
source nxz/.secrets/Administrator.env
curl -H "Host: erpnext.localhost" \
     -H "Authorization: token $FRAPPE_API_KEY:$FRAPPE_API_SECRET" \
     http://localhost:8080/api/method/frappe.auth.get_logged_user
```

Esperado: `{"message":"Administrator"}`.

## Próximos passos

- [Access Contract](./access-contract.md) — contrato estável que clientes podem depender.
- [API Access](./api-access.md) — endpoints, paginação, exemplos de CRUD.
- [Apps Workflow](./apps-workflow.md) — adicionar um app Frappe próprio.
