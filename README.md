# Docker Container - Consolidated Stack

A comprehensive Docker Compose setup providing a consolidated infrastructure for both data storage and UI monitoring tools.

## Project Overview

This project provides two modular Docker Compose stacks:
- **Storage Stack**: Core databases and data services (PostgreSQL, MongoDB, Redis, MinIO, Kafka)
- **UI Stack**: Monitoring and management interfaces (pgAdmin, Mongo Express, Grafana, RedisInsight)

All services are containerized and can be managed independently or together.

## Prerequisites

- Docker & Docker Compose (v2.0+)
- Bash shell

## Quick Start

### 1. Configure Environment

```bash
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=myapp
POSTGRES_PORT=5432

# MongoDB
MONGO_USER=admin
MONGO_PASSWORD=your_secure_password
MONGO_PORT=27017

# Redis
REDIS_PASSWORD=your_secure_password
REDIS_PORT=6379

# MinIO (S3-compatible object storage)
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_secure_password
MINIO_API_PORT=9000
MINIO_CONSOLE_PORT=9001

# pgAdmin
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=your_secure_password
PGADMIN_PORT=5050

# Mongo Express
MONGO_EXPRESS_USER=admin
MONGO_EXPRESS_PASSWORD=your_secure_password
MONGO_EXPRESS_PORT=8081

# Grafana
GRAFANA_ADMIN_PASSWORD=your_secure_password
GRAFANA_PORT=3000

# RedisInsight
REDIS_INSIGHT_PORT=5540
RI_HOST=redis
RI_ENCRYPTION_KEY=your_encryption_key
```

### 2. Start Services

```bash
# Start storage stack only
./run.sh up storage

# Start UI stack only
./run.sh up ui

# Start all services
./run.sh up all

# Stop all services
./run.sh down all
```

## Architecture

### Storage Stack (`docker-compose.storage.yml`)

#### PostgreSQL 17
- **Image**: `postgres:17-alpine`
- **Port**: Configurable (default: 5432)
- **Volume**: `postgres-data`
- **Use Case**: Primary relational database

#### MongoDB 8.2
- **Image**: `mongo:8.2-noble`
- **Port**: Configurable (default: 27017)
- **Volume**: `mongo-data`
- **Use Case**: NoSQL document database

#### Redis 7.2.4
- **Image**: `redis:7.2.4`
- **Port**: Configurable (default: 6379)
- **Volume**: `redis-data`
- **Use Case**: In-memory cache and message broker

#### MinIO
- **Image**: `minio/minio:latest`
- **API Port**: Configurable (default: 9000)
- **Console Port**: Configurable (default: 9001)
- **Volume**: `minio-data`
- **Use Case**: S3-compatible object storage

#### Kafka
- Included in storage stack for event streaming
- **Volume**: `kafka-data`

### UI Stack (`docker-compose.ui.yml`)

#### pgAdmin 4
- **Image**: `dpage/pgadmin4:latest`
- **Port**: Configurable (default: 5050)
- **Use Case**: PostgreSQL management and query tool
- **Access**: http://localhost:5050

#### Mongo Express
- **Image**: `mongo-express:latest`
- **Port**: Configurable (default: 8081)
- **Use Case**: MongoDB web admin interface
- **Access**: http://localhost:8081

#### Grafana 9.5.2
- **Image**: `grafana/grafana:9.5.2`
- **Port**: Configurable (default: 3000)
- **Volume**: `grafana-data`
- **Use Case**: Metrics visualization and dashboards
- **Access**: http://localhost:3000

#### RedisInsight
- **Image**: `redis/redisinsight:latest`
- **Port**: Configurable (default: 5540)
- **Use Case**: Redis GUI and monitoring tool
- **Access**: http://localhost:5540

## Scripts

### `run.sh`
Main orchestration script for managing Docker Compose stacks.

**Usage**:
```bash
./run.sh {up|down} {storage|ui|all}
```

**Examples**:
```bash
./run.sh up storage      # Start storage services
./run.sh up ui           # Start UI services
./run.sh up all          # Start everything
./run.sh down storage    # Stop storage services
./run.sh down all        # Stop all services
```

### `config.sh`
Helper script containing:
- Environment variable loading
- Docker volume management
- Utility functions for initialization

## Network

All services are connected via a custom Docker network: `app-net`

This allows services to communicate with each other using their service names as hostnames.

## Volumes

The following named volumes are managed by the system:

- `grafana-data` - Grafana configurations and dashboards
- `postgres-data` - PostgreSQL databases
- `mongo-data` - MongoDB data
- `redis-data` - Redis persistence
- `minio-data` - MinIO object storage
- `kafka-data` - Kafka topics and logs



## Common Tasks

### View Running Containers
```bash
docker ps
```

### View Logs
```bash
# All storage services
docker compose -p storage -f docker-compose.storage.yml logs -f

# All UI services
docker compose -p ui -f docker-compose.ui.yml logs -f

# Specific service
docker compose -p storage -f docker-compose.storage.yml logs -f postgres
```

### Connect to Databases

**PostgreSQL (via psql)**:
```bash
docker exec -it storage-postgres-1 psql -U $POSTGRES_USER -d $POSTGRES_DB
```

**MongoDB (via mongosh)**:
```bash
docker exec -it storage-mongo-1 mongosh -u $MONGO_USER -p $MONGO_PASSWORD
```

**Redis (via redis-cli)**:
```bash
docker exec -it storage-redis-1 redis-cli
```

### Restart a Service
```bash
docker compose -p storage -f docker-compose.storage.yml restart postgres
```

### Remove All Volumes (Caution!)
```bash
docker volume rm grafana-data postgres-data mongo-data redis-data minio-data kafka-data
```

## Access URLs

Once running, access the UI services at:

| Service | URL | Credentials |
|---------|-----|-------------|
| pgAdmin | http://localhost:5050 | Email/Password from .env |
| Mongo Express | http://localhost:8081 | Username/Password from .env |
| Grafana | http://localhost:3000 | admin / GRAFANA_ADMIN_PASSWORD |
| RedisInsight | http://localhost:5540 | Auto-configured |
| MinIO Console | http://localhost:9001 | MINIO_ROOT_USER / MINIO_ROOT_PASSWORD |

## Kubernetes Integration

For Kubernetes deployment, see `kubernete/note.txt` for dashboard access commands.

To retrieve Kubernetes dashboard token:
```bash
kubectl -n kubernetes-dashboard describe secret dashboard-admin-token
```

## Environment Variables

All configuration is managed through the `.env` file. Key variables include:

- Database credentials (PostgreSQL, MongoDB, Redis)
- Port mappings for all services
- UI tool credentials and configurations
- Storage configuration for MinIO and Kafka

## Troubleshooting

### Services won't start
1. Check if `.env` file exists and all required variables are set
2. Verify Docker daemon is running
3. Check port availability: `lsof -i -P -n | grep LISTEN`

### Volume errors
- Ensure Docker has sufficient disk space
- Verify volume permissions: `docker volume inspect <volume-name>`

### Network issues
- Verify services can communicate: `docker exec storage-postgres-1 ping storage-redis-1`
- Check network creation: `docker network ls | grep app-net`

### Container crashes
- View logs: `docker logs <container-name>`
- Check resource limits: `docker stats`
