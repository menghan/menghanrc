FROM menghan/base
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && \
	apt-get install -y python-pip git python-pkg-resources && \
	pip install "git+http://github.com/menghan/shadowsocks.git@master" && \
	apt-get purge -y python-pip git && \
	apt-get autoremove -y && \
	apt-get clean

ADD shadowsocks.json /etc/

USER nobody
CMD /usr/local/bin/ssserver -c /etc/shadowsocks.json
