FROM ubuntu:14.04

MAINTAINER menghan

RUN apt-get install -y git
RUN apt-get install -y --no-install-recommends mercurial openvpn dnsmasq golang-go

RUN GOPATH=/usr/local go get github.com/cyfdecyf/cow

# openvpn configuration
ADD openvpn/ /etc/openvpn/

# dnsmasq configuration
RUN echo 'conf-dir=/etc/dnsmasq.conf.d' >> /etc/dnsmasq.conf
ADD dnsmasq.conf /etc/dnsmasq.conf.d/

ADD start-all.sh /usr/local/bin/
CMD start-all.sh
