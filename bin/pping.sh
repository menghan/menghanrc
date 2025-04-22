#!/usr/bin/env bash

target="$1"
if [[ -z "$target" ]]; then
	echo Usage: "$(basename $0)" target
	exit 1
fi

shift
interval="$1"
if [[ -z "$interval" ]]; then
	interval="1"
fi

mkdir -p /dev/shm/tmp
TMP="/dev/shm/tmp"

host=$(hostname)
while true
do
	echo -n "$host ping $target at "; date
	ping -c 5 $target | grep time --line-buffered | tee $TMP/ping-$target | grep time=
	grep -q ', 0% packet loss' $TMP/ping-$target || loss=1
	if [[ -n $loss ]]; then
		egrep --color ' [0-9]*% packet loss' $TMP/ping-$target
	fi
	loss=
	echo
	sleep "$interval"
done
