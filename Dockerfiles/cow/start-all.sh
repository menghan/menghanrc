#!/usr/bin/env bash

service dnsmasq restart

mkdir -p /dev/net
test -e /dev/net/tun || mknod /dev/net/tun c 10 200
service openvpn restart

cow -rc /.cow/rc
