#!/usr/bin/env bash

set -e

LS=ls
if [[ `uname -a` =~ "Darwin" ]]; then
	LS=gls
fi

$LS -1 *.flv | while read f
do
	echo "ffmpeg -i \"$f\" -c copy -y \"""${f/.flv/.mp4}"'"'
done > transcode.sh
sh transcode.sh
rm -f transcode.sh
