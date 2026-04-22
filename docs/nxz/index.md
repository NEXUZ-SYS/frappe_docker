# Nxz frappe_docker — Base de Teste Local

Este diretório documenta o fork Nxz de `frappe_docker`, mantido como **base de teste local** para consumo do time AI interno via HTTP.

## O que é

- Fork de `github.com/frappe/frappe_docker` em `github.com/NEXUZ-SYS/frappe_docker` (branch `main`).
- Imagem custom `nxz-erpnext:v16` com 6 apps Frappe pré-instalados (frappe, erpnext, payments, crm, lms, builder).
- Stack Docker Compose com MariaDB, Redis e nginx, expondo HTTP sem traefik/SSL.
- Scripts em `nxz/` para build, up/down, reset e geração de API keys.

## Pra quem

Time AI interno da Nxz que precisa:

1. Subir a stack localmente.
2. Consumir endpoints via HTTP.
3. Eventualmente plugar apps Frappe próprios em cima.

## Navegação

| Documento | Quando ler |
|-----------|-----------|
| [Getting Started](./getting-started.md) | Primeira vez subindo a stack — do clone ao primeiro `curl`. |
| [Access Contract](./access-contract.md) | Antes de integrar qualquer cliente — o que é estável e o que pode mudar. |
| [API Access](./api-access.md) | Uso prático da API HTTP: auth, endpoints, exemplos curl. |
| [Apps Workflow](./apps-workflow.md) | Adicionar/remover apps Frappe da imagem. |
| [Lifecycle](./lifecycle.md) | Referência dos scripts `nxz/*.sh`. |
| [Troubleshooting](./troubleshooting.md) | Quando algo quebra — sintomas comuns e fixes. |

## Convenções

- Scripts e docs em pt-BR. Commits em inglês (padrão do repo upstream).
- Todos os caminhos referenciados são relativos à raiz do repo.
- Credenciais e portas em `nxz/.env.example` são **defaults de desenvolvimento** — troque antes de expor além de `localhost`.
