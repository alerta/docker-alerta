#!/bin/bash
set -x

RUN_ONCE=/app/.run_once

# Generate web console config, if not supplied
if [ ! -f "${ALERTA_WEB_CONF_FILE}" ]; then
  cat >"${ALERTA_WEB_CONF_FILE}" << EOF
'use strict';
angular.module('config', [])
  .constant('config', {
    'endpoint'    : "${BASE_URL}",
    'provider'    : "${PROVIDER}",
    'client_id'   : "${OAUTH2_CLIENT_ID}",
    'colors'      : {}
  });
EOF
fi

# Generate server config, if not supplied
if [ ! -f "${ALERTA_SVR_CONF_FILE}" ]; then
  cat >"${ALERTA_SVR_CONF_FILE}" << EOF
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
EOF
fi

if [ ! -f "${RUN_ONCE}" ]; then
  # Set BASE_URL
  sed -i 's@!BASE_URL!@'"$BASE_URL"'@' /app/nginx.conf
  sed -i 's@!BASE_URL!@'"$BASE_URL"'@' /app/supervisord.conf

  # Init admin users and API Keys
  if [ -n "${ADMIN_USERS}" ]; then
    alertad user --password ${ADMIN_PASSWORD:-alerta} --all
    alertad key --all
  fi

  # Generate alerta CLI config
  API_KEY=`alertad keys 2>/dev/null | head -1 | cut -d" " -f1`
  if [ -n "${API_KEY}" ]; then
    cat >${ALERTA_CONF_FILE} << EOF
[DEFAULT]
endpoint = http://localhost:8080${BASE_URL}
key = ${API_KEY}
EOF
  else
    cat >${ALERTA_CONF_FILE} << EOF
[DEFAULT]
endpoint = http://localhost:8080${BASE_URL}
EOF
  fi

  # Install plugins
  IFS=","
  for plugin in ${INSTALL_PLUGINS}
  do
    echo "Installing plugin '${plugin}'"
    /venv/bin/pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=plugins/$plugin
  done
  touch ${RUN_ONCE}
fi

exec "$@"
