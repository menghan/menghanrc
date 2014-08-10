FROM debian:wheezy
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && apt-get install -y python-pip python-m2crypto git

RUN pip install "git+http://github.com/menghan/shadowsocks.git@master"

RUN adduser --uid 1000 --group --system user
USER user
ENV LANG C.UTF-8

# Configure container to run as an executable
ENTRYPOINT ["/usr/local/bin/ssserver"]
