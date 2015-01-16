#!/bin/bash

cat >/app/config.js << EOF
'use strict';
angular.module('config', [])
  .constant('config', {
    'endpoint'    : "/api",
    'provider'    : "google",
    'client_id'   : "$CLIENT_ID"
  });
EOF
