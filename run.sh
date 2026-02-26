#!/usr/bin/env bash
set -e

PROJECT_STORAGE="storage"
PROJECT_UI="ui"

COMPOSE_STORAGE="docker-compose.storage.yml"
COMPOSE_UI="docker-compose.ui.yml"

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
  up_storage
  up_ui
}

down_all() {
  down_ui
  down_storage
}

usage() {
  echo "Usage: $0 {up|down} {storage|ui|all}"
  echo
  echo "Examples:"
  echo "  $0 up storage"
  echo "  $0 up ui"
  echo "  $0 up all"
  echo "  $0 down ui"
  echo "  $0 down all"
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

ACTION=$1
TARGET=$2

case "$ACTION:$TARGET" in
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