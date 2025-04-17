#!/usr/bin/env bash

set -e
shopt -s nocaseglob

curr_name="$(basename $0)"

appimage=$(ls -1t $HOME/bin/$curr_name*.AppImage | head -n 1)
chmod +x "$appimage"
"$HOME/bin/$appimage" "$@" || "$HOME/bin/$appimage" --no-sandbox "$@"
