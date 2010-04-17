#!/usr/bin/env bash

if [[ $# -ne 2 ]] ; then
	echo "Usage $0 pubkey.file some@host"
	exit 1
fi

cat $1 | ssh $2 "mkdir -p ~/.ssh; cat - >> ~/.ssh/authorized_keys; chmod 0700 ~/.ssh; chmod 0600 ~/.ssh/authorized_keys"
