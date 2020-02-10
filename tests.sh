#!/bin/sh

curl -sf http://sut:8080/ || echo "ERROR: no response from API endpoint"
curl -sf http://sut:8080/alerts || echo "ERROR: could not query for alerts"
