#!/usr/bin/env bash

which wget >/dev/null 2>&1 || apt-get -y install wget
wget -q -O - https://www.dropbox.com/download?plat=lnx.x86_64 | tar xzf -
