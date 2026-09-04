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

## Pool de teste e cgroup

`scripts/cpu-limit.js` lê o limite de CPU do cgroup (v2 `cpu.max`, v1
`cpu.cfs_quota_us`) e alimenta o `maxWorkers` do Jest em `jest.config.js`.
Dentro de um container, `os.cpus()` reporta as CPUs do **host**: sem esse ajuste
o Jest sobe workers demais e o job morre com todos os testes passando.
Fora de container (macOS local) o helper cai para `os.cpus().length`.
