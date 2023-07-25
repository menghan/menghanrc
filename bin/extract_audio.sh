#!/usr/bin/env bash

set -e

for video in "$@"; do
	video="$(realpath $video)"

	# Stream #0:0: Audio: mp3
	acodec="$(ffprobe $video 2>&1 | egrep '  Stream #.*: Audio: ' | head -n 1 | awk '{print $4}')"
	if [[ -z $acodec ]]; then
		echo "Cant get codec for $video"
		echo
		continue
	fi

	audio="${video/.mp4/}.$acodec"

	echo "$video to $audio"
	ffmpeg -hide_banner -loglevel error -y -i "$video" -vn -acodec copy "$audio"
done
