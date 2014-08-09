from ubuntu:14.04

maintainer menghan <menghan412@gmail.com>

RUN apt-get update
RUN apt-get install -y mercurial git supervisor

ADD http://golang.org/dl/go1.3.linux-amd64.tar.gz /usr/local/
RUN tar -C /usr/local -xf /usr/local/go1.3.linux-amd64.tar.gz || true

RUN GOPATH=/usr/local /usr/local/go/bin/go get github.com/menghan/cow
ADD cow.conf /etc/supervisor/conf.d/
RUN chmod a+w /var/log/supervisor /var/run /run

RUN adduser --uid 1000 --group --system user
RUN mkdir -p /home/user/.cow && chown user:user /home/user/.cow

ENV HOME /home/user
ENV LANG C.UTF-8
USER user
VOLUME /home/user/.cow
CMD /usr/bin/supervisord -n
