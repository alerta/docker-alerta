#!/usr/bin/env bash

#hey \
#-z 2s \
#-H "X-API-Key: demo-key" \
#http://localhost:8080/api/_

#hey \
#-z 30s \
#-H "X-API-Key: demo-key" \
#http://localhost:8080/api/management/gtg

#hey \
#-z 30s \
#-H "X-API-Key: demo-key" \
#http://localhost:8080/api/alerts

hey \
-m POST \
-D ../fixtures/payload.json \
-T 'application/json' \
-z 120s \
-H "X-API-Key: Urvrg5EVxqer1H_pk9A774JV8FYtgwfUxWPAWI_p" \
http://localhost:8080/api/alert
