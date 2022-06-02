#!/bin/bash
set -eu -o pipefail

MARIADB_HOST="${MARIADB_HOST:=database}"
MARIADB_USER="${MARIADB_USER:=strichliste}"
MARIADB_PASSWORD="${MARIADB_PASSWORD:=strichliste}"
MARIADB_DATABASE="${MARIADB_DATABASE:=strichliste}"

mysql="mysql
    --host=${MARIADB_HOST}
    --user=${MARIADB_USER}
    --password=${MARIADB_PASSWORD}
    ${MARIADB_DATABASE}"

# Wait for database
tries=0
maxTries=10
until ${mysql} -e "SELECT VERSION();" &> /dev/null; do
    tries=$((tries + 1))
    if [ $tries -gt $maxTries ]; then
        # give up
        echo "Could not connect to database, aborting"
        exit 1
    fi
    echo "Cannot connect to database, waiting"
    sleep 3
done
echo
echo "Database connection established"

if ! $(${mysql} -e "SELECT COUNT(*) FROM transactions" &> /dev/null); then
    # Import database
    echo "Initializing database"
    cd /var/www/strichliste
    php bin/console doctrine:schema:create

    echo
    echo "Strichliste's database initialized successfully!"
    echo
else
    echo
    echo "Strichliste's database is already installed"
    echo
fi

# Ignoring unbound variables and enable globbing
set +uf

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"