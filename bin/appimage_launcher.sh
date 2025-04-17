#!/usr/bin/env bash

set -e

curr_name="$(basename $0)"
appimage=$(shopt -s nocaseglob; ls -1t $HOME/bin/$curr_name*.AppImage | head -n 1)
chmod +x "$appimage"
"$appimage" "$@" || "$appimage" --no-sandbox "$@"
