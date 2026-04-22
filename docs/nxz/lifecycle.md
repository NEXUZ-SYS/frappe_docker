# Lifecycle

Referência dos scripts em `nxz/`. Todos rodam a partir da raiz do repo.

## Tabela resumo

| Script              | O que faz                                     | Destrutivo | Pede confirmação |
|---------------------|-----------------------------------------------|------------|------------------|
| `build.sh`          | Builda `nxz-erpnext:v16`                      | Não        | Não              |
| `up.sh`             | Sobe a stack (compose up -d)                  | Não        | Não              |
| `down.sh`           | Para a stack (compose down)                   | Não (mantém volumes) | Não    |
| `reset.sh`          | Para stack + apaga volumes                    | **Sim**    | Sim (`reset`)    |
| `gen-api-key.sh`    | Gera/rotaciona par api_key + api_secret       | **Sim** (rotaciona) | Não     |

## `./nxz/build.sh`

**Signature:** `./nxz/build.sh` (sem argumentos).

**O que faz:**

- Builda a imagem `nxz-erpnext:v16`.
- Usa BuildKit `--secret id=apps_json,src=nxz/apps.json` pra injetar a lista de apps sem virar layer.
- Força `--no-cache-filter=builder` no estágio `builder` — garante que mudanças em `nxz/apps.json` sempre re-disparem o clone dos apps.

**Quando usar:**

- Primeira instalação.
- Depois de editar `nxz/apps.json`.
- Depois de mudar versões de Python/Node no Dockerfile custom.

**Não faz:**

- Não sobe containers.
- Não toca em volumes.
- Não cria site.

**Gotchas:**

- Primeiro build: ~15-25min.
- Rebuild: ~3-5min (re-clone de apps sempre, por design).
- Se o build falhar no estágio `builder`, geralmente é `apps.json` inválido ou branch inexistente. Rode `cat nxz/apps.json | jq .` pra validar JSON.

## `./nxz/up.sh`

**Signature:** `./nxz/up.sh` (sem argumentos).

**O que faz:**

- `docker compose ... up -d` empilhando, nesta ordem:

  ```
  compose.yaml
  overrides/compose.mariadb.yaml
  overrides/compose.redis.yaml
  overrides/compose.noproxy.yaml
  nxz/compose.create-site.yaml
  ```

- Sobe `backend`, `frontend`, `websocket`, `queue-short`, `queue-long`, `scheduler`, `db`, `redis-cache`, `redis-queue`.
- Executa os one-shots `configurator` e `create-site` (primeira subida).

**Quando usar:**

- Sempre que quiser a stack rodando.

**Não faz:**

- Não builda a imagem (rode `build.sh` antes se a imagem não existe).
- Não bloqueia até `create-site` terminar (acompanhe com `docker logs -f nxz-create-site-1`).

**Gotchas:**

- `create-site` só instala apps na **primeira** subida (ou após `reset.sh`). Se o volume de sites já existe, ele pula.
- Porta `HTTP_PUBLISH_PORT` precisa estar livre.

## `./nxz/down.sh`

**Signature:** `./nxz/down.sh` (sem argumentos).

**O que faz:**

- `docker compose ... down` — para e remove containers.
- **Mantém volumes** (site, DB, Redis preservados).

**Quando usar:**

- Desligar a stack sem perder dados.
- Antes de `up.sh` se houver algo travado.

**Não faz:**

- Não apaga volumes.
- Não remove a imagem.

## `./nxz/reset.sh`

**Signature:** `./nxz/reset.sh` (sem argumentos).

**O que faz:**

- Pede confirmação interativa — você precisa digitar literalmente `reset`.
- Depois da confirmação: `docker compose ... down --volumes` — apaga **todos** os volumes (site, DB MariaDB, Redis data).

**Quando usar:**

- Adicionou/removeu app em `apps.json` e precisa recriar o site.
- Site em estado inconsistente.
- Quer começar do zero.

**Não faz:**

- Não remove a imagem `nxz-erpnext:v16` (rode `docker image rm nxz-erpnext:v16` se quiser).
- Não sobe a stack de volta (rode `up.sh` em seguida).

**Gotchas:**

- **Destrutivo.** Dados de teste somem. API keys também — vai precisar rodar `gen-api-key.sh` de novo.
- Se você apertou Enter sem digitar `reset`, o script aborta seguro.

## `./nxz/gen-api-key.sh`

**Signature:** `./nxz/gen-api-key.sh [user] [--save]`

**O que faz:**

- Executa `bench execute frappe.core.doctype.user.user.generate_keys` no container `backend`.
- Sem argumentos: usa `Administrator` e imprime `api_key`/`api_secret` no stdout.
- Com `[user]`: mesmo, para um usuário específico (email ou name do User doctype).
- Com `--save`: grava em `nxz/.secrets/<user>.env` com chmod 600. Cria o diretório se não existir. `nxz/.secrets/` é gitignored.

**Quando usar:**

- Primeira geração de chaves para um usuário.
- Rotação intencional de credenciais.

**Não faz:**

- Não cria o usuário (precisa existir antes via UI ou `bench`).
- Não atualiza clientes que já usam a chave antiga.

**Gotchas:**

- **Rotaciona sempre.** `api_secret` novo a cada chamada. `api_key` é idempotente mas o par fica inválido porque o secret muda.
- Não há comando "read-only" — se perdeu o secret, a única saída é rotacionar.
- Requer a stack rodando (`up.sh` antes).
