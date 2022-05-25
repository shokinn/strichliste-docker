FROM debian:stable as build

# You can get the latest version from here:
# https://github.com/strichliste/strichliste
ARG strichliste_version='v1.7.1'

RUN apt-get update \
    && apt-get install -y \
        ca-certificates \
        curl \
        tar \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /source
WORKDIR /source

RUN curl -Lo strichliste.tar.gz https://github.com/strichliste/strichliste/releases/download/${strichliste_version}/strichliste.tar.gz \
    && tar xfz strichliste.tar.gz \
    && rm -r strichliste.tar.gz



FROM php:7.4-fpm

ARG BUILD_DATE='1970-01-01T00:00:00+00:00'
ARG strichliste_version='v1.7.1'
ARG BUILD_REV=''
ARG GIT_REF_NAME=''

LABEL "org.opencontainers.image.authors"="Philip Henning <mail@philip-henning.com>"
LABEL "org.opencontainers.image.created"="${BUILD_DATE}"
LABEL "org.opencontainers.image.url"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.documentation"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.source"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.version"="${strichliste_version}"
LABEL "org.opencontainers.image.revision"="${BUILD_REV}"
LABEL "org.opencontainers.image.vendor"="Philip Henning <mail@philip-henning.com>"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.ref.name"="${GIT_REF_NAME}"
LABEL "org.opencontainers.image.title"="Strichliste backend"
LABEL "org.opencontainers.image.description"="Strichliste's backend container based on php-fpm"
LABEL "org.opencontainers.image.base.name"="hub.docker.com/_/php:7.4-fpm"

ARG app_dir='/var/www/strichliste'

WORKDIR ${app_dir}

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions \
        pdo_mysql

RUN apt-get update \
    && apt-get install -y \
        ca-certificates \ 
        default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /source .

RUN chown -R 1000:1000 ${app_dir}

COPY docker/backend_entrypoint.sh /entrypoint.sh

RUN chown 1000:1000 /entrypoint.sh \
    && chmod 500 /entrypoint.sh

VOLUME ${app_dir}/var

USER 1000:1000

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]