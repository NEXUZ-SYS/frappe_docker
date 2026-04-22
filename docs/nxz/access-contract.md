# Access Contract

Contrato estável que o time AI pode usar como referência pra integrar clientes. O que está aqui **não muda sem aviso**.

## URLs e porta

- Base URL: `http://localhost:<HTTP_PUBLISH_PORT>`.
- Default do time: `8080`. Máquina do autor usa `8090` pra evitar conflito — consulte `nxz/.env` local se o seu host precisar de outra porta.
- Sem HTTPS. Sem traefik. É uma base de teste **local** — não exponha em rede pública.

## Host header (obrigatório)

Toda request HTTP **precisa** incluir:

```http
Host: erpnext.localhost
```

Sem ele, o nginx não roteia pro site correto e você recebe erro ou página default do frontend.

Exemplo mínimo:

```bash
curl -H "Host: erpnext.localhost" http://localhost:8080/api/method/ping
```

## Site base

- Nome: `erpnext.localhost`.
- Definido via `SITES=erpnext.localhost` e `FRAPPE_SITE_NAME_HEADER=erpnext.localhost` em `nxz/.env.example`.
- **Não renomeie** sem alinhar — clientes dependem desse header.

## Credenciais

- Usuário admin padrão: `Administrator` com senha definida em `ADMIN_PASSWORD` (`.env`).
- API key/secret geradas via `./nxz/gen-api-key.sh` — ver [API Access](./api-access.md) e [Lifecycle](./lifecycle.md).
- Formato do header de auth:

  ```http
  Authorization: token <api_key>:<api_secret>
  ```

- Para um usuário dedicado ao time AI (recomendado em vez de Administrator): crie via UI em `http://localhost:8080/app/user/new?user_type=System+User` ou via `bench` e rode `./nxz/gen-api-key.sh email@nxz.ai --save`.

## Apps disponíveis na imagem

Versões fixadas em `nxz-erpnext:v16`:

| App       | Versão  | Branch     |
|-----------|---------|------------|
| frappe    | 16.16.0 | version-16 |
| erpnext   | 16.15.0 | version-16 |
| payments  | 0.0.1   | version-16 |
| crm       | 1.69.1  | main       |
| lms       | 2.52.1  | main       |
| builder   | 1.23.3  | master     |

**payments é dependência obrigatória do crm** (listado em `required_apps` do hooks.py) — não remova.

Instalados no site `erpnext.localhost` pelo `create-site`: `erpnext`, `crm`, `lms`, `builder` (+ `payments` via cascata).

## Estável vs. pode mudar

**Estável (garantia de contrato):**

- Base URL + porta configurável via `HTTP_PUBLISH_PORT`.
- Site `erpnext.localhost` + exigência do header `Host`.
- Formato do token auth (`Authorization: token K:S`).
- Presença dos 6 apps listados acima, na major line `v16` do Frappe.

**Pode mudar sem aviso:**

- Apps extras adicionados para experimentos.
- Customizações de doctypes / fixtures.
- Versões patch dos apps (16.16.x, 1.69.x etc.) — major line se mantém.
- Conteúdo de dados (usuários, registros de teste).

## Checklist mínimo (valide em 30s antes de integrar)

- [ ] `curl -H "Host: erpnext.localhost" http://localhost:<porta>/api/method/ping` retorna `{"message":"pong"}`.
- [ ] Você tem um `api_key` + `api_secret` salvos (de `nxz/.secrets/` ou equivalente).
- [ ] `curl` com `Authorization: token K:S` + `Host` header retorna `{"message":"Administrator"}` em `/api/method/frappe.auth.get_logged_user`.
- [ ] Porta configurada no cliente bate com `HTTP_PUBLISH_PORT` do host.
- [ ] Cliente envia `Host: erpnext.localhost` em todas as requests.
- [ ] Cliente não assume HTTPS.
