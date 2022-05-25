# strichliste-docker

A [Strichliste](https://github.com/strichliste) docker-compose base on nginx's unprivileged, php's fpm and Mariadb's container.

- [strichliste-docker](#strichliste-docker)
  - [Docker images](#docker-images)
    - [Frontend](#frontend)
    - [Backend](#backend)
  - [Build locally](#build-locally)
    - [Build and run whole stack locally](#build-and-run-whole-stack-locally)
    - [Build container independently](#build-container-independently)
  - [Backups](#backups)
    - [Performing a manual local database dump](#performing-a-manual-local-database-dump)
## Docker images

### Frontend

[strichliste-frontend](https://github.com/shokinn/strichliste-docker/pkgs/container/strichliste-frontend)

### Backend

[strichliste-backend](https://github.com/shokinn/strichliste-docker/pkgs/container/strichliste-backend)

## Build locally

### Build and run whole stack locally

```bash
docker build -t ghcr.io/shokinn/strichliste-frontend:develop -f ./docker/frontend.Dockerfile . \
    && docker build -t ghcr.io/shokinn/strichliste-backend:develop -f ./docker/backend.Dockerfile . \
    && docker compose up
```

### Build container independently
Frontend:  
```bash
docker build -t ghcr.io/shokinn/strichliste-frontend:develop -f ./docker/frontend.Dockerfile .
```

Backend:  
```bash
docker build -t ghcr.io/shokinn/strichliste-backend:develop -f ./docker/backend.Dockerfile .
```

## Backups

### Performing a manual local database dump

1. Go to your directory where your docker-compose.yml is.
2. Dump databases:  
```bash
docker compose exec -T database mariadb sh -c 'exec mysqldump --all-databases -uroot -p"${MARIADB_ROOT_PASSWORD}"' > mariadb-dump-$(date +%F_%H-%M-%S).sql
```
