#!/usr/bin/env bash

set -e

MKTEMP=mktemp
if [[ `uname -a` =~ "Darwin" ]]; then
	MKTEMP=gmktemp
fi

debfile="$1"
tempdir="$(MKTEMP -d)"
cd "$tempdir"
cp "$OLDPWD/$debfile" "${debfile/%.deb/.7z}"
7z x "${debfile/%.deb/.7z}"
tar xf data.tar
rm data.tar
mv Applications Payload
zip -r "$OLDPWD/${debfile/%.deb/.ipa}" Payload
cd "$OLDPWD"
rm -rf "$tempdir"
