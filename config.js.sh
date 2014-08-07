#!/bin/bash

cat >/app/config.js << EOF

'use strict';

angular.module('config', [])
  .constant('config', {
    'endpoint'    : "", // Use empty string when app served from same origin
    'client_id'   : "$CLIENT_ID",
    'redirect_url': "$REDIRECT_URL"
  });
EOF
