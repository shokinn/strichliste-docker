FROM debian:stable as build

# You can get the latest version from here:
# https://github.com/strichliste/strichliste
ARG APP_VERSION='v1.7.1'

RUN apt-get update \
    && apt-get install -y \
        ca-certificates \
        curl \
        tar \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /source
WORKDIR /source

RUN curl -Lo strichliste.tar.gz https://github.com/strichliste/strichliste/releases/download/${APP_VERSION}/strichliste.tar.gz \
    && tar xfz strichliste.tar.gz \
    && rm -r strichliste.tar.gz



FROM nginxinc/nginx-unprivileged:mainline

ARG APP_VERSION='v1.7.1'
ARG BUILD_DATE='1970-01-01T00:00:00+00:00'
ARG BUILD_REV=''

LABEL "org.opencontainers.image.authors"="Philip Henning <mail@philip-henning.com>"
LABEL "org.opencontainers.image.created"="${BUILD_DATE}"
LABEL "org.opencontainers.image.url"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.documentation"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.source"="https://github.com/shokinn/strichliste-docker"
LABEL "org.opencontainers.image.version"="${APP_VERSION}"
LABEL "org.opencontainers.image.revision"="${BUILD_REV}"
LABEL "org.opencontainers.image.vendor"="Philip Henning <mail@philip-henning.com>"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.ref.name"="${GIT_REF_NAME}"
LABEL "org.opencontainers.image.title"="Strichliste frontend"
LABEL "org.opencontainers.image.description"="Strichliste's frontend container based on nginx unprivileged"
LABEL "org.opencontainers.image.base.name"="hub.docker.com/r/nginxinc/nginx-unprivileged"

ARG app_dir='/var/www/strichliste'

USER root:root

RUN mkdir -p ${app_dir}

WORKDIR ${app_dir}

RUN apt-get update \
    && apt-get install -y \
        ca-certificates \
        yarn

COPY --from=build /source .

RUN chown -R nginx:nginx ${app_dir}

# Implement changes for strichliste into nginx.conf
RUN sed -i 's/#gzip  on;/gzip  on;/' /etc/nginx/nginx.conf \
    && sed -i 's/^error_log  \/var\/log\/nginx\/error.log notice;$/error_log  \/var\/log\/nginx\/error.log warn;/' /etc/nginx/nginx.conf \
    && sed -i "/^http {/a \    log_format scripts \'\$document_root\$fastcgi_script_name \> \$request\';\n" /etc/nginx/nginx.conf \
# forward scripts logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/scripts.log

RUN mkdir -p /etc/nginx/templates \
    && chown -R nginx:nginx /etc/nginx/conf.d/

COPY config/default.conf.template /etc/nginx/templates/default.conf.template

USER nginx:nginx
