FROM menghan/supervisor
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && apt-get install -y python-pip python-m2crypto git

RUN pip install "git+http://github.com/menghan/shadowsocks.git@master"

ADD shadowsocks.conf /etc/supervisor/conf.d/
ADD shadowsocks.json /etc/

USER user
