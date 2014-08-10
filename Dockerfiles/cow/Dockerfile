from menghan/supervisor

maintainer menghan <menghan412@gmail.com>

RUN apt-get update
RUN apt-get install -y mercurial git

ADD http://golang.org/dl/go1.3.linux-amd64.tar.gz /usr/local/
RUN tar -C /usr/local -xf /usr/local/go1.3.linux-amd64.tar.gz || true

RUN GOPATH=/usr/local /usr/local/go/bin/go get github.com/menghan/cow

ADD cow.conf /etc/supervisor/conf.d/

ENV HOME /home/user
ENV LANG C.UTF-8

USER user
RUN mkdir -p /home/user/.cow

VOLUME /home/user/.cow
