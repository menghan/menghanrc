#!/usr/bin/env bash

set -e

if [[ `id -u` != "0" ]]; then
  echo "Please run as root" 1>&2
  exit 1
fi

source_file=/etc/apt/sources.list.d/vscode.sources
cat >$source_file << EOF
Enabled: yes
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
EOF

apt-get update -o Dir::Etc::sourcelist=$source_file

apt-get reinstall -y code
