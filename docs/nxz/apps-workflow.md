# Apps Workflow

Como adicionar, atualizar ou remover apps Frappe da imagem `nxz-erpnext:v16`.

## Visão geral

A imagem é construída a partir de `nxz/apps.json`, que lista **todos** os apps a clonar e bench-buildar. O site `erpnext.localhost` é criado pelo one-shot `create-site` e recebe um **subconjunto hardcoded** desses apps.

```
nxz/apps.json  →  imagem (build time)  →  create-site instala subset  →  site
```

## Semântica de branches

Escolha de branch impacta estabilidade:

- `version-16` — **estável**, alinhado com frappe/erpnext v16. Use para apps que seguem o ciclo do ERPNext (ex.: `payments`).
- `main` ou `master` — rolling release do app. Usado por `crm` (main), `lms` (main), `builder` (master). Quebras raras mas possíveis em update de imagem.
- `develop` — bleeding edge. **Evite** salvo se quiser instabilidade de propósito.

Consulte o README do app upstream antes de fixar.

## Dependências implícitas (`required_apps`)

Alguns apps declaram dependências via `required_apps` em `hooks.py`. Exemplo real:

- `crm` requer `payments` — se `payments` não estiver em `apps.json`, `create-site` falha com `ModuleNotFoundError: No module named 'payments'`.

**Não remova apps sem checar `required_apps` dos outros.** Cascatas não aparecem em `apps.json`.

## Adicionar um app

### 1. Editar `nxz/apps.json`

```json
{
  "url": "https://github.com/seu-org/seu-app",
  "branch": "main"
}
```

Mantenha os apps existentes. Ordem não importa para bench.

### 2. Rebuildar a imagem

```bash
./nxz/build.sh
```

O script força `--no-cache-filter=builder`, então edições em `apps.json` são sempre re-aplicadas. Custo: ~3-5min de re-clone a cada build. Aceitável — evita o bug silencioso de build cacheado com `apps.json` stale.

### 3. Reset dos volumes

```bash
./nxz/reset.sh
```

Pede confirmação digitada (`reset`). **Destrói site, DB e Redis.** Necessário porque o site existente não reinstala apps automaticamente.

### 4. Subir de novo

```bash
./nxz/up.sh
```

`create-site` recria o site e instala o subset hardcoded (`erpnext`, `crm`, `lms`, `builder`).

### 5. Instalar o app novo no site (se não estiver no hardcoded)

**Limite atual:** `nxz/compose.create-site.yaml` tem a lista de apps fixa. Um app recém-adicionado à imagem fica disponível no bench mas **não é instalado no site automaticamente**.

Workaround enquanto o hardcoded não é parametrizado:

```bash
docker exec -it nxz-backend-1 bench --site erpnext.localhost install-app <appname>
```

(Futuro: tornar a lista de install-app parametrizável — ponto de extensão. Ver [Troubleshooting](./troubleshooting.md).)

## Remover um app

1. Remova a entrada de `nxz/apps.json`.
2. **Cheque dependências**: nenhum outro app declara esse em `required_apps`? Se sim, aborte ou remova o dependente junto.
3. `./nxz/build.sh` + `./nxz/reset.sh` + `./nxz/up.sh`.

Exemplo anti-pattern: remover `payments` achando que é dead code. Ele é `required_apps` de `crm` — build passa, mas `create-site` quebra.

## Atualizar versão de um app

1. Altere o `branch` em `nxz/apps.json` (ex.: pin em tag ou troca de `main` → `version-16`).
2. `./nxz/build.sh` (re-clona).
3. `./nxz/reset.sh` + `./nxz/up.sh` se quiser banco limpo; caso contrário, rode `bench --site erpnext.localhost migrate` no `backend`.

## Verificar o que está realmente na imagem

```bash
docker run --rm --entrypoint="" nxz-erpnext:v16 ls apps
```

Lista os diretórios de apps presentes no build atual. Use sempre que desconfiar de cache.
