#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "Usage: $0 host"
	exit 1
fi

while true
do
	ssh -D 8825 "$1" /bin/bash -c "echo connected!; sleep 8640000"
	sleep 1
	echo 'reconnecting...'
done
