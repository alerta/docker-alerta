#!/bin/sh

if ! echo -n "${ALERTA_API_SERVER}" | grep -q '^".*"$'; then
  ALERTA_API_SERVER="\"${ALERTA_API_SERVER}\""
fi

envsubst < /usr/share/nginx/html/config.js.template > /usr/share/nginx/html/config.js

exec "$@"
