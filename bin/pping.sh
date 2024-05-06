#!/usr/bin/env bash

# set -e

while true
do
	echo -n "ping $@ from `hostname` at "; date
	ping -c 10 $@ | grep time --line-buffered | tee /tmp/ping$@ | grep time=
	grep -q ', 0% packet loss' /tmp/ping$@ || loss=1
	if [[ -n $loss ]]; then
		egrep --color ' [0-9]*% packet loss' /tmp/ping$@
	fi
	loss=
	echo
	sleep 0.2
done
