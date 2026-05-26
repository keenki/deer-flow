# DeerFlow Deployment Guide

## Architecture

```
nginx:2026 → frontend (Next.js SSR)
           → gateway (FastAPI + LangGraph + AIO sandbox)
```

## Quick Deploy

```bash
./deploy.sh start   # Load images + start all services
```

Access: `http://localhost:2026`

## Build Images (on build machine)

```bash
# From repo root
docker compose -f docker/docker-compose-deploy.yaml build

# Export images
docker save deer-flow/gateway:latest  -o deer-flow-gateway.tar
docker save deer-flow/frontend:latest -o deer-flow-frontend.tar
docker pull nginx:alpine
docker save nginx:alpine               -o nginx-alpine.tar
```

Or use the packaging script:

```bash
./scripts/package-deploy.sh build
# Output: dist/deer-flow-deploy.tar.gz
```

## Deploy (on target machine)

1. Copy `deer-flow-deploy.tar.gz` to target machine
2. Extract: `tar xzf deer-flow-deploy.tar.gz -C /opt/`
3. Configure:
   ```bash
   cd /opt/deer-flow-deploy
   cp config.example.yaml config.yaml          # Edit API keys
   cp .env.example .env                         # Edit secrets
   ```
4. Load images (if shipped separately):
   ```bash
   docker load -i deer-flow-gateway.tar
   docker load -i deer-flow-frontend.tar
   docker load -i nginx-alpine.tar
   ```
5. Start: `./deploy.sh start`

## Manage

| Command | Description |
|---------|-------------|
| `./deploy.sh start` | Load images and start services |
| `./deploy.sh stop` | Stop containers |
| `./deploy.sh down` | Stop and remove containers |
| `./deploy.sh logs` | View logs (`logs gateway` for single service) |
| `./deploy.sh status` | Container status |

## Configuration

- `config.yaml` — Models, tools, sandbox, database (copy from `config.example.yaml`)
- `.env` — API keys and secrets (copy from `.env.example`)
- `extensions_config.json` — MCP servers and skills config
- `nginx.conf` — Reverse proxy routing
- `docker-compose.yaml` — Service orchestration

## Important: `--no-sync` Flag

The gateway start command **must** include `--no-sync`:

```yaml
command: sh -c "cd backend && PYTHONPATH=. uv run --no-sync uvicorn ..."
```

Without it, `uv run` tries to re-sync dependencies on every container startup, which fails when the container has no network access.
