#!/bin/bash

set -e

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
  PLUGINS=$(python -c "exec(open('$ALERTA_SVR_CONF_FILE')); print ','.join(PLUGINS)")
fi

# Install plugins
echo -n $PLUGINS | sed 's/,/\n/g' | grep -v reject | while read plugin
do
  pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=plugins/$plugin
done

# Configure housekeeping
if [ ! -f "/etc/cron.d/alerta" ]; then
  MONGO_ADDR=$(echo $MONGO_URI | sed -e 's/mongodb:\/\///')
  echo "* * * * * root /usr/bin/mongo $MONGO_ADDR /housekeepingAlerts.js" >/etc/cron.d/alerta
fi

exec "$@"
