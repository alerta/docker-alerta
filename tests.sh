#!/bin/sh

curl -sf http://sut:8080/ || (echo "ERROR: no response from web UI" && exit 11)
curl -sf http://sut:8080/api/_ || (echo "ERROR: no response from API endpoint" && exit 12)
curl -sf http://sut:8080/api/management/gtg || (echo "ERROR: no response from API good-to-go healthcheck" && exit 13)
curl -sf http://sut:8080/api/alerts && (echo "ERROR: authentication not enabled" && exit 14)
curl -sf http://sut:8080/api/alerts?api-key=demo-key || (echo "ERROR: could not query for alerts" && exit 15)
