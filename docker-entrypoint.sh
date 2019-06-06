#!/bin/bash
set -e

export BASE_PATH=$(echo "/"${BASE_URL#*//*/} | tr -s /)
export WEB_PATH=$(echo ${BASE_PATH%/api}"/" | tr -s /)

RUN_ONCE=/app/.run_once

if [ ! -f "${RUN_ONCE}" ]; then
  touch ${RUN_ONCE}

  # Fix web server config
  sed -i 's@!BASE_PATH!@'"${BASE_PATH}"'@' /app/uwsgi.ini
  sed -i 's@!WEB_PATH!@'"${WEB_PATH}"'@' /app/nginx.conf
  sed -i 's@!BASE_PATH!@'"${BASE_PATH}"'@' /app/nginx.conf

  # Update static assets
  sed -i 's@href=/@href='"${WEB_PATH}"'@g' /web/index.html
  sed -i 's@src=/@src='"${WEB_PATH}"'@g' /web/index.html

  # Update supervisor config
  sed -i 's@!BASE_PATH!@'"${BASE_PATH}"'@' /app/supervisord.conf

  # Generate web console config, if not supplied
  if [ ! -f "${ALERTA_WEB_CONF_FILE}" ]; then
    envsubst < /web/config.json.template > "${ALERTA_WEB_CONF_FILE}"
  fi

  # Generate server config, if not supplied
  if [ ! -f "${ALERTA_SVR_CONF_FILE}" ]; then
    cat >"${ALERTA_SVR_CONF_FILE}" << EOF
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
EOF
  fi

  # Init admin users and API keys
  if [ -n "${ADMIN_USERS}" ]; then
    alertad user --all --password ${ADMIN_PASSWORD:-alerta} || true
    alertad key --all

    # Create user-defined API key, if required
    if [ -n "${ADMIN_KEY}" ]; then
      alertad key --username $(echo ${ADMIN_USERS} | cut -d, -f1)  --key ${ADMIN_KEY}
    fi
  fi

  # Generate client config, if not supplied
  if [ ! -f "${ALERTA_CONF_FILE}" ]; then
    if [ "${AUTH_REQUIRED}" == "True" ]; then
      API_KEY=${ADMIN_KEY:-$(alertad keys 2>/dev/null | tail -1 | cut -d" " -f1)}
      cat >${ALERTA_CONF_FILE} << EOF
[DEFAULT]
endpoint = http://localhost:8080${BASE_PATH}
key = ${API_KEY}
EOF
    else
      cat >${ALERTA_CONF_FILE} << EOF
[DEFAULT]
endpoint = http://localhost:8080${BASE_PATH}
EOF
    fi
  fi

  echo
  echo 'Alerta init process complete; ready for start up.'
  echo
fi

exec "$@"
