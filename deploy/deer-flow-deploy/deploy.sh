#!/usr/bin/env bash
set -e
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DEPLOY_DIR"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'
CMD="${1:-}"
if [ "$CMD" != "stop" ] && [ "$CMD" != "down" ] && [ "$CMD" != "logs" ] && [ "$CMD" != "status" ]; then
    if [ -d "images" ]; then
        echo -e "${YELLOW}Loading Docker images...${NC}"
        for tar_file in images/*.tar; do
            [ -f "$tar_file" ] || continue
            echo -e "${BLUE}  Loading $tar_file...${NC}"
            docker load -i "$tar_file"
        done
        echo -e "${GREEN}✓ Images loaded${NC}"; echo ""
    fi
fi
[ -f ".env" ] && set -a && source .env && set +a && echo -e "${GREEN}✓ Loaded .env${NC}"
export DEER_FLOW_HOST_SKILLS_PATH="${DEER_FLOW_HOST_SKILLS_PATH:-$DEPLOY_DIR/skills}"
export HOME="${HOME:-/root}"
case "${CMD:-}" in
    start) echo -e "${BLUE}Starting DeerFlow...${NC}"; docker-compose -p deer-flow up -d --remove-orphans; echo -e "${GREEN}==========================================\n  DeerFlow is running!\n==========================================${NC}"; echo ""; echo "  🌐 Application: http://localhost:${PORT:-2026}"; echo "  📡 API Gateway: http://localhost:${PORT:-2026}/api/*"; echo ""; echo "  Manage:"; echo "    ./deploy.sh stop     — stop containers"; echo "    ./deploy.sh logs     — view logs"; echo "    ./deploy.sh status   — container status"; echo "";;
    stop) docker-compose -p deer-flow stop;;
    down) docker-compose -p deer-flow down;;
    logs) docker-compose -p deer-flow logs -f "${@:2}";;
    status) docker-compose -p deer-flow ps;;
    *) echo "DeerFlow Deploy Manager"; echo ""; echo "Usage: ./deploy.sh [command]"; echo ""; echo "Commands:"; echo "  start    — Load images and start services (default)"; echo "  stop     — Stop containers"; echo "  down     — Stop and remove containers"; echo "  logs     — View logs"; echo "  status   — Show container status"; echo ""; echo "Access: http://localhost:${PORT:-2026}";;
esac
