#!/bin/bash

while read plugin version; do
  echo "Installing '${plugin}' (${version})"
  /venv/bin/pip install --no-cache-dir git+https://github.com/g-research/alerta-contrib.git@${version}#subdirectory=${plugin}
done </app/plugins.txt
