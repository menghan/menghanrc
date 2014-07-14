FROM ubuntu:14.04

MAINTAINER menghan

RUN apt-get update && \
	apt-get install -y openvpn dnsmasq openssh-server && \
	apt-get clean

# openvpn configuration
ADD openvpn/ /etc/openvpn/

# dnsmasq configuration
RUN echo 'conf-dir=/etc/dnsmasq.conf.d' >> /etc/dnsmasq.conf
ADD dnsmasq.conf /etc/dnsmasq.conf.d/

RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200

CMD service openvpn restart; service dnsmasq restart; service ssh restart; tail -F /dev/null
