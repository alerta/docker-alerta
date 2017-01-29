#!/bin/bash

set -ex

MONGO_ADDR=$(echo $MONGO_URI | sed -e 's/mongodb:\/\///')

# Generate web console config, if not supplied
if [ ! -f "$ALERTA_WEB_CONF_FILE" ]; then
  cat >$ALERTA_WEB_CONF_FILE << EOF
'use strict';

angular.module('config', [])
  .constant('config', {
    'endpoint'    : "/api",
    'provider'    : "$PROVIDER",
    'client_id'   : "$CLIENT_ID",
    'colors'      : {}
  });
EOF
fi

# Generate server config, if not supplied
if [ ! -f "$ALERTA_SVR_CONF_FILE" ]; then
  cat >$ALERTA_SVR_CONF_FILE << EOF
DEBUG = True
BASE_URL = '$BASE_URL'
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
OAUTH2_CLIENT_ID = '$CLIENT_ID'
OAUTH2_CLIENT_SECRET = '$CLIENT_SECRET'
EOF
else
  PLUGINS=$(python -c "exec(open('$ALERTA_SVR_CONF_FILE')); print(','.join(PLUGINS))")
fi

# Generate API key for admin
KEY=$(openssl rand -base64 32 | cut -c1-40)
EXPIRE_TIME=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z" -d +1year)
/usr/bin/mongo $MONGO_ADDR --eval "db.keys.insert( \
    { \
        user:\"internal\", \
        key:\"${KEY}\", \
        type:\"read-write\", \
        text:\"cron jobs\", \
        expireTime: new Date(\"$EXPIRE_TIME\"), \
        count:0, \
        lastUsedTime: null \
    })"

# Generate client config
cat >/root/alerta.conf << EOF
[DEFAULT]
endpoint = http://localhost/api
key = ${KEY}
EOF

# Install plugins
echo -n $PLUGINS | sed 's/,/\n/g' | grep -v reject | while read plugin
do
  pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=plugins/$plugin
done

# Configure housekeeping and heartbeat alerts
echo  "* * * * * root /usr/bin/mongo $MONGO_ADDR /housekeepingAlerts.js >>/var/log/cron.log 2>&1" >> /etc/cron.d/alerta
echo  "* * * * * root ALERTA_CONF_FILE=$ALERTA_CONF_FILE /usr/local/bin/alerta heartbeats --alert >>/var/log/cron.log 2>&1" >> /etc/cron.d/alerta

exec "$@"
