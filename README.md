# srv-template

Template de backend Desenrolai — criado pelo forge.

Stack: **NestJS 11 + Fastify + TypeScript 6 (strict) + Node 24 LTS**.

## Requisitos

- Node **24 LTS** (o CI e a imagem Docker usam `node:24`)

## Desenvolvimento

```bash
cp .env.example .env.local
npm install
npm run start:dev
```

Health check: `GET /api/v1/health` → `{ "status": "ok" }`

## Scripts

| Comando             | Descrição                                             |
| ------------------- | ----------------------------------------------------- |
| `npm run build`     | Compila TypeScript (`tsconfig.build.json`, sem specs) |
| `npm run start`     | Inicia em produção                                    |
| `npm run start:dev` | Inicia com hot-reload                                 |
| `npm run lint`      | ESLint (flat config)                                  |
| `npm run format`    | Prettier em modo check                                |
| `npm run typecheck` | `tsc --noEmit`                                        |
| `npm test`          | Jest                                                  |
| `npm run test:cov`  | Jest + coverage                                       |

## Docker

```bash
docker build -t srv-template .
docker run -p 3000:3000 srv-template
```

A imagem roda como usuário não-root (`node`) e traz `HEALTHCHECK` apontando para
o mesmo `healthPath` declarado no `forge.yaml`.

## CI: runner do repo gerado

O workflow roda em runner **hospedado** por padrão. Este template é público — em
repo público o Actions hospedado é gratuito, e apontar self-hosted aqui deixaria
um PR de fork executar código de terceiro dentro do cluster.

⚠️ **O repo gerado é privado, e nele esse default não vale.** Com a cota
hospedada bloqueada por billing, o job **falha em ~2 s sem executar nenhum
step** — e sem mensagem no log que oriente.

Zero steps, sozinho, não identifica nada: um job `skipped` pelo `if:` também
reporta zero. **O separador é a conclusão**: `failure` em ~2 s é billing;
`skipped` é o `if:`. Parece YAML quebrado, não é — a causa costuma vir na
*annotation* do job, não no log. Não perca tempo procurando erro no workflow.

Antes do primeiro push, defina duas **variáveis de repositório** (Settings →
Secrets and variables → Actions → Variables) com **array JSON** de labels:

| Variável           | Valor                              | Usada por                    |
| ------------------ | ---------------------------------- | ---------------------------- |
| `CI_RUNNER`        | `["self-hosted","desenrolai"]`     | job `ci`                     |
| `CI_RUNNER_DOCKER` | `["self-hosted","docker-builder"]` | jobs que constroem a imagem  |

```bash
gh variable set CI_RUNNER --body '["self-hosted","desenrolai"]'
gh variable set CI_RUNNER_DOCKER --body '["self-hosted","docker-builder"]'
```

São dois pools diferentes de propósito: o pool `desenrolai` **não tem Docker**
(`dockerEnabled: false`), só o `docker-builder` tem. Build de imagem no pool
errado falha por falta de daemon.

JSON é obrigatório: `runs-on` com a string `self-hosted,desenrolai` vira **um**
label contendo vírgula — não dois — e o job fica em `queued` para sempre. Sem as
variáveis definidas, o default hospedado continua valendo.

## Pool de teste e cgroup

`scripts/cpu-limit.js` lê o limite de CPU do cgroup (v2 `cpu.max`, v1
`cpu.cfs_quota_us`) e alimenta o `maxWorkers` do Jest em `jest.config.js`.
Dentro de um container, `os.cpus()` reporta as CPUs do **host**: sem esse ajuste
o Jest sobe workers demais e o job morre com todos os testes passando.
Fora de container (macOS local) o helper cai para `os.cpus().length`.

## Ao gerar um repo a partir deste template (rename)

O Forge scaffolda com `octokit.repos.createUsingTemplate` — **cópia literal, sem
substituição de placeholder**. Todo nome deste template chega intacto no repo
gerado.

Lista **completa**:

| Onde                                                    | Valor atual                            | O que quebra se ficar                                                                                                         |
| ------------------------------------------------------- | -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `package.json` → `name`                                 | `srv-template`                         | colide com todo outro repo gerado deste template                                                                              |
| `package-lock.json` → `name` (2 ocorrências)            | idem                                   | regenerado sozinho: rode `npm install` **depois** de trocar o `package.json`                                                  |
| `package.json` → `description`                          | `Template de backend Desenrolai — ...` | nada — cosmético, e **não casa com o grep abaixo**                                                                            |
| `README.md` → título e exemplos de `docker build`/`run` | `srv-template`                         | nada — cosmético                                                                                                              |
| `.github/workflows/ci.yml` → `IMAGE_NAME`               | `desenrolai/${{ ... }}`                | **NÃO troque**: `desenrolai` aqui é a org do GHCR, não o nome do template. O repo já entra por `github.event.repository.name` |

Nenhum ponto deste template é lido em runtime — nada quebra funcionalmente se o
rename ficar pela metade, e o `private: true` já impede publicação acidental. O
risco é cosmético e de colisão de nome entre repos gerados.

Confira, do próprio repo:

```bash
git grep -nI 'srv-template' -- . ':!README.md'
```

Saída vazia = os pontos que casam o nome foram todos trocados. **Ele não pega a
`description` do `package.json`** (não contém o nome) — confira essa à mão.

O `-- . ':!README.md'` exclui esta própria seção, que cita os valores antigos
de propósito. **Apague esta seção** depois de concluir o rename — ela é
instrução de scaffold, não documentação do repo gerado.
