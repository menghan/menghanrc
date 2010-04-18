#!/usr/bin/env bash

SRCDIR=$(pwd)
INSTALLPREFIX=/usr/local/menghan
WGET="wget -q"

function download_or_exit
{
	if [[ $# -ne 1 ]]; then
		echo 'Usage: download_or_exit http://a.b.c/d.tar.gz'
		return 1
	fi
	if ! cd ${SRCDIR}; then
		echo 'cd ${SRCDIR} failed'
		return 1
	fi
	if ! $WGET $1; then
		echo 'download failed'
		return 1
	fi
}

export -f download_or_exit
