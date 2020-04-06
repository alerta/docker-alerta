#!/bin/bash
set -e

ADMIN_USER=${ADMIN_USERS%%,*}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-alerta}

# Generate minimal server config, if not supplied
if [ ! -f "${ALERTA_SVR_CONF_FILE}" ]; then
  cat >"${ALERTA_SVR_CONF_FILE}" << EOF
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
EOF
fi

# Generate minimal client config, if not supplied
if [ ! -f "${ALERTA_CONF_FILE}" ]; then
  cat >${ALERTA_CONF_FILE} << EOF
[DEFAULT]
endpoint = http://localhost:8080/api
EOF
fi

# Add API key to client config, if required
if [ "${AUTH_REQUIRED}" == "True" ]; then
  if [ -z $(grep 'key =' ${ALERTA_CONF_FILE}) ]; then
    API_KEY=$(alertad key --username ${ADMIN_USER}  | grep "${ADMIN_USER}$" | cut -d" " -f1)
    cat >>${ALERTA_CONF_FILE} << EOF
key = ${API_KEY}
EOF
  fi
fi

# Init admin users and API keys
if [ -n "${ADMIN_USERS}" ]; then
  alertad user --all --password ${ADMIN_PASSWORD} || true
  alertad key --all  # FIXME - should only generate keys for missing admin users

  # Create user-defined API key, if required
  if [ -n "${ADMIN_KEY}" ]; then
    if [ -z $(alertad keys | grep "${ADMIN_KEY}") ]; then
      alertad key --username ${ADMIN_USER} --key ${ADMIN_KEY}
    fi
  fi
fi

echo
echo 'Alerta init process complete; ready for start up.'
echo

exec "$@"
