#!/bin/bash

set -e

FIRST_RUN="${XDG_CONFIG_HOME}/flatpak-vscode-first-run"

if [ ! -f ${FIRST_RUN} ]; then
  WARNING_FILE="/app/share/vscode/flatpak-warning.txt"
  touch ${FIRST_RUN}
fi

PYTHONDIR=lib/python3.7/site-packages

for sdk_ext_dir in /usr/lib/sdk/*; do
  # If the extension provides enable.sh, use it
  if [[ -f $sdk_ext_dir/enable.sh ]]; then
    . $sdk_ext_dir/enable.sh
    continue
  fi
  # Append extension's bindir to PATH, if present
  if [[ -d $sdk_ext_dir/bin ]]; then
    export PATH=$PATH:$sdk_ext_dir/bin
  fi
  # Append extension's python modules dir to PYTHONPATH, if present
  if [[ -d $sdk_ext_dir/$PYTHONDIR ]]; then
    if [[ -z $PYTHONPATH ]]; then
      export PYTHONPATH=$sdk_ext_dir/$PYTHONDIR
    else
      export PYTHONPATH=$PYTHONPATH:$sdk_ext_dir/$PYTHONDIR
    fi
  fi
done

if [[ -d /usr/lib/sdk/mono5 ]]; then
  . /usr/lib/sdk/mono5/enable.sh
fi

exec env PATH="${PATH}:${XDG_DATA_HOME}/node_modules/bin" \
  /app/extra/vscode/bin/code --extensions-dir=${XDG_DATA_HOME}/vscode/extensions "$@" ${WARNING_FILE}
