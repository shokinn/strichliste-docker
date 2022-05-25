# strichliste-docker
A [Strichliste](https://github.com/strichliste) docker-compose base on nginx's unprivileged, php's fpm and Mariadb's container.


## Build locally

### Build and run whole stack locally

```bash
docker build -t ghcr.io/shokinn/strichliste-docker/frontend:develop -f ./docker/frontend.Dockerfile . \
    && docker build -t ghcr.io/shokinn/strichliste-docker/backend:develop -f ./docker/backend.Dockerfile . \
    && docker compose up

```

### Build container independently
Frontend:  
```bash
docker build -t ghcr.io/shokinn/strichliste-docker/frontend:develop -f ./docker/frontend.Dockerfile .
```

Backend:  
```bash
docker build -t ghcr.io/shokinn/strichliste-docker/backend:develop -f ./docker/backend.Dockerfile .
```

## Backups

### Performing a manual local database dump

1. Go to your directory where your docker-compose.yml is.
2. Dump databases:  
```bash
docker compose exec -T database mariadb sh -c 'exec mysqldump --all-databases -uroot -p"${MARIADB_ROOT_PASSWORD}"' > mariadb-dump-$(date +%F_%H-%M-%S).sql
```
