#!/bin/sh

# Generate web console config, if not supplied
if [ ! -f "${ALERTA_WEB_CONF_FILE}" ]; then
  envsubst < /usr/share/nginx/html/config.json.template > /usr/share/nginx/html/config.json
fi

exec "$@"
