#!/bin/bash

#docker-compose -f docker-compose.yml -f docker-compose.postgres.yml up

export IMAGE_NAME=alerta

$PWD/hooks/build
