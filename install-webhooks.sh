#!/bin/bash

while read webhook version; do
  echo "Installing '${webhook}' (${version})"
  /venv/bin/pip install git+https://github.com/alerta/alerta-contrib.git@${version}#subdirectory=${webhook}
done </app/webhooks.txt
