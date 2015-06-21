#!/bin/bash

# To build and run docker images:
#
#    $ export VERSION=1.0
#    $ docker build -t="alerta/test:$VERSION" .
#    $ run.sh alerta/test:$VERSION

IMAGE=${1:-alerta/alerta-web} && shift

DOCKER_HOST="tcp://52.17.76.5:4243"

docker run --name alerta-db -d mongo
docker pull alerta/alerta-web

AUTH_REQUIRED=True
PROVIDER=google
CLIENT_ID=
CLIENT_SECRET=
ALLOWED_EMAIL_DOMAIN=example.com

docker run --link alerta-db:mongo \
-e AUTH_REQUIRED=$AUTH_REQUIRED \
-e PROVIDER=$PROVIDER \
-e CLIENT_ID=$CLIENT_ID \
-e CLIENT_SECRET=$CLIENT_SECRET \
-e ALLOWED_EMAIL_DOMAIN=$ALLOWED_EMAIL_DOMAIN \
-t -i -p 49901:80 $IMAGE $*
