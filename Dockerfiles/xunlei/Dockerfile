# alias xunlei='docker run -it -v $PWD:/mnt xunlei'

FROM ubuntu:14.04

MAINTAINER menghan

RUN apt-get update
RUN apt-get install -y python wget unzip
ADD https://github.com/iambus/xunlei-lixian/archive/master.zip /usr/local/
RUN cd /usr/local && unzip master.zip && cd bin && ln -s ../xunlei-lixian-master/lixian_cli.py xunlei

RUN adduser --uid 1000 --group --system user
USER user
ENV HOME /mnt
ENV LANG C.UTF-8

WORKDIR /mnt
ENTRYPOINT ["xunlei"]
CMD ["-h"]
