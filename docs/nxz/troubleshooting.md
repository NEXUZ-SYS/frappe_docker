# Troubleshooting

Sintomas comuns, diagnóstico, fix e verificação. Se o seu problema não estiver aqui, pule pra [Como coletar logs](#como-coletar-logs).

## Sintoma: `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Diagnóstico:** outro processo (container ou serviço) já usa a porta 8080 no host.

**Fix:**

1. Edite `nxz/.env` (gitignored):

   ```bash
   HTTP_PUBLISH_PORT=8090
   ```

   (ou outra livre: 8100, 9090, etc.)

2. `./nxz/down.sh && ./nxz/up.sh`.

**Não** altere `nxz/.env.example` salvo se o time todo for adotar a nova porta como default.

**Verificação:**

```bash
curl -H "Host: erpnext.localhost" http://localhost:8090/api/method/ping
# {"message":"pong"}
```

## Sintoma: `ModuleNotFoundError: No module named 'payments'` no create-site

**Diagnóstico:** `nxz/apps.json` lista `crm` mas não lista `payments`. `crm` declara `payments` em `required_apps`, e o install falha.

**Fix:**

1. Adicione payments em `nxz/apps.json`:

   ```json
   { "url": "https://github.com/frappe/payments", "branch": "version-16" }
   ```

2. `./nxz/build.sh` → `./nxz/reset.sh` → `./nxz/up.sh`.

**Verificação:** `docker logs nxz-create-site-1` termina sem erro e `curl .../api/method/ping` retorna pong.

**Nota:** nunca remova `payments` achando que é código morto. Ver [Apps Workflow](./apps-workflow.md#dependências-implícitas-required_apps).

## Sintoma: alterei `apps.json` e os apps continuam iguais na imagem

**Diagnóstico:** ou esqueceu de rebuildar, ou alguém editou `build.sh` e removeu o `--no-cache-filter=builder`.

**Fix:**

1. Cheque o conteúdo real da imagem:

   ```bash
   docker run --rm --entrypoint="" nxz-erpnext:v16 ls apps
   ```

   Compare com `nxz/apps.json`.

2. Se divergiu: `./nxz/build.sh` novamente. Confirme que o build re-clona os apps (~3-5min, não segundos).

3. Se o build ainda usa cache do estágio `builder`, confira que `nxz/build.sh` contém `--no-cache-filter=builder`.

**Verificação:** após rebuild, `docker run --rm --entrypoint="" nxz-erpnext:v16 ls apps` mostra o app novo.

## Sintoma: stack "up" mas site não responde

**Diagnóstico:** provável falha no `create-site`. O service existe com status `Exited` ou com erro.

**Fix:**

1. Cheque o log:

   ```bash
   docker logs nxz-create-site-1
   ```

2. Causas comuns:
   - Dependência de app faltando (ver caso payments acima).
   - DB não ficou healthy a tempo — raro, geralmente resolvido na segunda tentativa.
   - Credenciais divergentes entre `.env` e `.env.example`.

3. Depois de corrigir: `./nxz/reset.sh` + `./nxz/up.sh`.

**Verificação:**

```bash
docker logs nxz-create-site-1 | tail -n 20
# "Installing app <nome>..." para cada app + "Site ... installed."
curl -H "Host: erpnext.localhost" http://localhost:8080/api/method/ping
```

## Sintoma: `api_secret` de ontem retorna 401

**Diagnóstico:** alguém rodou `./nxz/gen-api-key.sh <mesmo_user>` depois. O script rotaciona o secret a cada chamada.

**Fix:**

```bash
./nxz/gen-api-key.sh <user> --save
```

Atualize o cliente (env var, secret manager, etc.) com o novo valor de `nxz/.secrets/<user>.env`.

**Verificação:**

```bash
source nxz/.secrets/<user>.env
curl -H "Host: erpnext.localhost" \
     -H "Authorization: token $FRAPPE_API_KEY:$FRAPPE_API_SECRET" \
     http://localhost:8080/api/method/frappe.auth.get_logged_user
# {"message":"<user>"}
```

**Anti-pattern:** rodar `gen-api-key.sh` periodicamente "pra garantir". Só rotacione quando necessário.

## Sintoma: quero um usuário dedicado pra AI team, não Administrator

**Fix:**

1. Crie o usuário:

   - Via UI: `http://localhost:8080/app/user/new?user_type=System+User` (logue como Administrator).
   - Via bench (no container backend já rodando):

     ```bash
     docker exec -it nxz-backend-1 \
       bench --site erpnext.localhost add-user email@nxz.ai \
       --first-name AI --last-name Team --password <senha>
     ```

     (Comando `add-user` do bench; confirme flags na versão atual antes de depender.)

2. Ajuste roles/permissions do usuário via UI.

3. Gere chaves:

   ```bash
   ./nxz/gen-api-key.sh email@nxz.ai --save
   ```

**Verificação:** request autenticado com as novas chaves retorna `{"message":"email@nxz.ai"}` em `/api/method/frappe.auth.get_logged_user`.

## Sintoma: app novo está na imagem mas não aparece no site

**Diagnóstico:** `nxz/compose.create-site.yaml` hardcoda a lista de apps instalados no site (`erpnext`, `crm`, `lms`, `builder`). Apps adicionais ficam no bench mas não no site.

**Fix (manual por enquanto):**

```bash
docker exec -it nxz-backend-1 bench --site erpnext.localhost install-app <appname>
```

**Ponto de extensão futura:** parametrizar a lista de `install-app` no `create-site`. Hoje é limitação conhecida.

**Verificação:**

```bash
docker exec nxz-backend-1 bench --site erpnext.localhost list-apps
```

## Como coletar logs

Comandos úteis rodados da raiz do repo:

**Tudo de uma vez (últimos 200 linhas por service):**

```bash
docker compose --project-name nxz \
  --env-file nxz/.env \
  -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.noproxy.yaml \
  -f nxz/compose.create-site.yaml \
  logs --tail=200
```

**Um service específico com timestamps:**

```bash
docker logs -t nxz-backend-1
docker logs -t nxz-create-site-1
docker logs -t nxz-db-1
```

**Seguir em tempo real:**

```bash
docker logs -f nxz-backend-1
```

**Filtrar erros rapidamente:**

```bash
docker logs nxz-backend-1 2>&1 | grep -iE 'error|traceback'
```

Ao reportar problema, inclua:

- Versão do repo (`git rev-parse HEAD`).
- Conteúdo de `nxz/.env` (sem senhas).
- Saída de `docker compose --project-name nxz ps` (ou `docker ps --filter name=nxz-`).
- Logs relevantes do service que falhou.
