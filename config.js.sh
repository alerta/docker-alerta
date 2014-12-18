#!/bin/bash

cat >/app/config.js << EOF
'use strict';
angular.module('config', [])
  .constant('config', {
    'endpoint'    : "/api",
    'client_id'   : "$CLIENT_ID",
    'redirect_url': "$REDIRECT_URL"
  });
EOF
