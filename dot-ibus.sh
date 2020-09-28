#!/usr/bin/env bash

# link to ~/.config/plasma-workspace/env/ibus.sh

export QT_IM_MODULE=ibus
ibus-daemon -drx

# https://medium.com/hong-kong-linux-user-group/%E4%BF%AE%E6%AD%A3-telegram-desktop-%E5%8F%8A%E5%85%B6%E4%BB%96-qt-%E8%BB%9F%E4%BB%B6%E5%9C%A8-gnome-wayland-%E4%B8%8B%E7%9A%84-ibus-%E4%B8%AD%E6%96%87%E8%BC%B8%E5%85%A5%E5%95%8F%E9%A1%8C-797abc906c3d
export IBUS_USE_PORTAL=1
