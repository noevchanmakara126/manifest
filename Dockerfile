# syntax=docker/dockerfile:1

# Next.js 16 requires >= 20.9. Pinned to the major the app is developed against.
ARG NODE_VERSION=22-alpine


# ============================================================
# DEPENDENCY STAGE
# ============================================================
FROM node:${NODE_VERSION} AS deps

WORKDIR /app

# Manifests only, so this layer is reused until a dependency actually changes.
COPY package.json package-lock.json ./

# devDependencies are needed: the build runs tsc, tailwind and eslint-config-next.
RUN --mount=type=cache,target=/root/.npm \
    npm ci


# ============================================================
# BUILD STAGE
# ============================================================
FROM node:${NODE_VERSION} AS build

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1

# Every service URL and the session secret are read at request time in
# src/lib/api/client.ts and src/lib/session.ts, never inlined into the bundle,
# so no build arg is required and one image can move from staging to prod.
#
# Every route is dynamic (each reads cookies or session), so nothing is
# prerendered and the build never tries to reach the Spring Boot services.
RUN --mount=type=cache,target=/app/.next/cache \
    npm run build


# ============================================================
# RUNTIME STAGE
# ============================================================
FROM node:${NODE_VERSION} AS runtime

WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0

# High, fixed UID so a `runAsUser: 10001` pod security context lines up with the
# file ownership below, matching the four Spring Boot images.
RUN addgroup -S -g 10001 nodejs \
    && adduser -S -u 10001 -G nodejs nextjs

# The standalone bundle: server.js plus the traced subset of node_modules.
COPY --from=build --chown=10001:10001 /app/.next/standalone ./

# server.js serves neither of these on its own — they are copied in deliberately
# so the pod is self-sufficient without a CDN in front of it.
COPY --from=build --chown=10001:10001 /app/.next/static ./.next/static
COPY --from=build --chown=10001:10001 /app/public ./public

# The `revalidate: 30`/`300` fetches in src/lib/api write their data cache here.
# Pre-created and owned so the container still starts under a read-only root
# filesystem with an emptyDir mounted over it.
RUN mkdir -p .next/cache \
    && chown -R 10001:10001 .next

USER 10001:10001

EXPOSE 3000

# No HEALTHCHECK: kubelet ignores it, and the only route that could stand in for
# one is `/`, which renders the catalogue — a backend outage would then restart
# a perfectly healthy frontend. Add a /api/health route and point the probes at
# that instead.

# Direct exec — PID 1 is node, so SIGTERM reaches it and the pod drains cleanly.
CMD ["node", "server.js"]
