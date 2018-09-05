#!/bin/bash
set -x

RUN_ONCE=/app/.run_once

# Generate web console config, if not supplied
if [ ! -f "${ALERTA_WEB_CONF_FILE}" ]; then
  envsubst < /web/config.js.template > "${ALERTA_WEB_CONF_FILE}"
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

  # Set Web URL
  WEB_URL=${BASE_URL%/api}
  sed -i 's@!WEB_URL!@'"${WEB_URL:=/}"'@' /app/nginx.conf

  # Init admin users and API keys
  if [ -n "${ADMIN_USERS}" ]; then
    alertad user --password ${ADMIN_PASSWORD:-alerta} --all
    alertad key --all

    # Create user-defined API key, if required
    if [ -n "${ADMIN_KEY}" ]; then
      alertad key --username $(echo ${ADMIN_USERS} | cut -d, -f1)  --key ${ADMIN_KEY}
    fi
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

# Generate client config, if not supplied
if [ ! -f "${ALERTA_CONF_FILE}" ]; then
  API_KEY=${ADMIN_KEY:-$(alertad keys 2>/dev/null | head -1 | cut -d" " -f1)}
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
fi

exec "$@"
