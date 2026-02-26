#!/usr/bin/env bash
set -e

ENV_FILE=".env"

# =========================
# Config
# =========================
VOLUMES=(
  grafana-data
  postgres-data
  mongo-data
  redis-data
  minio-data
  kafka-data
)

# =========================
# Load .env
# =========================
load_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ .env file not found"
    exit 1
  fi

  set -a
  source "$ENV_FILE"
  set +a
}

# =========================
# Volume helpers
# =========================
ensure_volume() {
  local volume="$1"

  if [[ -z "$volume" ]]; then
    echo "❌ Volume name required"
    exit 1
  fi

  if docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "✔ Volume exists: $volume"
  else
    echo "📦 Creating volume: $volume"
    docker volume create "$volume" >/dev/null
  fi
}

remove_volume() {
  local volume="$1"

  if [[ -z "$volume" ]]; then
    echo "❌ Volume name required"
    exit 1
  fi

  if docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "🗑 Removing volume: $volume"
    docker volume rm "$volume" >/dev/null
  else
    echo "ℹ Volume not found: $volume"
  fi
}

ensure_all_volumes() {
  for volume in "${VOLUMES[@]}"; do
    ensure_volume "$volume"
  done
}

remove_all_volumes() {
  for volume in "${VOLUMES[@]}"; do
    remove_volume "$volume"
  done
}

# =========================
# Network helpers
# =========================
ensure_network() {
  load_env

  if [[ -z "$APP_NETWORK" ]]; then
    echo "❌ APP_NETWORK not set in .env"
    exit 1
  fi

  if docker network inspect "$APP_NETWORK" >/dev/null 2>&1; then
    echo "✔ Network exists: $APP_NETWORK"
  else
    echo "🌐 Creating network: $APP_NETWORK"
    docker network create "$APP_NETWORK" >/dev/null
  fi
}

remove_network() {
  load_env

  if docker network inspect "$APP_NETWORK" >/dev/null 2>&1; then
    echo "🗑 Removing network: $APP_NETWORK"
    docker network rm "$APP_NETWORK" >/dev/null
  else
    echo "ℹ Network not found: $APP_NETWORK"
  fi
}

# =========================
# Usage
# =========================
usage() {
  echo "Usage:"
  echo "  $0 ensure network"
  echo "  $0 remove network"
  echo
  echo "  $0 ensure volume <volume-name>"
  echo "  $0 remove volume <volume-name>"
  echo
  echo "  $0 ensure volumes"
  echo "  $0 remove volumes"
  echo
  echo "Examples:"
  echo "  $0 ensure network"
  echo "  $0 ensure volume redis-data"
  echo "  $0 ensure volumes"
  echo "  $0 remove volume minio-data"
  echo "  $0 remove volumes"
}

# =========================
# Command routing
# =========================
if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

ACTION=$1
TARGET=$2
NAME=$3

case "$ACTION:$TARGET" in
  ensure:network) ensure_network ;;
  remove:network) remove_network ;;
  ensure:volume)  ensure_volume "$NAME" ;;
  remove:volume)  remove_volume "$NAME" ;;
  ensure:volumes) ensure_all_volumes ;;
  remove:volumes) remove_all_volumes ;;
  *)
    usage
    exit 1
    ;;
esac
