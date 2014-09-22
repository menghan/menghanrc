FROM debian:wheezy

MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && \
	apt-get install -y openvpn dnsmasq && \
	apt-get clean

# dnsmasq configuration
RUN mkdir -p /etc/dnsmasq.conf.d && echo 'conf-dir=/etc/dnsmasq.conf.d' >> /etc/dnsmasq.conf

RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200

CMD service dnsmasq start; cd /etc/openvpn; /usr/sbin/openvpn "$(ls *.ovpn *.conf 2>/dev/null)"
