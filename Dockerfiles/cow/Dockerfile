FROM ubuntu:14.04

MAINTAINER menghan

RUN apt-get update && \
	apt-get install -y --no-install-recommends aptitude git && \
	aptitude install -y mercurial openvpn dnsmasq openssh-server golang-go && \
	GOPATH=/usr/local go get github.com/menghan/cow && \
	aptitude remove -y git mercurial aptitude golang-go && \
	apt-get clean

# openvpn configuration
ADD openvpn/ /etc/openvpn/

# dnsmasq configuration
RUN echo 'conf-dir=/etc/dnsmasq.conf.d' >> /etc/dnsmasq.conf
ADD dnsmasq.conf /etc/dnsmasq.conf.d/

RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200

CMD service openvpn restart; service dnsmasq restart; service ssh restart; cow -rc /.cow/rc
