FROM debian:wheezy
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && \
	apt-get install -y python-pip python-m2crypto git && \
	apt-get clean

RUN pip install "git+http://github.com/menghan/shadowsocks.git@master"

ADD shadowsocks.json /etc/

USER nobody
CMD /usr/local/bin/ssserver -c /etc/shadowsocks.json
