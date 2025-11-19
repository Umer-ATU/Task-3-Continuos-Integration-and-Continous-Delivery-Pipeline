# syntax=docker/dockerfile:1
FROM node:18-bullseye AS build
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json jest.config.js ./
COPY src ./src
COPY tests ./tests
RUN npm run build

FROM node:18-slim AS runtime
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY package*.json ./
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser \
    && npm ci --omit=dev && npm cache clean --force
COPY --from=build /usr/src/app/dist ./dist
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
USER appuser
CMD ["node", "dist/index.js"]
