#!/usr/bin/env bash
set -e

# Load environment variables
if [[ ! -f ".env" ]]; then
  echo "❌ .env file not found"
  exit 1
fi

set -a
source .env
set +a

PROJECT_STORAGE="storage"
PROJECT_UI="ui"

COMPOSE_STORAGE="docker-compose.storage.yml"
COMPOSE_UI="docker-compose.ui.yml"

ensure_infrastructure() {
  echo "🔧 Setting up infrastructure..."
  bash config.sh ensure network
  bash config.sh ensure volumes
}

up_storage() {
  echo "⬆️  Starting STORAGE stack..."
  docker compose -p "$PROJECT_STORAGE" -f "$COMPOSE_STORAGE" up -d
}

down_storage() {
  echo "⬇️  Stopping STORAGE stack..."
  docker compose -p "$PROJECT_STORAGE" -f "$COMPOSE_STORAGE" down
}

up_ui() {
  echo "⬆️  Starting UI stack..."
  docker compose -p "$PROJECT_UI" -f "$COMPOSE_UI" up -d
}

down_ui() {
  echo "⬇️  Stopping UI stack..."
  docker compose -p "$PROJECT_UI" -f "$COMPOSE_UI" down
}

up_all() {
  ensure_infrastructure
  up_storage
  up_ui
}

down_all() {
  down_ui
  down_storage
}

usage() {
  echo "Usage: $0 {init|up|down} {storage|ui|all}"
  echo
  echo "Commands:"
  echo "  init    - Initialize infrastructure (networks and volumes)"
  echo "  up      - Start services"
  echo "  down    - Stop services"
  echo
  echo "Examples:"
  echo "  $0 init all          # Setup infrastructure"
  echo "  $0 up storage        # Start storage services"
  echo "  $0 up ui             # Start UI services"
  echo "  $0 up all            # Start all services (auto-initializes infrastructure)"
  echo "  $0 down ui           # Stop UI services"
  echo "  $0 down all          # Stop all services"
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

ACTION=$1
TARGET=$2

case "$ACTION:$TARGET" in
  init:storage)  ensure_infrastructure; echo "✅ Storage infrastructure initialized" ;;
  init:ui)       ensure_infrastructure; echo "✅ UI infrastructure initialized" ;;
  init:all)      ensure_infrastructure; echo "✅ All infrastructure initialized" ;;
  up:storage)   up_storage ;;
  down:storage) down_storage ;;
  up:ui)        up_ui ;;
  down:ui)      down_ui ;;
  up:all)       up_all ;;
  down:all)     down_all ;;
  *)
    usage
    exit 1
    ;;
esac