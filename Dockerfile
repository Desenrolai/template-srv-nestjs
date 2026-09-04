# ─── builder ───────────────────────────────────────────────────────────────────
FROM node:24-bookworm-slim AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY tsconfig.json tsconfig.build.json nest-cli.json ./
COPY src/ ./src/
RUN npm run build

# ─── runtime ───────────────────────────────────────────────────────────────────
FROM node:24-bookworm-slim AS runtime

ENV NODE_ENV=production \
    PORT=3000

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist

# Usuario nao-root ja existente na imagem oficial (uid 1000).
USER node

EXPOSE 3000

# Coerente com forge.yaml healthPath: /api/v1/health
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/api/v1/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "dist/main"]
