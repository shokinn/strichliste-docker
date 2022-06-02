FROM alpine:latest

LABEL "org.opencontainers.image.authors"="Philip Henning <mail@philip-henning.com>"
LABEL "org.opencontainers.image.url"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.documentation"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.source"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.vendor"="Philip Henning <mail@philip-henning.com>"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.title"="Strichliste DB periodic backup"
LABEL "org.opencontainers.image.description"="Strichliste's database backup container for periodic backups"
LABEL "org.opencontainers.image.base.name"="hub.docker.com/_/alpine:latest"

COPY db_backup.sh /etc/periodic/daily/db_backup.sh
    
RUN mkdir /db_backups \
    && chmod 770 /db_backups \
    && chmod a+x /etc/periodic/daily/*

RUN apk update \
    && apk upgrade \
    && apk add --no-cache mariadb-client coreutils bash

CMD [ "crond", "-f", "-d", "8" ]
