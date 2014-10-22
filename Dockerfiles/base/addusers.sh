#!/usr/bin/env bash

apt-get update
apt-get install -y adduser
for ((i=500; i<5000; i++)); do
	addgroup --system --gid "$i" "$(printf "group%04d" $i)" --quiet
	adduser --system --no-create-home --disabled-password --disabled-login --uid "$i" --gid "$i" "$(printf "user%04d" $i)" --quiet
done
rm -rf /var/lib/apt/lists/*
