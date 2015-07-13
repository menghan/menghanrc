FROM debian:latest
MAINTAINER Menghan Zheng <menghan412@gmail.com>

ENV LANG C.UTF-8

RUN apt-get update && \
	apt-get install -y python-pip && \
	pip install shadowsocks && \
	apt-get purge -y python-pip && \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ADD shadowsocks.json /etc/

USER nobody
CMD /usr/local/bin/ssserver -c /etc/shadowsocks.json
