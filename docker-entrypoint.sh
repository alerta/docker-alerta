#!/bin/bash
set -x

RUN_ONCE=/app/.run_once

# Set base path
BASE_URL=${BASE_URL:=/}
BASE_PATH=$(echo "/"${BASE_URL#*//*/} | tr -s /)
API_PATH=$(echo ${BASE_PATH}/api | tr -s /)

# Generate web console config, if not supplied
if [ ! -f "${ALERTA_WEB_CONF_FILE}" ]; then
  export BASE_PATH API_PATH
  envsubst < /web/config.json.template > "${ALERTA_WEB_CONF_FILE}"
fi

# Generate server config, if not supplied
if [ ! -f "${ALERTA_SVR_CONF_FILE}" ]; then
  cat >"${ALERTA_SVR_CONF_FILE}" << EOF
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
EOF
fi

if [ ! -f "${RUN_ONCE}" ]; then

  sed -i 's@!BASE_PATH!@'"${API_PATH}"'@' /app/uwsgi.ini
  sed -i 's@!BASE_PATH!@'"${API_PATH}"'@' /app/nginx.conf

  # Set Web URL
  WEB_URL=$(echo ${BASE_PATH}/ | tr -s /)
  sed -i 's@!WEB_PATH!@'"${BASE_PATH}"'@' /app/nginx.conf
  sed -i 's@!WEB_URL!@'"${WEB_URL}"'@' /app/nginx.conf

  sed -i 's@href=/@href='"${WEB_URL}"'@g' /web/index.html
  sed -i 's@src=/@src='"${WEB_URL}"'@g' /web/index.html
  

  # Init admin users and API keys
  if [ -n "${ADMIN_USERS}" ]; then
    if [ "${AUTH_PROVIDER}" = "basic" ]; then
      alertad user --password ${ADMIN_PASSWORD:-alerta} --all
    fi
    alertad key --all

    # Create user-defined API key, if required
    if [ -n "${ADMIN_KEY}" ]; then
      alertad key --username $(echo ${ADMIN_USERS} | cut -d, -f1)  --key ${ADMIN_KEY}
    fi
  fi

  # Install plugins
  IFS_BCK=${IFS}
  IFS=","
  for plugin in ${INSTALL_PLUGINS}; do
    echo "Installing plugin '${plugin}'"
    /venv/bin/pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=plugins/$plugin
  done
  echo "BASE_URL=${BASE_URL}" > ${RUN_ONCE}
  IFS=${IFS_BCK}

  # Install Custom plugins
  # IFS=${IFS_BCK}
  # for plugin_repo in ${PLUGINS_REPO} do
    IFS_BCK=${IFS}
    IFS=","
    for plugin in ${CUSTOM_PLUGINS}; do
      echo "Installing custom plugin '${plugin}' from repo"
      /venv/bin/pip install $plugin
    done
   
    IFS=${IFS_BCK}
  # done
fi

# Generate client config, if not supplied
if [ ! -f "${ALERTA_CONF_FILE}" ]; then
  API_KEY=${ADMIN_KEY:-$(alertad keys 2>/dev/null | tail -1 | cut -d" " -f1)}
  if [ -n "${API_KEY}" ]; then
    cat >${ALERTA_CONF_FILE} << EOF
[DEFAULT]
endpoint = http://localhost:8080${API_PATH}
key = ${API_KEY}
EOF
  else
    cat >${ALERTA_CONF_FILE} << EOF
[DEFAULT]
endpoint = http://localhost:8080${API_PATH}
EOF
  fi
fi

exec "$@"
