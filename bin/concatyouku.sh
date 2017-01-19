#!/usr/bin/env bash

# known issues:
# 1. only support 01-99 prefixes
# 2. youku may return mp4 instead of flv

set -e

count=${1:-1}

T=$(mktemp)
for ((i=1; i<=$count; i++))
do
	output=$(ls `printf "%02d" $i`* | head -n1 | sed 's/-[a-zA-Z0-9]\{15\}_part[0-9]\{1,\}.flv/.flv/')
	ls -v1 `printf "%02d" $i`* | sed -e "s/^/file \'/" -e "s/$/\'/" > "$T"
	ffmpeg -f concat -safe -1 -i "$T" -c copy "$output"
	rm -f "$T"
done
