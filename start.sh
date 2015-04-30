#!/bin/bash

MSUSER="${MSUSER:-reviewboard}"
MSPASSWORD="${MSPASSWORD:-reviewboard}"
MSDB="${MSDB:-reviewboard}"

# Get these variables either from MSPORT and MSHOST, or from
# linked "ms" container.
MSPORT="${MSPORT:-$( echo "${MS_PORT_3306_TCP_PORT:-3306}" )}"
MSHOST="${MSHOST:-$( echo "${MS_PORT_3306_TCP_ADDR:-127.0.0.1}" )}"

# Get these variable either from MEMCACHED env var, or from
# linked "memcached" container.
MEMCACHED_LINKED_NOTCP="${MEMCACHED_PORT#tcp://}"
MEMCACHED="${MEMCACHED:-$( echo "${MEMCACHED_LINKED_NOTCP:-127.0.0.1}" )}"

DOMAIN="${DOMAIN:localhost}"
DEBUG="$DEBUG"

mkdir -p /var/www/

CONFFILE=/var/www/reviewboard/conf/settings_local.py

if [[ ! -d /var/www/reviewboard ]]; then
    rb-site install --noinput \
        --domain-name="$DOMAIN" \
        --site-root=/ --static-url=static/ --media-url=media/ \
        --db-type=mysql \
        --db-name="$MSDB" \
        --db-host="$MSHOST" \
        --db-user="$MSUSER" \
        --db-pass="$MSPASSWORD" \
        --cache-type=memcached --cache-info="$MEMCACHED" \
        --web-server-type=lighttpd --web-server-port=8000 \
        --admin-user=admin --admin-password=admin --admin-email=admin@example.com \
        /var/www/reviewboard/
fi
if [[ "$DEBUG" ]]; then
    sed -i 's/DEBUG *= *False/DEBUG=True/' "$CONFFILE"
fi

cat "$CONFFILE"

exec uwsgi --ini /uwsgi.ini