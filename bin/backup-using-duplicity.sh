#!/usr/bin/env bash

set -e

if [[ -z $3 ]]; then
	echo "Usage: $0 src dst container_host_name"
	exit 1
fi

docker run --rm \
	-v "$1":/src:ro \
	-v "$2":/dst \
	-v /etc/localtime:/etc/localtime:ro \
	--hostname "$3" \
	menghan/duplicity \
	duplicity --progress --no-encryption --exclude-regexp='/src/.*\.dropbox.*' -v 6 --volsize 100 /src file:///dst
