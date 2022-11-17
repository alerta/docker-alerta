#!/bin/bash

while read plugin version; do
  echo "Installing '${plugin}' (${version})"
  pip install git+https://github.com/alerta/alerta-contrib.git@${version}#subdirectory=${plugin}
done </app/plugins.txt
