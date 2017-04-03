#!/usr/bin/env bash

# known issues:
# 1. only support 01-99 prefixes
# 2. youku may return mp4 instead of flv

set -e

SED=sed
MKTEMP=mktemp
LS=ls
if [[ `uname -a` =~ "Darwin" ]]; then
	SED=gsed
	MKTEMP=gmktemp
	LS=gls
fi

count=${1:-1}

for ((i=1; i<=$count; i++))
do
	T=$($MKTEMP -p .)
	output=$(ls *`printf "%02d" $i`*_part*.flv | head -n1 | $SED 's/-[a-zA-Z0-9]\{15\}_part[0-9]\{1,\}.flv/.flv/')
	$LS -v1 *`printf "%02d" $i`*_part*.flv | $SED -e "s/^/file \'/" -e "s/$/\'/" > "$T"
	ffmpeg -f concat -safe -1 -i "$T" -c copy -y "$output"
	rm -f "$T"
done
