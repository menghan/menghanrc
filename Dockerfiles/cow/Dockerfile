from menghan/supervisor

maintainer menghan <menghan412@gmail.com>

RUN apt-get update && \
	apt-get install -y mercurial git wget && \
	wget -qO- http://golang.org/dl/go1.3.linux-amd64.tar.gz | tar -xz -C /usr/local && \
	GOPATH=/usr/local /usr/local/go/bin/go get github.com/menghan/cow && \
	rm -rf /usr/local/go && \
	apt-get purge -y mercurial git wget && \
	apt-get autoremove -y
	apt-get clean

ADD cow.conf /etc/supervisor/conf.d/

ENV HOME /home/user
ENV LANG C.UTF-8

USER user
RUN mkdir -p /home/user/.cow

VOLUME /home/user/.cow
