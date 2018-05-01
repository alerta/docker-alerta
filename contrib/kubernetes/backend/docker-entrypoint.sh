#!/bin/bash
set -x

RUN_ONCE=/app/.run_once

# Generate server config, if not supplied
if [ ! -f "${ALERTA_SVR_CONF_FILE}" ]; then
  cat >"${ALERTA_SVR_CONF_FILE}" << EOF
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
EOF
fi

if [ ! -f "${RUN_ONCE}" ]; then
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
endpoint = http://localhost:8080
key = ${API_KEY}
EOF
  fi

  # Install plugins
  IFS=","
  for plugin in ${INSTALL_PLUGINS}
  do
    echo "Installing plugin '${plugin}'"
    pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=plugins/$plugin
  done
  touch ${RUN_ONCE}
fi

envsubst < /app/uwsgi.ini.template > /app/uwsgi.ini

exec "$@"
